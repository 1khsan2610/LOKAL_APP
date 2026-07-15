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

    /**
     * POST /api/orders/process-payment-webhook
     *
     * Public endpoint: Simulasi webhook sukses dari Midtrans.
     */
    public function processPaymentWebhook(Request $request)
    {
        $request->validate([
            'order_id' => 'required|exists:orders,id',
        ]);

        $order = Order::with(['items.product.umkm.user', 'user.wallet'])
            ->lockForUpdate()
            ->findOrFail($request->order_id);

        if ($order->status === 'processing' || $order->status === 'delivered' || $order->status === 'cancelled') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan sudah diproses sebelumnya.',
            ], 422);
        }

        return $this->distributePaymentFunds($order);
    }

    /**
     * Internal: distribusi dana setelah pembayaran sukses.
     * Dipanggil dari webhook Midtrans (PaymentController) dan endpoint simulasi.
     */
    public function distributePaymentFunds(Order $order)
    {
        return DB::transaction(function () use ($order) {
            // --- Konfigurasi ---
            $commissionPercent = 5;   // 5% komisi admin
            $cashbackPercent   = 2;   // 2% cashback Lokal Coin untuk konsumen
            $coinToRupiah      = 10;  // 1 coin = Rp 10 (sesuai CoinService)

            $cashPaid   = $order->total;
            $subtotal   = $order->subtotal;
            $shipping   = $order->shipping_fee;
            $coinUsed   = $order->coin_discount;

            // --- 1. Hitung komisi & hak UMKM ---
            $commissionAmount = (int) ($subtotal * $commissionPercent / 100);
            $umkmCashAmount   = ($subtotal - $commissionAmount) + $shipping;

            // --- 2. Jika konsumen pakai koin, UMKM tetap dibayar penuh ---
            $adminCoversCoinDiscount = 0;
            if ($coinUsed > 0) {
                $adminCoversCoinDiscount = $coinUsed;
                $umkmCashAmount += $adminCoversCoinDiscount;
            }

            // --- 3. Cashback 2% untuk konsumen (dalam Lokal Coin) ---
            $cashbackRupiah = (int) ($cashPaid * $cashbackPercent / 100);
            $cashbackCoin   = (int) ($cashbackRupiah / $coinToRupiah);
            if ($cashbackCoin < 1 && $cashbackRupiah > 0) {
                $cashbackCoin = 1;
            }

            // --- 4. Validasi saldo komisi admin ---
            $adminWallet = Wallet::whereHas('user', fn($q) => $q->where('role', 'admin'))
                ->lockForUpdate()
                ->first();

            if (!$adminWallet) {
                throw new \Exception('Wallet admin tidak ditemukan. Hubungi administrator.');
            }

            $totalAdminDeduction = $commissionAmount + $adminCoversCoinDiscount + ($cashbackCoin * $coinToRupiah);
            if ($adminWallet->commission_balance < $totalAdminDeduction) {
                throw new \Exception(
                    "Saldo komisi admin tidak mencukupi. Dibutuhkan: Rp " .
                    number_format($totalAdminDeduction) .
                    ", tersedia: Rp " . number_format($adminWallet->commission_balance)
                );
            }

            // --- 5a. Admin: commission_balance bertambah dari komisi 5% ---
            $adminWallet->increment('commission_balance', $commissionAmount);
            $adminWallet->recordHistory(
                'credit', 'commission', $commissionAmount,
                "Komisi 5% dari Order #{$order->order_number} (subtotal: Rp " . number_format($subtotal) . ")",
                'order', $order->id
            );

            // --- 5b. Admin: commission_balance berkurang untuk menutup diskon koin ---
            if ($adminCoversCoinDiscount > 0) {
                $adminWallet->decrement('commission_balance', $adminCoversCoinDiscount);
                $adminWallet->recordHistory(
                    'debit', 'commission', $adminCoversCoinDiscount,
                    "Menutup diskon koin konsumen Order #{$order->order_number} (Rp " . number_format($coinUsed) . ")",
                    'order', $order->id
                );
            }

            // --- 5c. Admin: commission_balance berkurang untuk cashback koin konsumen ---
            if ($cashbackCoin > 0) {
                $cashbackCost = $cashbackCoin * $coinToRupiah;
                $adminWallet->decrement('commission_balance', $cashbackCost);
                $adminWallet->recordHistory(
                    'debit', 'commission', $cashbackCost,
                    "Cashback 2% Lokal Coin untuk Order #{$order->order_number} ({$cashbackCoin} koin)",
                    'order', $order->id
                );
            }

            // --- 5d. UMKM: cash_balance bertambah ---
            $umkmGroups = [];
            foreach ($order->items as $item) {
                $umkmId    = $item->product->umkm_id;
                $umkmUserId = $item->product->umkm->user_id;
                if (!isset($umkmGroups[$umkmId])) {
                    $umkmGroups[$umkmId] = [
                        'user_id'  => $umkmUserId,
                        'subtotal' => 0,
                        'shipping' => 0,
                    ];
                }
                $umkmGroups[$umkmId]['subtotal'] += $item->subtotal;
            }

            $totalSubtotal = $order->items->sum('subtotal');
            foreach ($umkmGroups as $umkmId => &$group) {
                $ratio = $totalSubtotal > 0 ? $group['subtotal'] / $totalSubtotal : 0;
                $group['shipping'] = (int) ($shipping * $ratio);
            }
            unset($group);

            foreach ($umkmGroups as $umkmId => $group) {
                $umkmUserId    = $group['user_id'];
                $umkmSubtotal  = $group['subtotal'];
                $umkmShipping  = $group['shipping'];

                $umkmCommission = (int) ($umkmSubtotal * $commissionPercent / 100);
                $umkmShare      = ($umkmSubtotal - $umkmCommission) + $umkmShipping;

                if ($coinUsed > 0 && $totalSubtotal > 0) {
                    $umkmCoinTopUp = (int) ($coinUsed * ($umkmSubtotal / $totalSubtotal));
                    $umkmShare += $umkmCoinTopUp;
                }

                $umkmWallet = Wallet::where('user_id', $umkmUserId)->lockForUpdate()->first();
                if (!$umkmWallet) {
                    $umkmWallet = Wallet::create([
                        'user_id'           => $umkmUserId,
                        'coin_balance'      => 0,
                        'cash_balance'      => 0,
                        'commission_balance' => 0,
                    ]);
                }

                $umkmWallet->increment('cash_balance', $umkmShare);
                $umkmWallet->recordHistory(
                    'credit', 'cash', $umkmShare,
                    "Pembayaran Order #{$order->order_number} (subtotal: Rp " .
                    number_format($umkmSubtotal) . ", ongkir: Rp " . number_format($umkmShipping) . ")",
                    'order', $order->id
                );
            }

            // --- 5e. Konsumen: tambah Lokal Coin (cashback) ---
            if ($cashbackCoin > 0) {
                $this->coinService->add(
                    $order->user_id,
                    $cashbackCoin,
                    "Cashback 2% pembelian Order #{$order->order_number}"
                );

                $consumerWallet = Wallet::where('user_id', $order->user_id)->lockForUpdate()->first();
                if ($consumerWallet) {
                    $consumerWallet->recordHistory(
                        'credit', 'coin', $cashbackCoin,
                        "Cashback 2% dari Order #{$order->order_number}",
                        'order', $order->id
                    );
                }
            }

            // --- 6. Update status order → 'processing' (Sudah Dibayar) ---
            $order->update(['status' => 'processing']);

            // --- 7. Kirim notifikasi ---
            $this->notifService->sendToUser($order->user_id, [
                'title' => 'Pembayaran Berhasil! ✅',
                'body'  => "Pesanan #{$order->order_number} sudah dibayar. Pesanan sedang diproses oleh penjual." .
                    ($cashbackCoin > 0 ? " Kamu mendapat {$cashbackCoin} Lokal Coin! 🪙" : ''),
                'type'  => 'payment',
                'data'  => ['order_id' => $order->id],
            ]);

            foreach ($umkmGroups as $umkmId => $group) {
                $this->notifService->sendToUser($group['user_id'], [
                    'title' => 'Pesanan Baru Perlu Diproses 📦',
                    'body'  => "Pesanan #{$order->order_number} sudah dibayar. Segera proses pesanan.",
                    'type'  => 'order',
                    'data'  => ['order_id' => $order->id],
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Pembayaran berhasil diproses. Dana telah didistribusikan.',
                'data'    => $order->fresh()->load('payment'),
            ]);
        });
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