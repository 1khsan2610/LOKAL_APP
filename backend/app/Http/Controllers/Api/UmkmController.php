<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UmkmNearbyResource;
use App\Http\Resources\UmkmProfileResource;
use App\Models\UmkmProfile;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
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
     * Get UMKM analytics dashboard (REQ-F06-01, REQ-F06-02, REQ-F06-03)
     * 
     * Endpoint: GET /umkm/analytics/summary?period=daily|weekly|monthly&start=YYYY-MM-DD&end=YYYY-MM-DD
     * 
     * Returns:
     * - Total revenue, growth %, orders, new customers, avg rating (REQ-F06-02)
     * - Support period + custom date range (REQ-F06-03)
     * - Redis cache for performance (< 5 min update delay) (REQ-F06-01)
     * - Verified UMKM only with Bearer token (REQ-F06-03)
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function analytics(Request $request): JsonResponse
    {
        // Verify UMKM authentication (Bearer token + UMKM role)
        $user = $request->user();
        
        if (!$user || !$user->isUmkm() || !$user->umkmProfile) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Hanya akun UMKM terverifikasi yang dapat mengakses.',
            ], 403);
        }

        $umkm = $user->umkmProfile;
        
        // Validate UMKM verification status
        if (!$umkm->isVerified()) {
            return response()->json([
                'success' => false,
                'message' => 'UMKM belum terverifikasi.',
            ], 403);
        }

        // Parse period parameter: daily, weekly, monthly (default: month)
        $period = $request->query('period', 'monthly');
        
        // Validate period
        if (!in_array($period, ['daily', 'weekly', 'monthly'])) {
            return response()->json([
                'success' => false,
                'message' => 'Period parameter harus: daily, weekly, atau monthly.',
            ], 422);
        }

        // Parse custom date range (optional)
        $startDate = null;
        $endDate = null;
        
        if ($request->has('start') && $request->has('end')) {
            try {
                $startDate = Carbon::createFromFormat('Y-m-d', $request->query('start'))->startOfDay();
                $endDate = Carbon::createFromFormat('Y-m-d', $request->query('end'))->endOfDay();
                
                // Validate date range
                if ($startDate > $endDate) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Start date tidak boleh lebih besar dari end date.',
                    ], 422);
                }
            } catch (\Exception $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Format tanggal tidak valid. Gunakan format YYYY-MM-DD.',
                ], 422);
            }
        } else {
            // Calculate date range from period
            $now = now();
            $endDate = $now->endOfDay();
            
            $startDate = match ($period) {
                'daily' => $now->clone()->startOfDay(),
                'weekly' => $now->clone()->startOfWeek(),
                'monthly' => $now->clone()->startOfMonth(),
                default => $now->clone()->startOfMonth(),
            };
        }

        // Generate cache key (REQ-F06-01: < 5 min update delay)
        $cacheKey = "umkm_analytics:{$umkm->id}:{$period}:{$startDate->format('Y-m-d')}:{$endDate->format('Y-m-d')}";
        
        // Try to get from cache (5 minute TTL)
        if (Cache::has($cacheKey)) {
            return response()->json(Cache::get($cacheKey), 200);
        }

        try {
            // Get orders in current period
            $orders = $umkm->orders()
                ->whereBetween('created_at', [$startDate, $endDate])
                ->get();

            // Calculate previous period for growth percentage
            $periodLength = $startDate->diffInDays($endDate) + 1;
            $prevStartDate = $startDate->clone()->subDays($periodLength);
            $prevEndDate = $startDate->clone()->subDay();

            $prevOrders = $umkm->orders()
                ->whereBetween('created_at', [$prevStartDate, $prevEndDate])
                ->get();

            // Calculate metrics
            $totalRevenue = (float) $orders->sum('total_amount');
            $prevRevenue = (float) $prevOrders->sum('total_amount');
            $growthPercentage = $prevRevenue > 0 
                ? round((($totalRevenue - $prevRevenue) / $prevRevenue) * 100, 2)
                : ($totalRevenue > 0 ? 100 : 0);

            $totalOrders = $orders->count();
            $completedOrders = $orders->where('status', 'completed')->count();
            $completionRate = $totalOrders > 0 ? round(($completedOrders / $totalOrders) * 100, 2) : 0;

            // Get new customers in this period
            $newCustomerIds = $orders->pluck('consumer_id')->unique();
            $newCustomersCount = $orders
                ->whereIn('consumer_id', $newCustomerIds)
                ->groupBy('consumer_id')
                ->count();

            // Calculate average rating from reviews in this period
            $avgRating = $umkm->reviews()
                ->whereBetween('created_at', [$startDate, $endDate])
                ->avg('rating');
            $avgRating = $avgRating ? round($avgRating, 2) : (float) $umkm->rating;

            // Get top products sold in this period (REQ-F06-02)
            $topProducts = $umkm->products()
                ->with(['orderItems' => function ($query) use ($startDate, $endDate) {
                    $query->whereHas('order', function ($q) use ($startDate, $endDate) {
                        $q->whereBetween('created_at', [$startDate, $endDate]);
                    });
                }])
                ->get()
                ->map(function ($product) {
                    return [
                        'id' => $product->id,
                        'name' => $product->name,
                        'price' => (float) $product->price,
                        'sold' => $product->orderItems->count(),
                        'revenue' => (float) $product->orderItems->sum(function ($item) {
                            return $item->quantity * $item->unit_price;
                        }),
                    ];
                })
                ->sortByDesc('sold')
                ->take(5)
                ->values();

            // Generate chart data for visualization
            $chartData = $this->generateChartData($umkm, $startDate, $endDate, $period);

            // Build response
            $response = [
                'success' => true,
                'data' => [
                    'umkm_id' => $umkm->id,
                    'business_name' => $umkm->business_name,
                    'summary' => [
                        'total_revenue' => $totalRevenue,
                        'growth_percentage' => $growthPercentage,
                        'total_orders' => $totalOrders,
                        'completed_orders' => $completedOrders,
                        'completion_rate' => $completionRate,
                        'new_customers' => $newCustomersCount,
                        'avg_rating' => $avgRating,
                    ],
                    'top_products' => $topProducts,
                    'chart_data' => $chartData,
                    'period' => [
                        'type' => $period,
                        'start_date' => $startDate->format('Y-m-d'),
                        'end_date' => $endDate->format('Y-m-d'),
                    ],
                ],
            ];

            // Cache the response for 5 minutes (REQ-F06-01)
            Cache::put($cacheKey, $response, now()->addMinutes(5));

            return response()->json($response, 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data analytics.',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    /**
     * Generate chart data for visualization
     * 
     * Returns daily/weekly breakdown for line chart and product sales for bar chart
     * 
     * @param UmkmProfile $umkm
     * @param Carbon $startDate
     * @param Carbon $endDate
     * @param string $period
     * @return array
     */
    private function generateChartData(UmkmProfile $umkm, Carbon $startDate, Carbon $endDate, string $period): array
    {
        $revenueByDay = [];
        $ordersByDay = [];
        
        // Generate daily breakdown
        $currentDate = $startDate->clone();
        while ($currentDate <= $endDate) {
            $dayStart = $currentDate->clone()->startOfDay();
            $dayEnd = $currentDate->clone()->endOfDay();
            
            $dayRevenue = $umkm->orders()
                ->whereBetween('created_at', [$dayStart, $dayEnd])
                ->sum('total_amount');
            
            $dayOrders = $umkm->orders()
                ->whereBetween('created_at', [$dayStart, $dayEnd])
                ->count();
            
            $dateLabel = $currentDate->format('Y-m-d');
            
            $revenueByDay[] = [
                'date' => $dateLabel,
                'revenue' => (float) $dayRevenue,
            ];
            
            $ordersByDay[] = [
                'date' => $dateLabel,
                'orders' => $dayOrders,
            ];
            
            $currentDate->addDay();
        }

        return [
            'revenue_daily' => $revenueByDay,
            'orders_daily' => $ordersByDay,
        ];
    }
}
