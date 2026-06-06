<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UmkmProfileResource;
use App\Models\UmkmProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UmkmController extends Controller
{
    /**
     * Get nearby UMKM for map
     */
    public function nearby(Request $request): JsonResponse
    {
        $latitude = (float) $request->latitude;
        $longitude = (float) $request->longitude;
        $radius = (float) ($request->radius ?? 5); // Default 5 km

        // Validate radius (0.5 - 10 km)
        if ($radius < 0.5 || $radius > 10) {
            $radius = 5;
        }

        // Haversine formula to calculate distance
        // This is a simplified version; in production, use MySQL ST_Distance_Sphere
        $query = UmkmProfile::select('*')
            ->selectRaw(
                '(6371 * acos(cos(radians(?)) * cos(radians(ST_Y(location))) * cos(radians(ST_X(location)) - radians(?)) + sin(radians(?)) * sin(radians(ST_Y(location))))) AS distance',
                [$latitude, $longitude, $latitude]
            )
            ->having('distance', '<=', $radius)
            ->orderBy('distance')
            ->where('verified_at', '!=', null);

        $umkms = $query->paginate(50);

        return response()->json([
            'success' => true,
            'data' => UmkmProfileResource::collection($umkms->items()),
            'pagination' => [
                'total' => $umkms->total(),
                'per_page' => $umkms->perPage(),
                'current_page' => $umkms->currentPage(),
                'last_page' => $umkms->lastPage(),
            ],
        ], 200);
    }

    /**
     * Get all verified UMKM
     */
    public function index(Request $request): JsonResponse
    {
        $query = UmkmProfile::where('verified_at', '!=', null);

        // Search by business name
        if ($request->search) {
            $query->where('business_name', 'like', '%' . $request->search . '%');
        }

        // Filter by rating
        if ($request->min_rating) {
            $query->where('rating', '>=', $request->min_rating);
        }

        $umkms = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => UmkmProfileResource::collection($umkms->items()),
            'pagination' => [
                'total' => $umkms->total(),
                'per_page' => $umkms->perPage(),
                'current_page' => $umkms->currentPage(),
                'last_page' => $umkms->lastPage(),
            ],
        ], 200);
    }

    /**
     * Get single UMKM details
     */
    public function show(UmkmProfile $umkm): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => new UmkmProfileResource($umkm),
        ], 200);
    }

    /**
     * Get UMKM analytics (for owner only)
     */
    public function analytics(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->isUmkm() || !$user->umkmProfile) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak.',
            ], 403);
        }

        $umkm = $user->umkmProfile;
        $dateRange = $request->date_range ?? 'month'; // day, week, month

        // Calculate date filter
        $startDate = match ($dateRange) {
            'day' => now()->startOfDay(),
            'week' => now()->startOfWeek(),
            'month' => now()->startOfMonth(),
            default => now()->startOfMonth(),
        };

        $endDate = now()->endOfDay();

        // Get orders in period
        $orders = $umkm->orders()
            ->whereBetween('created_at', [$startDate, $endDate])
            ->get();

        $totalRevenue = $orders->sum('total_amount');
        $totalOrders = $orders->count();
        $completedOrders = $orders->where('status', 'completed')->count();
        $totalProducts = $umkm->products()->count();
        $activeProducts = $umkm->products()->where('is_active', true)->count();

        // Get top products
        $topProducts = $umkm->products()
            ->withCount('orderItems')
            ->orderBy('order_items_count', 'desc')
            ->limit(5)
            ->get();

        // Get recent reviews
        $recentReviews = $umkm->reviews()
            ->latest()
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'umkm_id' => $umkm->id,
                'business_name' => $umkm->business_name,
                'rating' => (float) $umkm->rating,
                'total_reviews' => $umkm->total_reviews,
                'summary' => [
                    'total_revenue' => (float) $totalRevenue,
                    'total_orders' => $totalOrders,
                    'completed_orders' => $completedOrders,
                    'total_products' => $totalProducts,
                    'active_products' => $activeProducts,
                    'conversion_rate' => $totalOrders > 0 ? round(($completedOrders / $totalOrders) * 100, 2) : 0,
                ],
                'top_products' => $topProducts,
                'recent_reviews' => $recentReviews,
                'period' => [
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                    'range' => $dateRange,
                ],
            ],
        ], 200);
    }
}
