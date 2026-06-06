<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Order\CreateOrderRequest;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Payment;
use App\Models\Product;
use App\Services\PaymentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    protected PaymentService $paymentService;

    public function __construct(PaymentService $paymentService)
    {
        $this->paymentService = $paymentService;
    }

    /**
     * Get user's orders
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = Order::where('consumer_id', $user->id)
            ->with('items', 'payment', 'umkm');

        // Filter by status
        if ($request->status) {
            $query->where('status', $request->status);
        }

        // Filter by date range
        if ($request->start_date && $request->end_date) {
            $query->whereBetween('created_at', [$request->start_date, $request->end_date]);
        }

        // Sort
        $query->orderBy('created_at', 'desc');

        $orders = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => OrderResource::collection($orders->items()),
            'pagination' => [
                'total' => $orders->total(),
                'per_page' => $orders->perPage(),
                'current_page' => $orders->currentPage(),
                'last_page' => $orders->lastPage(),
            ],
        ], 200);
    }

    /**
     * Create order
     */
    public function store(CreateOrderRequest $request): JsonResponse
    {
        $user = $request->user();

        return DB::transaction(function () use ($request, $user) {
            $orderItems = [];
            $totalAmount = 0;
            $umkmId = null;

            // Validate and prepare items
            foreach ($request->items as $item) {
                $product = Product::find($item['product_id']);

                if (!$product) {
                    return response()->json([
                        'success' => false,
                        'message' => "Produk #{$item['product_id']} tidak ditemukan.",
                    ], 422);
                }

                if ($product->stock < $item['quantity']) {
                    return response()->json([
                        'success' => false,
                        'message' => "{$product->name} stok tidak cukup. Stok tersedia: {$product->stock}",
                    ], 422);
                }

                if (!$umkmId) {
                    $umkmId = $product->umkm_id;
                } elseif ($umkmId !== $product->umkm_id) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Semua produk harus dari UMKM yang sama dalam satu pesanan.',
                    ], 422);
                }

                $subtotal = $product->price * $item['quantity'];
                $totalAmount += $subtotal;

                $orderItems[] = [
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'product_price' => $product->price,
                    'quantity' => $item['quantity'],
                    'subtotal' => $subtotal,
                ];
            }

            // Create order
            $order = Order::create([
                'order_number' => Order::generateOrderNumber(),
                'consumer_id' => $user->id,
                'umkm_id' => $umkmId,
                'subtotal' => $totalAmount,
                'total_amount' => $totalAmount,
                'status' => Order::STATUS_PENDING,
                'delivery_address' => $request->delivery_address,
                'notes' => $request->notes,
            ]);

            // Create order items
            foreach ($orderItems as $item) {
                OrderItem::create(array_merge($item, ['order_id' => $order->id]));
            }

            // Get payment token from Midtrans
            $paymentResult = $this->paymentService->createPaymentToken($order);

            if (!$paymentResult['success']) {
                return response()->json($paymentResult, 500);
            }

            return response()->json([
                'success' => true,
                'message' => 'Pesanan berhasil dibuat.',
                'data' => [
                    'order' => new OrderResource($order->fresh(['items', 'payment'])),
                    'payment' => [
                        'snap_token' => $paymentResult['snap_token'],
                        'payment_id' => $paymentResult['payment_id'],
                    ],
                ],
            ], 201);
        });
    }

    /**
     * Get order details
     */
    public function show(Order $order): JsonResponse
    {
        $this->authorize('view', $order);

        return response()->json([
            'success' => true,
            'data' => new OrderResource($order->load('items', 'payment', 'reviews')),
        ], 200);
    }

    /**
     * Update order status (UMKM only)
     */
    public function updateStatus(Order $order, Request $request): JsonResponse
    {
        $user = $request->user();

        if ($order->umkm_id !== $user->umkmProfile?->id) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki akses untuk mengubah pesanan ini.',
            ], 403);
        }

        $request->validate([
            'status' => 'required|in:confirmed,processing,completed,cancelled',
        ]);

        $order->update(['status' => $request->status]);

        if ($request->status === Order::STATUS_COMPLETED) {
            $order->update(['completed_at' => now()]);

            // Trigger completion event for rewards
            event(new \App\Events\OrderCompletedEvent($order));
        }

        return response()->json([
            'success' => true,
            'message' => 'Status pesanan berhasil diubah.',
            'data' => new OrderResource($order),
        ], 200);
    }

    /**
     * Get orders for UMKM
     */
    public function umkmOrders(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->isUmkm()) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya UMKM yang dapat melihat pesanan toko.',
            ], 403);
        }

        $query = Order::where('umkm_id', $user->umkmProfile->id)
            ->with('items', 'consumer', 'payment');

        // Filter by status
        if ($request->status) {
            $query->where('status', $request->status);
        }

        // Filter by date
        if ($request->start_date && $request->end_date) {
            $query->whereBetween('created_at', [$request->start_date, $request->end_date]);
        }

        $orders = $query->orderBy('created_at', 'desc')->paginate(20);

        return response()->json([
            'success' => true,
            'data' => OrderResource::collection($orders->items()),
            'pagination' => [
                'total' => $orders->total(),
                'per_page' => $orders->perPage(),
                'current_page' => $orders->currentPage(),
                'last_page' => $orders->lastPage(),
            ],
        ], 200);
    }
}
