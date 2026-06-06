<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Review\CreateReviewRequest;
use App\Http\Resources\ReviewResource;
use App\Models\Review;
use App\Services\LokalCoinService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    protected LokalCoinService $lokalCoinService;

    public function __construct(LokalCoinService $lokalCoinService)
    {
        $this->lokalCoinService = $lokalCoinService;
    }

    /**
     * Create review for product
     */
    public function store(CreateReviewRequest $request): JsonResponse
    {
        $user = $request->user();
        $order = $user->orders()->find($request->order_id);

        if (!$order || !$order->isCompleted()) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya pesanan yang selesai yang dapat diulas.',
            ], 422);
        }

        // Check if already reviewed
        $existingReview = Review::where('order_id', $order->id)
            ->where('product_id', $request->product_id)
            ->exists();

        if ($existingReview) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah memberikan ulasan untuk produk ini.',
            ], 422);
        }

        $review = Review::create([
            'order_id' => $order->id,
            'product_id' => $request->product_id,
            'consumer_id' => $user->id,
            'umkm_id' => $order->umkm_id,
            'rating' => $request->rating,
            'comment' => $request->comment,
            'is_verified_purchase' => true,
        ]);

        // Award Lokal Coin reward (5 coins)
        $this->lokalCoinService->awardReviewReward($review);

        // Update product and UMKM rating
        $review->product->updateRating();
        $review->umkm->updateRating();

        return response()->json([
            'success' => true,
            'message' => 'Ulasan berhasil dikirim. Anda mendapat 5 Lokal Coin!',
            'data' => new ReviewResource($review),
        ], 201);
    }

    /**
     * Get product reviews
     */
    public function productReviews(int $productId, Request $request): JsonResponse
    {
        $query = Review::where('product_id', $productId)
            ->with('consumer')
            ->orderBy('created_at', 'desc');

        // Filter by rating
        if ($request->rating) {
            $query->where('rating', $request->rating);
        }

        $reviews = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => ReviewResource::collection($reviews->items()),
            'pagination' => [
                'total' => $reviews->total(),
                'per_page' => $reviews->perPage(),
                'current_page' => $reviews->currentPage(),
                'last_page' => $reviews->lastPage(),
            ],
        ], 200);
    }

    /**
     * Get UMKM reviews
     */
    public function umkmReviews(int $umkmId, Request $request): JsonResponse
    {
        $query = Review::where('umkm_id', $umkmId)
            ->with('consumer', 'product')
            ->orderBy('created_at', 'desc');

        // Filter by rating
        if ($request->rating) {
            $query->where('rating', $request->rating);
        }

        $reviews = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => ReviewResource::collection($reviews->items()),
            'pagination' => [
                'total' => $reviews->total(),
                'per_page' => $reviews->perPage(),
                'current_page' => $reviews->currentPage(),
                'last_page' => $reviews->lastPage(),
            ],
        ], 200);
    }
}
