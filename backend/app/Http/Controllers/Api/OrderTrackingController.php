<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TrackingLog;

class OrderTrackingController extends Controller
{
    /**
     * GET /api/orders/{id}/tracking
     * Ambil riwayat tracking berdasarkan order_id.
     */
    public function tracking($id)
    {
        $tracks = TrackingLog::where('order_id', $id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $tracks,
        ], 200);
    }
}
