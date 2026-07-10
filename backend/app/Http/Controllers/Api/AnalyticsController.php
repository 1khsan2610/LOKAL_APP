<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use App\Models\Umkm;
use Illuminate\Support\Facades\DB;

class AnalyticsController extends Controller
{
    public function adminSummary() {
        $salesByMonth = Order::select(
                DB::raw("DATE_FORMAT(created_at, '%Y-%m') as month"),
                DB::raw('SUM(total) as total')
            )
            ->where('status', 'delivered')
            ->groupBy('month')
            ->orderBy('month')
            ->get();

        $topUmkm = Umkm::withCount(['products as products_count'])
            ->orderByDesc('products_count')
            ->limit(5)
            ->get(['id', 'name', 'category']);

        return response()->json([
            'success' => true,
            'data' => [
                'total_users'      => User::count(),
                'total_umkm'       => Umkm::count(),
                'total_orders'     => Order::count(),
                'total_revenue'    => Order::where('status', 'delivered')->sum('total'),
                'sales_by_month'   => $salesByMonth,
                'top_umkm'         => $topUmkm,
            ],
        ]);
    }

    public function umkmSummary() {
        $umkmId = auth()->user()->umkm->id;
        $totalSales = Order::whereHas('items.product', fn($q) => $q->where('umkm_id', $umkmId))->sum('total');
        $orderCount = Order::whereHas('items.product', fn($q) => $q->where('umkm_id', $umkmId))->count();
        
        return response()->json([
            'success' => true,
            'data' => ['total_sales' => $totalSales, 'order_count' => $orderCount]
        ]);
    }

    public function salesChart() {
        // Contoh sederhana: Penjualan per hari
        $data = Order::select(DB::raw('DATE(created_at) as date'), DB::raw('sum(total) as total'))
                     ->groupBy('date')
                     ->get();
        return response()->json(['success' => true, 'data' => $data]);
    }
}