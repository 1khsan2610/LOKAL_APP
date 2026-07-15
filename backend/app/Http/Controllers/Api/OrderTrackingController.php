<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderHistory;

class OrderTrackingController extends Controller
{
    /**
     * GET /api/orders/{id}/tracking
     * Ambil riwayat tracking pesanan untuk konsumen.
     */
    public function tracking($id)
    {
        $order = Order::with(['items.product.images', 'address'])
            ->where('user_id', auth()->id())
            ->findOrFail($id);

        $histories = OrderHistory::where('order_id', $order->id)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(fn($h) => [
                'status'     => $h->status,
                'notes'      => $h->notes,
                'created_at' => $h->created_at->toIso8601String(),
            ]);

        return response()->json([
            'success' => true,
            'data'    => [
                'order_id'       => (int) $order->id,
                'order_number'   => $order->order_number,
                'status_saat_ini' => $order->status,
                'tracking_number' => $order->tracking_number,
                'histories'      => $histories,
            ],
        ], 200);
    }
}