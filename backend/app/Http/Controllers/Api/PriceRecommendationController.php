<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PriceRecommendation;
use App\Models\Product;
use App\Services\MlRecommendationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PriceRecommendationController extends Controller
{
    protected MlRecommendationService $mlService;

    public function __construct(MlRecommendationService $mlService)
    {
        $this->mlService = $mlService;
    }

    /**
     * Get price recommendation for a specific product (sync or async)
     */
    public function getRecommendation(Product $product, Request $request): JsonResponse
    {
        $request->validate([
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'async' => 'nullable|boolean',
        ]);

        $latitude = $request->latitude ?? 0;
        $longitude = $request->longitude ?? 0;
        $async = $request->boolean('async', false);

        // If async requested, trigger async analysis
        if ($async) {
            $result = $this->mlService->triggerAsyncRecommendation($product, $latitude, $longitude);

            if (!$result['success']) {
                return response()->json([
                    'success' => false,
                    'message' => $result['message'],
                ], 500);
            }

            return response()->json([
                'success' => true,
                'message' => $result['message'],
                'data' => [
                    'request_id' => $result['request_id'],
                    'status' => $result['status'],
                ],
            ], 202);
        }

        // Sync recommendation
        $result = $this->mlService->getPriceRecommendation($product, $latitude, $longitude);

        if (!$result['success']) {
            return response()->json([
                'success' => false,
                'message' => $result['message'],
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Rekomendasi harga berhasil diambil',
            'data' => [
                'recommendation' => $result['data'],
                'source' => $result['source'],
            ],
        ], 200);
    }

    /**
     * Get recommendation status for async request
     */
    public function getRecommendationStatus(int $requestId): JsonResponse
    {
        $result = $this->mlService->getRecommendationStatus($requestId);

        if (!$result['success']) {
            return response()->json([
                'success' => false,
                'message' => $result['message'],
            ], 404);
        }

        return response()->json([
            'success' => true,
            'status' => $result['status'],
            'data' => $result['data'] ?? null,
        ], 200);
    }

    /**
     * Get UMKM product recommendations
     */
    public function getUmkmRecommendations(Request $request): JsonResponse
    {
        $user = Auth::user();

        if (!$user->isUmkm() || !$user->umkmProfile) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya UMKM yang dapat mengakses rekomendasi produk mereka',
            ], 403);
        }

        $request->validate([
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
        ]);

        $latitude = $request->latitude;
        $longitude = $request->longitude;

        $result = $this->mlService->getUmkmProductRecommendations(
            $user->umkmProfile->id,
            $latitude,
            $longitude
        );

        return response()->json([
            'success' => $result['success'],
            'message' => $result['success'] ? 'Rekomendasi produk berhasil diambil' : $result['message'],
            'data' => [
                'recommendations' => $result['data'],
                'total' => $result['count'] ?? 0,
            ],
        ], $result['success'] ? 200 : 500);
    }

    /**
     * Get price recommendation history
     */
    public function getRecommendationHistory(Product $product, Request $request): JsonResponse
    {
        $request->validate([
            'limit' => 'nullable|integer|min:1|max:100',
            'status' => 'nullable|in:pending,processing,completed,failed',
        ]);

        $query = PriceRecommendation::where('product_id', $product->id);

        if ($request->status) {
            $query->where('status', $request->status);
        }

        $recommendations = $query
            ->orderBy('created_at', 'desc')
            ->limit($request->limit ?? 20)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $recommendations->map(function ($rec) {
                return [
                    'id' => $rec->id,
                    'product_id' => $rec->product_id,
                    'current_price' => (float) $rec->current_price,
                    'recommended_price' => (float) $rec->recommended_price,
                    'confidence' => (float) $rec->confidence_score,
                    'reason' => $rec->recommendation_reason,
                    'status' => $rec->status,
                    'created_at' => $rec->created_at,
                ];
            }),
            'total' => $recommendations->count(),
        ], 200);
    }

    /**
     * Apply recommendation (update product price)
     */
    public function applyRecommendation(PriceRecommendation $recommendation, Request $request): JsonResponse
    {
        $user = Auth::user();
        $product = $recommendation->product;

        // Verify authorization
        if ($product->umkm_id !== $user->umkmProfile?->id) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki akses untuk mengubah produk ini',
            ], 403);
        }

        // Check if recommendation is completed
        if ($recommendation->status !== PriceRecommendation::STATUS_COMPLETED) {
            return response()->json([
                'success' => false,
                'message' => 'Rekomendasi belum selesai diproses',
            ], 422);
        }

        $request->validate([
            'apply_recommendation' => 'required|boolean',
            'notes' => 'nullable|string|max:255',
        ]);

        if ($request->apply_recommendation) {
            $oldPrice = $product->price;
            $newPrice = $recommendation->recommended_price;

            // Update product price
            $product->update(['price' => $newPrice]);

            // Log the change
            \App\Models\AuditLog::create([
                'model_type' => Product::class,
                'model_id' => $product->id,
                'action' => 'price_update',
                'old_values' => ['price' => $oldPrice],
                'new_values' => ['price' => $newPrice],
                'user_id' => $user->id,
                'changes' => 'Harga diperbarui berdasarkan rekomendasi ML',
                'notes' => $request->notes,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Harga produk berhasil diperbarui',
                'data' => [
                    'product_id' => $product->id,
                    'old_price' => (float) $oldPrice,
                    'new_price' => (float) $newPrice,
                    'change_percent' => (($newPrice - $oldPrice) / $oldPrice * 100),
                ],
            ], 200);
        }

        return response()->json([
            'success' => true,
            'message' => 'Rekomendasi ditolak',
        ], 200);
    }

    /**
     * Get latest recommendation for product
     */
    public function getLatestRecommendation(Product $product): JsonResponse
    {
        $recommendation = PriceRecommendation::where('product_id', $product->id)
            ->where('status', PriceRecommendation::STATUS_COMPLETED)
            ->latest()
            ->first();

        if (!$recommendation) {
            return response()->json([
                'success' => false,
                'message' => 'Belum ada rekomendasi untuk produk ini',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $recommendation->id,
                'product_id' => $recommendation->product_id,
                'current_price' => (float) $recommendation->current_price,
                'recommended_price' => (float) $recommendation->recommended_price,
                'confidence' => (float) $recommendation->confidence_score,
                'reason' => $recommendation->recommendation_reason,
                'price_change_percent' => $recommendation->getPriceIncreasePercentage(),
                'suggests_increase' => $recommendation->suggestsPriceIncrease(),
                'high_confidence' => $recommendation->isHighConfidence(),
                'market_analysis' => json_decode($recommendation->market_analysis, true),
                'competitive_products' => json_decode($recommendation->competitive_products, true),
                'created_at' => $recommendation->created_at,
            ],
        ], 200);
    }
}
