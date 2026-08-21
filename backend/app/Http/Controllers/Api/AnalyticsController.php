<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\User;
use App\Models\Umkm;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AnalyticsController extends Controller
{
    /**
     * GET /api/admin/analytics — Dashboard Admin
     */
    public function adminSummary()
    {
        $salesByMonth = Order::select(
                DB::raw("DATE_FORMAT(created_at, '%Y-%m') as month"),
                DB::raw('SUM(total) as total'),
                DB::raw('COUNT(*) as order_count')
            )
            ->where('status', 'delivered')
            ->groupBy('month')
            ->orderBy('month', 'desc')
            ->limit(12)
            ->get();

        $topUmkm = Umkm::withCount(['products as products_count'])
            ->orderByDesc('products_count')
            ->limit(5)
            ->get(['id', 'name', 'category']);

        $totalRevenue = Order::where('status', 'delivered')->sum('total');
        $totalRevenueLastMonth = Order::where('status', 'delivered')
            ->whereMonth('created_at', now()->subMonth()->month)
            ->sum('total');

        $revenueGrowth = $totalRevenueLastMonth > 0
            ? round((($totalRevenue - $totalRevenueLastMonth) / $totalRevenueLastMonth) * 100, 1)
            : 0;

        return response()->json([
            'success' => true,
            'data' => [
                'total_users'       => User::count(),
                'total_umkm'        => Umkm::count(),
                'total_orders'      => Order::count(),
                'total_revenue'     => $totalRevenue,
                'revenue_growth'    => $revenueGrowth,
                'sales_by_month'    => $salesByMonth,
                'top_umkm'          => $topUmkm,
            ],
        ]);
    }

    /**
     * GET /api/umkm/analytics/summary — Dashboard UMKM
     * F-06: Total pendapatan bersih, produk terlaris, pertumbuhan
     */
    public function umkmSummary()
    {
        $umkm = auth()->user()->umkm;
        if (!$umkm) {
            return response()->json(['success' => false, 'message' => 'Toko UMKM tidak ditemukan.'], 403);
        }

        $umkmId = $umkm->id;

        // Total pendapatan bersih (dari order delivered)
        $totalRevenue = OrderItem::whereHas('order', fn($q) => $q->where('status', 'delivered'))
            ->whereHas('product', fn($q) => $q->where('umkm_id', $umkmId))
            ->sum(DB::raw('subtotal'));

        // Pendapatan bulan ini
        $revenueThisMonth = OrderItem::whereHas('order', function ($q) {
                $q->where('status', 'delivered')
                  ->whereMonth('created_at', now()->month);
            })
            ->whereHas('product', fn($q) => $q->where('umkm_id', $umkmId))
            ->sum(DB::raw('subtotal'));

        // Pendapatan bulan lalu
        $revenueLastMonth = OrderItem::whereHas('order', function ($q) {
                $q->where('status', 'delivered')
                  ->whereMonth('created_at', now()->subMonth()->month);
            })
            ->whereHas('product', fn($q) => $q->where('umkm_id', $umkmId))
            ->sum(DB::raw('subtotal'));

        $growth = $revenueLastMonth > 0
            ? round((($revenueThisMonth - $revenueLastMonth) / $revenueLastMonth) * 100, 1)
            : 0;

        // Total pesanan
        $orderCount = Order::whereHas('items.product', fn($q) => $q->where('umkm_id', $umkmId))->count();
        $orderCountThisMonth = Order::whereHas('items.product', fn($q) => $q->where('umkm_id', $umkmId))
            ->whereMonth('created_at', now()->month)
            ->count();

        // Produk terlaris (top 5)
        $topProducts = Product::where('umkm_id', $umkmId)
            ->where('is_active', true)
            ->orderBy('sold_count', 'desc')
            ->limit(5)
            ->get(['id', 'name', 'price', 'sold_count', 'stock']);

        // Total produk
        $totalProducts = Product::where('umkm_id', $umkmId)->count();

        return response()->json([
            'success' => true,
            'data' => [
                'total_revenue'       => (int) $totalRevenue,
                'revenue_this_month'  => (int) $revenueThisMonth,
                'revenue_last_month'  => (int) $revenueLastMonth,
                'revenue_growth'      => $growth,
                'total_orders'        => $orderCount,
                'orders_this_month'   => $orderCountThisMonth,
                'total_products'      => $totalProducts,
                'top_products'        => $topProducts,
            ],
        ]);
    }

    /**
     * GET /api/umkm/analytics/weekly — Analitik Minggu Ini vs Minggu Lalu
     * F-06: Perbandingan mingguan dengan tren
     */
    public function weekly()
    {
        $umkm = auth()->user()->umkm;
        if (!$umkm) {
            return response()->json(['success' => false, 'message' => 'Toko UMKM tidak ditemukan.'], 403);
        }

        $umkmId = $umkm->id;
        $now = now();

        // Minggu Ini: 7 hari terakhir
        $currentWeekStart = $now->copy()->startOfWeek();
        $currentWeekEnd = $now->copy()->endOfWeek();

        // Minggu Lalu: 7 hari sebelum minggu ini
        $prevWeekStart = $currentWeekStart->copy()->subWeek();
        $prevWeekEnd = $currentWeekEnd->copy()->subWeek();

        // Pendapatan minggu ini
        $currentRevenue = (int) OrderItem::whereHas('order', function ($q) use ($currentWeekStart, $currentWeekEnd) {
                $q->where('status', 'delivered')
                  ->whereBetween('created_at', [$currentWeekStart, $currentWeekEnd]);
            })
            ->whereHas('product', fn($q) => $q->where('umkm_id', $umkmId))
            ->sum(DB::raw('subtotal'));

        // Pendapatan minggu lalu
        $prevRevenue = (int) OrderItem::whereHas('order', function ($q) use ($prevWeekStart, $prevWeekEnd) {
                $q->where('status', 'delivered')
                  ->whereBetween('created_at', [$prevWeekStart, $prevWeekEnd]);
            })
            ->whereHas('product', fn($q) => $q->where('umkm_id', $umkmId))
            ->sum(DB::raw('subtotal'));

        // Order count minggu ini
        $currentOrders = (int) Order::whereHas('items.product', fn($q) => $q->where('umkm_id', $umkmId))
            ->where('status', 'delivered')
            ->whereBetween('created_at', [$currentWeekStart, $currentWeekEnd])
            ->count();

        // Order count minggu lalu
        $prevOrders = (int) Order::whereHas('items.product', fn($q) => $q->where('umkm_id', $umkmId))
            ->where('status', 'delivered')
            ->whereBetween('created_at', [$prevWeekStart, $prevWeekEnd])
            ->count();

        // Hitung persentase perubahan
        $revenueChange = $prevRevenue > 0
            ? round((($currentRevenue - $prevRevenue) / $prevRevenue) * 100, 1)
            : ($currentRevenue > 0 ? 100 : 0);

        $ordersChange = $prevOrders > 0
            ? round((($currentOrders - $prevOrders) / $prevOrders) * 100, 1)
            : ($currentOrders > 0 ? 100 : 0);

        return response()->json([
            'success' => true,
            'data' => [
                'current_week' => [
                    'revenue' => $currentRevenue,
                    'orders'  => $currentOrders,
                    'start'   => $currentWeekStart->toDateString(),
                    'end'     => $currentWeekEnd->toDateString(),
                ],
                'previous_week' => [
                    'revenue' => $prevRevenue,
                    'orders'  => $prevOrders,
                    'start'   => $prevWeekStart->toDateString(),
                    'end'     => $prevWeekEnd->toDateString(),
                ],
                'revenue_change' => $revenueChange,
                'orders_change'  => $ordersChange,
                'revenue_trend'  => $revenueChange >= 0 ? 'up' : 'down',
                'orders_trend'   => $ordersChange >= 0 ? 'up' : 'down',
            ],
        ]);
    }

    /**
     * GET /api/umkm/analytics/sales — Grafik penjualan harian/mingguan/bulanan
     * F-06: Grafik penjualan dengan periode
     */
    public function salesChart(Request $request)
    {
        $umkm = auth()->user()->umkm;
        if (!$umkm) {
            return response()->json(['success' => false, 'message' => 'Toko UMKM tidak ditemukan.'], 403);
        }

        $umkmId = $umkm->id;
        $period = $request->period ?? 'daily'; // daily | weekly | monthly
        $daysBack = $request->days ?? 30;

        switch ($period) {
            case 'weekly':
                $selectDate = DB::raw("DATE_FORMAT(orders.created_at, '%Y-%u') as period");
                $groupBy = 'period';
                break;
            case 'monthly':
                $selectDate = DB::raw("DATE_FORMAT(orders.created_at, '%Y-%m') as period");
                $groupBy = 'period';
                break;
            default: // daily
                $selectDate = DB::raw("DATE(orders.created_at) as period");
                $groupBy = 'period';
                break;
        }

        $salesData = OrderItem::select(
                $selectDate,
                DB::raw('SUM(order_items.subtotal) as total'),
                DB::raw('COUNT(DISTINCT orders.id) as order_count')
            )
            ->join('orders', 'orders.id', '=', 'order_items.order_id')
            ->whereHas('product', fn($q) => $q->where('umkm_id', $umkmId))
            ->where('orders.status', 'delivered')
            ->where('orders.created_at', '>=', now()->subDays($daysBack))
            ->groupBy($groupBy)
            ->orderBy('period', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'period'  => $period,
                'days'    => $daysBack,
                'records' => $salesData,
            ],
        ]);
    }
}