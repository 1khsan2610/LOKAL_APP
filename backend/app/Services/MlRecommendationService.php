<?php

namespace App\Services;

use App\Models\Product;
use App\Models\PriceRecommendation;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MlRecommendationService
{
    protected string $mlServiceUrl;
    protected int $mlServiceTimeout;
    protected string $mlServiceApiKey;

    public function __construct()
    {
        $this->mlServiceUrl = config('services.ml.url', 'http://ml-service:8000');
        $this->mlServiceTimeout = config('services.ml.timeout', 30);
        $this->mlServiceApiKey = config('services.ml.api_key', '');
    }

    /**
     * Get price recommendation for a product from ML service
     * Async operation that stores results in database
     */
    public function getPriceRecommendation(Product $product, float $latitude = 0, float $longitude = 0): array
    {
        try {
            // Check if we already have a recent recommendation
            $cached = PriceRecommendation::where('product_id', $product->id)
                ->where('created_at', '>', now()->subHours(24))
                ->latest()
                ->first();

            if ($cached && $cached->status === PriceRecommendation::STATUS_COMPLETED) {
                return [
                    'success' => true,
                    'source' => 'cached',
                    'data' => [
                        'product_id' => $product->id,
                        'current_price' => (float) $product->price,
                        'recommended_price' => (float) $cached->recommended_price,
                        'confidence' => (float) $cached->confidence_score,
                        'reason' => $cached->recommendation_reason,
                        'market_analysis' => json_decode($cached->market_analysis, true),
                        'competitive_products' => json_decode($cached->competitive_products, true),
                    ],
                ];
            }

            // Prepare request data
            $requestData = [
                'product_id' => $product->id,
                'product_name' => $product->name,
                'category' => $product->category,
                'current_price' => (float) $product->price,
                'cost_price' => (float) ($product->cost_price ?? $product->price * 0.6),
                'stock' => $product->stock,
                'rating' => (float) $product->rating,
                'total_reviews' => $product->total_reviews,
                'total_sold' => $product->total_sold,
                'umkm_id' => $product->umkm_id,
                'latitude' => (float) $latitude,
                'longitude' => (float) $longitude,
                'radius_km' => 5, // Analyze products within 5km radius
            ];

            // Call ML service
            $response = $this->callMlService('POST', '/api/price-recommendation', $requestData);

            if (!$response['success']) {
                // Log error but don't fail - graceful degradation
                Log::warning('ML Service recommendation failed', [
                    'product_id' => $product->id,
                    'error' => $response['error'] ?? 'Unknown error',
                ]);

                return [
                    'success' => false,
                    'source' => 'ml_service_error',
                    'message' => 'Layanan rekomendasi harga sedang tidak tersedia',
                    'data' => null,
                ];
            }

            $mlData = $response['data'];

            // Store recommendation in database
            $recommendation = PriceRecommendation::create([
                'product_id' => $product->id,
                'umkm_id' => $product->umkm_id,
                'ml_request_data' => json_encode($requestData),
                'ml_response_data' => json_encode($mlData),
                'current_price' => (float) $product->price,
                'recommended_price' => (float) $mlData['recommended_price'],
                'confidence_score' => (float) ($mlData['confidence'] ?? 0),
                'recommendation_reason' => $mlData['reason'] ?? 'Berdasarkan analisis pasar lokal',
                'market_analysis' => json_encode($mlData['market_analysis'] ?? []),
                'competitive_products' => json_encode($mlData['competitive_products'] ?? []),
                'status' => PriceRecommendation::STATUS_COMPLETED,
            ]);

            return [
                'success' => true,
                'source' => 'ml_service',
                'data' => [
                    'product_id' => $product->id,
                    'current_price' => (float) $product->price,
                    'recommended_price' => (float) $recommendation->recommended_price,
                    'confidence' => (float) $recommendation->confidence_score,
                    'reason' => $recommendation->recommendation_reason,
                    'market_analysis' => json_decode($recommendation->market_analysis, true),
                    'competitive_products' => json_decode($recommendation->competitive_products, true),
                ],
            ];
        } catch (\Exception $e) {
            Log::error('ML Recommendation Service Error', [
                'product_id' => $product->id,
                'exception' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return [
                'success' => false,
                'source' => 'exception',
                'message' => 'Terjadi kesalahan dalam sistem rekomendasi harga',
                'data' => null,
            ];
        }
    }

    /**
     * Trigger async price recommendation analysis
     * Returns immediately with request ID for polling
     */
    public function triggerAsyncRecommendation(Product $product, float $latitude = 0, float $longitude = 0): array
    {
        try {
            // Check if analysis already pending
            $pending = PriceRecommendation::where('product_id', $product->id)
                ->where('status', PriceRecommendation::STATUS_PENDING)
                ->latest()
                ->first();

            if ($pending && $pending->created_at->diffInMinutes(now()) < 5) {
                return [
                    'success' => true,
                    'message' => 'Analisis harga sudah dalam proses',
                    'request_id' => $pending->id,
                    'status' => PriceRecommendation::STATUS_PENDING,
                ];
            }

            $requestData = [
                'product_id' => $product->id,
                'product_name' => $product->name,
                'category' => $product->category,
                'current_price' => (float) $product->price,
                'cost_price' => (float) ($product->cost_price ?? $product->price * 0.6),
                'stock' => $product->stock,
                'rating' => (float) $product->rating,
                'total_reviews' => $product->total_reviews,
                'total_sold' => $product->total_sold,
                'umkm_id' => $product->umkm_id,
                'latitude' => (float) $latitude,
                'longitude' => (float) $longitude,
                'radius_km' => 5,
                'async' => true, // Request async processing
            ];

            // Call ML service async endpoint
            $response = $this->callMlService('POST', '/api/price-recommendation/async', $requestData);

            if (!$response['success']) {
                Log::warning('ML Service async trigger failed', [
                    'product_id' => $product->id,
                    'error' => $response['error'] ?? 'Unknown error',
                ]);

                return [
                    'success' => false,
                    'message' => 'Gagal memulai analisis harga',
                    'data' => null,
                ];
            }

            // Create pending recommendation record
            $recommendation = PriceRecommendation::create([
                'product_id' => $product->id,
                'umkm_id' => $product->umkm_id,
                'ml_request_data' => json_encode($requestData),
                'status' => PriceRecommendation::STATUS_PENDING,
                'external_request_id' => $response['data']['request_id'] ?? null,
            ]);

            return [
                'success' => true,
                'message' => 'Analisis harga dimulai',
                'request_id' => $recommendation->id,
                'status' => PriceRecommendation::STATUS_PENDING,
            ];
        } catch (\Exception $e) {
            Log::error('ML Async Recommendation Error', [
                'product_id' => $product->id,
                'exception' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'message' => 'Terjadi kesalahan dalam sistem rekomendasi',
                'data' => null,
            ];
        }
    }

    /**
     * Get recommendation status for async request
     */
    public function getRecommendationStatus(int $requestId): array
    {
        try {
            $recommendation = PriceRecommendation::find($requestId);

            if (!$recommendation) {
                return [
                    'success' => false,
                    'message' => 'Permintaan analisis tidak ditemukan',
                ];
            }

            // If completed, return data
            if ($recommendation->status === PriceRecommendation::STATUS_COMPLETED) {
                return [
                    'success' => true,
                    'status' => PriceRecommendation::STATUS_COMPLETED,
                    'data' => [
                        'product_id' => $recommendation->product_id,
                        'current_price' => (float) $recommendation->current_price,
                        'recommended_price' => (float) $recommendation->recommended_price,
                        'confidence' => (float) $recommendation->confidence_score,
                        'reason' => $recommendation->recommendation_reason,
                        'market_analysis' => json_decode($recommendation->market_analysis, true),
                        'competitive_products' => json_decode($recommendation->competitive_products, true),
                    ],
                ];
            }

            // If pending, check with ML service if available
            if ($recommendation->status === PriceRecommendation::STATUS_PENDING && $recommendation->external_request_id) {
                $response = $this->callMlService('GET', '/api/price-recommendation/status/' . $recommendation->external_request_id);

                if ($response['success'] && isset($response['data']['status']) && $response['data']['status'] === 'completed') {
                    // Update with results
                    $mlData = $response['data'];
                    $recommendation->update([
                        'ml_response_data' => json_encode($mlData),
                        'recommended_price' => (float) $mlData['recommended_price'],
                        'confidence_score' => (float) ($mlData['confidence'] ?? 0),
                        'recommendation_reason' => $mlData['reason'] ?? 'Berdasarkan analisis pasar lokal',
                        'market_analysis' => json_encode($mlData['market_analysis'] ?? []),
                        'competitive_products' => json_encode($mlData['competitive_products'] ?? []),
                        'status' => PriceRecommendation::STATUS_COMPLETED,
                    ]);

                    return [
                        'success' => true,
                        'status' => PriceRecommendation::STATUS_COMPLETED,
                        'data' => [
                            'product_id' => $recommendation->product_id,
                            'current_price' => (float) $recommendation->current_price,
                            'recommended_price' => (float) $recommendation->recommended_price,
                            'confidence' => (float) $recommendation->confidence_score,
                            'reason' => $recommendation->recommendation_reason,
                            'market_analysis' => json_decode($recommendation->market_analysis, true),
                            'competitive_products' => json_decode($recommendation->competitive_products, true),
                        ],
                    ];
                }
            }

            return [
                'success' => true,
                'status' => PriceRecommendation::STATUS_PENDING,
                'message' => 'Analisis masih dalam proses',
            ];
        } catch (\Exception $e) {
            Log::error('ML Recommendation Status Error', [
                'request_id' => $requestId,
                'exception' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'message' => 'Gagal mengambil status rekomendasi',
            ];
        }
    }

    /**
     * Call ML service with proper error handling
     */
    protected function callMlService(string $method, string $endpoint, array $data = []): array
    {
        try {
            $headers = [
                'Accept' => 'application/json',
                'Content-Type' => 'application/json',
            ];

            if ($this->mlServiceApiKey) {
                $headers['X-API-Key'] = $this->mlServiceApiKey;
            }

            $url = rtrim($this->mlServiceUrl, '/') . $endpoint;

            $response = match ($method) {
                'GET' => Http::timeout($this->mlServiceTimeout)
                    ->withHeaders($headers)
                    ->get($url),
                'POST' => Http::timeout($this->mlServiceTimeout)
                    ->withHeaders($headers)
                    ->post($url, $data),
                default => throw new \Exception('Invalid HTTP method'),
            };

            if (!$response->successful()) {
                Log::warning('ML Service HTTP Error', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                    'url' => $url,
                ]);

                return [
                    'success' => false,
                    'error' => "ML Service returned status {$response->status()}",
                ];
            }

            $result = $response->json();

            if (!isset($result['success']) || !$result['success']) {
                return [
                    'success' => false,
                    'error' => $result['error'] ?? 'ML Service returned error',
                    'data' => $result['data'] ?? null,
                ];
            }

            return [
                'success' => true,
                'data' => $result['data'] ?? $result,
            ];
        } catch (\Exception $e) {
            Log::error('ML Service Connection Error', [
                'url' => $this->mlServiceUrl,
                'exception' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => 'Tidak dapat terhubung ke layanan rekomendasi harga: ' . $e->getMessage(),
            ];
        }
    }

    /**
     * Get recommendations for UMKM products
     */
    public function getUmkmProductRecommendations(int $umkmId, ?float $latitude = null, ?float $longitude = null): array
    {
        try {
            $products = Product::where('umkm_id', $umkmId)
                ->active()
                ->limit(10)
                ->get();

            $recommendations = [];

            foreach ($products as $product) {
                $result = $this->getPriceRecommendation($product, $latitude ?? 0, $longitude ?? 0);
                if ($result['success']) {
                    $recommendations[] = $result['data'];
                }
            }

            return [
                'success' => true,
                'data' => $recommendations,
                'count' => count($recommendations),
            ];
        } catch (\Exception $e) {
            Log::error('UMKM Recommendations Error', [
                'umkm_id' => $umkmId,
                'exception' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'message' => 'Gagal mengambil rekomendasi produk UMKM',
                'data' => [],
            ];
        }
    }
}
