<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\Cart;
use App\Models\Umkm;
use App\Models\Wallet;
use App\Services\CoinService;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    public function __construct(
        private CoinService $coinService,
        private NotificationService $notifService
    ) {}

    /**
     * GET /api/orders  —  daftar pesanan pembeli
     */
    public function index(Request $request)
    {
        $orders = Order::with(['items.product.images', 'address', 'payment'])
            ->where('user_id', auth()->id())
            ->when($request->status, fn($q, $s) => $q->where('status', $s))
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json(['success' => true, 'data' => $orders]);
    }

    /**
     * POST /api/orders  —  buat pesanan baru
     */
    public function store(Request $request)
    {
        $request->validate([
            'address_id'      => 'required|exists:addresses,id',
            'shipping_method' => 'required|string',
            'items'           => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity'   => 'required|integer|min:1',
            'items.*.variant_id' => 'nullable|exists:product_variants,id',
            'use_coin'        => 'boolean',
            'notes'           => 'nullable|string|max:500',
        ]);

        return DB::transaction(function () use ($request) {
            $user          = auth()->user();
            $subtotal      = 0;
            $orderItems    = [];

            // Validate & compute items
            foreach ($request->items as $item) {
                $product = Product::lockForUpdate()->findOrFail($item['product_id']);

                if ($product->stock < $item['quantity']) {
                    throw new \Exception("Stok {$product->name} tidak mencukupi.");
                }

                $price     = $product->price;
                $lineTotal = $price * $item['quantity'];
                $subtotal += $lineTotal;

                $orderItems[] = [
                    'product_id' => $product->id,
                    'variant_id' => $item['variant_id'] ?? null,
                    'quantity'   => $item['quantity'],
                    'price'      => $price,
                    'subtotal'   => $lineTotal,
                ];

                // Decrease stock
                $product->decrement('stock', $item['quantity']);
            }

            // Calculate coin discount
            $coinDiscount = 0;
            if ($request->use_coin) {
                $wallet       = Wallet::where('user_id', $user->id)->firstOrFail();
                $coinDiscount = $this->coinService->calculateDiscount($wallet->coin_balance, $subtotal);
            }

            $shippingFee = $this->getShippingFee($request->shipping_method);
            $total       = $subtotal + $shippingFee - $coinDiscount;

            // Create order
            $order = Order::create([
                'order_number'    => 'EL' . strtoupper(Str::random(8)),
                'user_id'         => $user->id,
                'address_id'      => $request->address_id,
                'status'          => 'pending',
                'subtotal'        => $subtotal,
                'shipping_fee'    => $shippingFee,
                'shipping_method' => $request->shipping_method,
                'coin_discount'   => $coinDiscount,
                'total'           => $total,
                'notes'           => $request->notes,
            ]);

            // Insert order items
            foreach ($orderItems as &$oi) {
                $oi['order_id'] = $order->id;
            }
            OrderItem::insert($orderItems);

            // Deduct coin if used
            if ($coinDiscount > 0) {
                $this->coinService->deduct($user->id, $coinDiscount, "Digunakan untuk diskon Order #{$order->order_number}");
            }

            // Clear cart items for these products
            $productIds = collect($request->items)->pluck('product_id');
            Cart::where('user_id', $user->id)->whereIn('product_id', $productIds)->delete();

            // Notify UMKM sellers that a new order has arrived
            $sellerUserIds = Product::whereIn('id', $productIds->unique())
                ->get(['id', 'umkm_id'])
                ->pluck('umkm_id')
                ->filter()
                ->unique()
                ->map(fn($umkmId) => Umkm::where('id', $umkmId)->value('user_id'))
                ->filter();

            foreach ($sellerUserIds as $sellerUserId) {
                $this->notifService->sendToUser((int) $sellerUserId, [
                    'title' => 'Pesanan Baru Masuk 📦',
                    'body'  => "Ada pesanan baru #{$order->order_number} untuk toko Anda.",
                    'type'  => 'order',
                    'data'  => ['order_id' => $order->id, 'order_number' => $order->order_number],
                ]);
            }

            // Send notification to buyer
            $this->notifService->sendToUser($user->id, [
                'title' => 'Pesanan Berhasil Dibuat 🎉',
                'body'  => "Pesanan #{$order->order_number} sedang menunggu konfirmasi pembayaran.",
                'type'  => 'order',
                'data'  => ['order_id' => $order->id],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pesanan berhasil dibuat.',
                'data'    => $order->load('items.product.images', 'address'),
            ], 201);
        });
    }

    /**
     * GET /api/orders/{id}
     */
    public function show($id)
    {
        $order = Order::with(['items.product.images', 'address', 'payment'])
            ->where('user_id', auth()->id())
            ->findOrFail($id);

        return response()->json(['success' => true, 'data' => $order]);
    }

    /**
     * PATCH /api/orders/{id}/cancel
     */
    public function cancel($id)
    {
        $order = Order::where('user_id', auth()->id())
            ->whereIn('status', ['pending', 'awaiting_payment'])
            ->findOrFail($id);

        DB::transaction(function () use ($order) {
            // Restore stock
            foreach ($order->items as $item) {
                $item->product->increment('stock', $item->quantity);
            }

            // Refund coin if used
            if ($order->coin_discount > 0) {
                $this->coinService->add(
                    $order->user_id,
                    (int)($order->coin_discount / 10),
                    "Refund Coin - Order #{$order->order_number}"
                );
            }

            $order->update(['status' => 'cancelled']);
        });

        $this->notifService->sendToUser(auth()->id(), [
            'title' => 'Pesanan Dibatalkan',
            'body'  => "Pesanan #{$order->order_number} telah dibatalkan.",
            'type'  => 'order',
        ]);

        return response()->json(['success' => true, 'message' => 'Pesanan berhasil dibatalkan.']);
    }

    /**
     * PATCH /api/orders/{id}/confirm-received
     */
    public function confirmReceived($id)
    {
        $order = Order::where('user_id', auth()->id())
            ->where('status', 'shipped')
            ->findOrFail($id);

        DB::transaction(function () use ($order) {
            $order->update(['status' => 'delivered', 'delivered_at' => now()]);

            // Award Lokal Coin to buyer
            $coinEarned = (int)($order->subtotal / 1000);
            $this->coinService->add($order->user_id, $coinEarned, "Reward pembelian #{$order->order_number}");

            // Award coin to UMKM seller
            foreach ($order->items as $item) {
                $umkmUserId = $item->product->umkm->user_id;
                $this->coinService->add($umkmUserId, (int)($item->subtotal / 2000), "Komisi penjualan #{$order->order_number}");
            }
        });

        return response()->json(['success' => true, 'message' => 'Pesanan dikonfirmasi diterima. Lokal Coin kamu bertambah! 🪙']);
    }

    /**
     * GET /api/umkm/orders  —  pesanan untuk UMKM seller
     */
    public function sellerOrders(Request $request)
    {
        $umkm = auth()->user()->umkm;

        $orders = Order::with(['items' => fn($q) => $q->whereHas('product', fn($p) => $p->where('umkm_id', $umkm->id)), 'user', 'address'])
            ->whereHas('items.product', fn($q) => $q->where('umkm_id', $umkm->id))
            ->when($request->status, fn($q, $s) => $q->where('status', $s))
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $orders]);
    }

    /**
     * PATCH /api/umkm/orders/{id}/status  —  update status oleh UMKM
     */
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status'          => 'required|in:processing,shipped,cancelled',
            'tracking_number' => 'required_if:status,shipped|nullable|string',
            'notes'           => 'nullable|string',
        ]);

        $umkm  = auth()->user()->umkm;
        $order = Order::whereHas('items.product', fn($q) => $q->where('umkm_id', $umkm->id))->findOrFail($id);

        $order->update([
            'status'          => $request->status,
            'tracking_number' => $request->tracking_number,
            'seller_notes'    => $request->notes,
        ]);

        // Notify buyer
        $this->notifService->sendToUser($order->user_id, [
            'title' => 'Update Status Pesanan',
            'body'  => "Pesanan #{$order->order_number} sekarang: {$request->status}",
            'type'  => 'order',
            'data'  => ['order_id' => $order->id],
        ]);

        return response()->json(['success' => true, 'message' => 'Status pesanan diperbarui.']);
    }

    private function getShippingFee(string $method): int
    {
        return match ($method) {
            'jne_yes'  => 20000,
            'jt'       => 9000,
            'sicepat'  => 9500,
            'anteraja' => 8500,
            default    => 10000, // jne_reg
        };
    }
}
