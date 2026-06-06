<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Product\CreateProductRequest;
use App\Http\Requests\Product\UpdateProductRequest;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use App\Models\ProductImage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ProductController extends Controller
{
    /**
     * Get all products with filters
     */
    public function index(Request $request): JsonResponse
    {
        $query = Product::with('images', 'umkm')->where('is_active', true);

        // Filter by category
        if ($request->category) {
            $query->where('category', $request->category);
        }

        // Filter by UMKM
        if ($request->umkm_id) {
            $query->where('umkm_id', $request->umkm_id);
        }

        // Price range filter
        if ($request->min_price) {
            $query->where('price', '>=', $request->min_price);
        }
        if ($request->max_price) {
            $query->where('price', '<=', $request->max_price);
        }

        // Search by name or description
        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', '%' . $request->search . '%')
                    ->orWhere('description', 'like', '%' . $request->search . '%');
            });
        }

        // Rating filter
        if ($request->min_rating) {
            $query->where('rating', '>=', $request->min_rating);
        }

        // Pagination
        $perPage = $request->per_page ?? 20;
        $products = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => ProductResource::collection($products->items()),
            'pagination' => [
                'total' => $products->total(),
                'per_page' => $products->perPage(),
                'current_page' => $products->currentPage(),
                'last_page' => $products->lastPage(),
            ],
        ], 200);
    }

    /**
     * Get single product
     */
    public function show(Product $product): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => new ProductResource($product),
        ], 200);
    }

    /**
     * Create product (UMKM only)
     */
    public function store(CreateProductRequest $request): JsonResponse
    {
        $user = Auth::user();

        if (!$user->isUmkm() || !$user->umkmProfile?->isVerified()) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya UMKM terverifikasi yang dapat membuat produk.',
            ], 403);
        }

        $product = Product::create([
            'umkm_id' => $user->umkmProfile->id,
            'name' => $request->name,
            'description' => $request->description,
            'category' => $request->category,
            'price' => $request->price,
            'cost_price' => $request->cost_price,
            'stock' => $request->stock,
            'weight' => $request->weight,
            'attributes' => $request->attributes,
        ]);

        // Handle product images
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $index => $image) {
                $path = $image->store('products', 'public');
                ProductImage::create([
                    'product_id' => $product->id,
                    'image_url' => url('storage/' . $path),
                    'sort_order' => $index,
                ]);
            }
        }

        // Update UMKM product count
        $user->umkmProfile->increment('total_products');

        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil dibuat.',
            'data' => new ProductResource($product),
        ], 201);
    }

    /**
     * Update product
     */
    public function update(UpdateProductRequest $request, Product $product): JsonResponse
    {
        $user = Auth::user();

        if ($product->umkm_id !== $user->umkmProfile?->id) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki akses untuk mengubah produk ini.',
            ], 403);
        }

        $product->update($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil diperbarui.',
            'data' => new ProductResource($product),
        ], 200);
    }

    /**
     * Delete product
     */
    public function destroy(Product $product): JsonResponse
    {
        $user = Auth::user();

        if ($product->umkm_id !== $user->umkmProfile?->id) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki akses untuk menghapus produk ini.',
            ], 403);
        }

        $product->delete();
        $user->umkmProfile->decrement('total_products');

        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil dihapus.',
        ], 200);
    }

    /**
     * Get products by category
     */
    public function byCategory(string $category): JsonResponse
    {
        $products = Product::where('category', $category)
            ->where('is_active', true)
            ->with('images', 'umkm')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => ProductResource::collection($products->items()),
            'pagination' => [
                'total' => $products->total(),
                'per_page' => $products->perPage(),
                'current_page' => $products->currentPage(),
                'last_page' => $products->lastPage(),
            ],
        ], 200);
    }

    /**
     * Get products for specific UMKM
     */
    public function byUmkm(int $umkmId): JsonResponse
    {
        $products = Product::where('umkm_id', $umkmId)
            ->where('is_active', true)
            ->with('images')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => ProductResource::collection($products->items()),
            'pagination' => [
                'total' => $products->total(),
                'per_page' => $products->perPage(),
                'current_page' => $products->currentPage(),
                'last_page' => $products->lastPage(),
            ],
        ], 200);
    }
}
