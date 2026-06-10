<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UmkmNearbyResource;
use App\Http\Resources\UmkmProfileResource;
use App\Models\UmkmProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class UmkmController extends Controller
{
    /**
     * Get nearby UMKM for map (REQ-F02-01, REQ-F02-02)
     * 
     * Query geospatial menggunakan MySQL SPATIAL index & ST_Distance_Sphere
     * Untuk performa optimal < 200ms (NF-PERF-04)
     * 
     * @param Request $request - lat (latitude), lng (longitude), radius (0.5-10 km, default 5)
     * @return JsonResponse
     */
    public function nearby(Request $request): JsonResponse
    {
        // Validate and parse request parameters
        $latitude = (float) $request->query('lat', 0);
        $longitude = (float) $request->query('lng', 0);
        $radius = (float) ($request->query('radius', 5)); // Default 5 km

        // Validate latitude and longitude
        if ($latitude < -90 || $latitude > 90 || $longitude < -180 || $longitude > 180) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid coordinates. Latitude must be -90 to 90, Longitude must be -180 to 180.',
                'data' => [],
            ], 422);
        }

        // Validate radius (0.5 - 10 km)
        if ($radius < 0.5) {
            $radius = 0.5;
        } elseif ($radius > 10) {
            $radius = 10;
        }

        try {
            // Create POINT from request coordinates
            $centerPoint = DB::raw("POINT($longitude, $latitude)");

            /**
             * Query using ST_Distance_Sphere for accurate distance calculation
             * ST_Distance_Sphere returns distance in meters, so multiply radius by 1000
             * Only return verified UMKM (verified_at is not null)
             */
            $query = UmkmProfile::select(
                'id',
                'user_id',
                'business_name',
                'business_description',
                'rating',
                'total_reviews',
                'total_products',
                'total_orders',
                'coordinates',
                'verified_at',
                'created_at',
                'updated_at'
            )
            ->selectRaw(
                '(ST_Distance_Sphere(coordinates, POINT(?, ?)) / 1000) AS distance',
                [$longitude, $latitude]
            )
            ->whereNotNull('verified_at') // Only verified UMKM
            ->whereRaw('ST_Distance_Sphere(coordinates, POINT(?, ?)) / 1000 <= ?', [$longitude, $latitude, $radius])
            ->orderBy('distance');

            // Paginate results (50 per page as per spec)
            $umkms = $query->paginate(50);

            return response()->json([
                'success' => true,
                'message' => 'Nearby UMKM retrieved successfully',
                'data' => UmkmNearbyResource::collection($umkms->items()),
                'pagination' => [
                    'total' => $umkms->total(),
                    'per_page' => $umkms->perPage(),
                    'current_page' => $umkms->currentPage(),
                    'last_page' => $umkms->lastPage(),
                ],
                'filters' => [
                    'latitude' => $latitude,
                    'longitude' => $longitude,
                    'radius_km' => $radius,
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching nearby UMKM',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error',
                'data' => [],
            ], 500);
        }
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
