<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Review;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReviewController extends Controller
{
    /**
     * POST /api/reviews
     * Menambahkan ulasan baru untuk produk
     */
    public function store(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'order_id'   => 'required|exists:orders,id',
            'rating'     => 'required|integer|min:1|max:5',
            'comment'    => 'nullable|string|max:1000',
            'images'     => 'nullable|array',
            'images.*'   => 'image|mimes:jpeg,png,jpg|max:2048',
        ]);

        // Pastikan order ini milik user yang sedang login
        $order = Order::where('id', $request->order_id)
                      ->where('user_id', Auth::id())
                      ->first();

        if (!$order) {
            return response()->json(['success' => false, 'message' => 'Pesanan tidak ditemukan.'], 404);
        }

        if (!in_array($order->status, ['delivered', 'shipped'], true)) {
            return response()->json(['success' => false, 'message' => 'Ulasan hanya bisa dibuat untuk pesanan yang sudah diterima atau dalam pengiriman.'], 422);
        }

        $orderHasProduct = $order->items()->where('product_id', $request->product_id)->exists();
        if (!$orderHasProduct) {
            return response()->json(['success' => false, 'message' => 'Produk ini tidak ada di pesanan Anda.'], 422);
        }

        $existingReview = Review::where('user_id', Auth::id())
            ->where('product_id', $request->product_id)
            ->where('order_id', $request->order_id)
            ->first();

        $review = Review::updateOrCreate(
            [
                'user_id'    => Auth::id(),
                'product_id' => $request->product_id,
                'order_id'   => $request->order_id,
            ],
            [
                'rating'  => $request->rating,
                'comment' => $request->comment,
                'images'  => $request->hasFile('images') ? $this->uploadImages($request->file('images')) : null,
            ]
        );

        return response()->json([
            'success' => true,
            'message' => $existingReview ? 'Ulasan berhasil diperbarui.' : 'Ulasan berhasil dikirim.',
            'data'    => $review->fresh()
        ], $existingReview ? 200 : 201);
    }

    /**
     * GET /api/reviews/me
     * Menampilkan daftar ulasan milik user yang sedang login
     */
    public function myReviews()
    {
        $reviews = Review::where('user_id', Auth::id())
            ->with('product:id,name')
            ->latest()
            ->get();

        return response()->json(['success' => true, 'data' => $reviews]);
    }

    /**
     * GET /api/products/{productId}/reviews
     * Menampilkan daftar ulasan untuk produk tertentu
     */
    public function index($productId)
    {
        $reviews = Review::where('product_id', $productId)
                         ->with('user:id,name')
                         ->latest()
                         ->paginate(10);

        return response()->json(['success' => true, 'data' => $reviews]);
    }

    /**
     * PUT /api/reviews/{id}
     * Mengubah ulasan milik sendiri
     */
    public function update(Request $request, $id)
    {
        $review = Review::where('id', $id)->where('user_id', Auth::id())->first();

        if (!$review) {
            return response()->json(['success' => false, 'message' => 'Ulasan tidak ditemukan.'], 404);
        }

        $request->validate([
            'rating'   => 'sometimes|integer|min:1|max:5',
            'comment'  => 'nullable|string|max:1000',
            'images'   => 'nullable|array',
            'images.*' => 'image|mimes:jpeg,png,jpg|max:2048',
        ]);

        $review->update($request->only(['rating', 'comment']));

        if ($request->hasFile('images')) {
            $review->update(['images' => $this->uploadImages($request->file('images'))]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Ulasan berhasil diperbarui.',
            'data'    => $review->fresh(),
        ]);
    }

    /**
     * DELETE /api/reviews/{id}
     * Menghapus ulasan milik sendiri
     */
    public function destroy($id)
    {
        $review = Review::where('id', $id)->where('user_id', Auth::id())->first();

        if (!$review) {
            return response()->json(['success' => false, 'message' => 'Ulasan tidak ditemukan.'], 404);
        }

        $review->delete();

        return response()->json(['success' => true, 'message' => 'Ulasan berhasil dihapus.']);
    }

    // Helper sederhana untuk upload gambar
    private function uploadImages($files)
    {
        $paths = [];
        foreach ($files as $file) {
            $paths[] = $file->store('reviews', 'public');
        }
        return $paths;
    }
}