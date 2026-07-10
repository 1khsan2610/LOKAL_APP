<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Umkm;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class ProductController extends Controller
{
    /**
     * GET /api/products
     * List produk dengan filter & pagination
     */
    public function index(Request $request)
    {
        $query = Product::with(['umkm', 'images'])
            ->where('is_active', true)
            ->where('stock', '>', 0);

        // Filter kategori
        if ($request->category) {
            $query->where('category', $request->category);
        }

        // Filter harga
        if ($request->min_price) $query->where('price', '>=', $request->min_price);
        if ($request->max_price) $query->where('price', '<=', $request->max_price);

        // Filter UMKM
        if ($request->umkm_id) $query->where('umkm_id', $request->umkm_id);

        // Sort
        $sort = $request->sort ?? 'newest';
        match ($sort) {
            'price_asc'  => $query->orderBy('price', 'asc'),
            'price_desc' => $query->orderBy('price', 'desc'),
            'popular'    => $query->orderBy('sold_count', 'desc'),
            'rating'     => $query->orderBy('avg_rating', 'desc'),
            default      => $query->orderBy('created_at', 'desc'),
        };

        $products = $query->paginate($request->per_page ?? 20);

        return response()->json([
            'success' => true,
            'data'    => $products,
        ]);
    }

    /**
     * GET /api/products/search
     */
    public function search(Request $request)
    {
        $request->validate(['q' => 'required|string|min:2']);

        $products = Product::with(['umkm', 'images'])
            ->where('is_active', true)
            ->where(function ($q) use ($request) {
                $q->where('name', 'like', "%{$request->q}%")
                  ->orWhere('description', 'like', "%{$request->q}%")
                  ->orWhereHas('umkm', fn($u) => $u->where('name', 'like', "%{$request->q}%"));
            })
            ->orderBy('sold_count', 'desc')
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $products]);
    }

    /**
     * GET /api/products/flash-sale
     */
    public function flashSale()
    {
        $products = Product::with(['umkm', 'images'])
            ->where('is_active', true)
            ->where('flash_sale_price', '>', 0)
            ->where('flash_sale_ends_at', '>', now())
            ->orderBy('flash_sale_discount', 'desc')
            ->limit(20)
            ->get();

        return response()->json(['success' => true, 'data' => $products]);
    }

    /**
     * GET /api/products/{id}
     */
    public function show($id)
    {
        $product = Product::with(['umkm', 'images', 'reviews.user', 'variants'])
            ->findOrFail($id);

        return response()->json(['success' => true, 'data' => $product]);
    }

    /**
     * GET /api/umkm/products  (UMKM only — list own products)
     */
    public function myProducts(Request $request)
    {
        $umkm = Umkm::where('user_id', auth('api')->id())->first();
        if (!$umkm) {
            return response()->json([
                'success' => false,
                'message' => 'Toko UMKM Anda belum terdaftar.',
            ], 403);
        }

        $products = Product::with(['images', 'variants'])
            ->where('umkm_id', $umkm->id)
            ->where('is_active', true)
            ->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 50);

        return response()->json(['success' => true, 'data' => $products]);
    }

    /**
     * POST /api/umkm/products  (UMKM only)
     */
    public function store(Request $request)
    {
        // Validate text fields and optional images in one request
        $request->validate([
            'name'        => 'required|string|max:150',
            'description' => 'required|string',
            'price'       => 'required|numeric|min:0',
            'stock'       => 'required|integer|min:0',
            'category'    => 'required|string|max:50',
            'weight'      => 'required|numeric|min:0',
            'variants'    => 'nullable|array',
            'images'      => 'nullable|array|max:5',
            'images.*'    => 'image|mimes:jpeg,png,webp|max:5120',
        ]);

        $umkm = Umkm::where('user_id', auth('api')->id())->first();
        if (!$umkm) {
            return response()->json([
                'success' => false,
                'message' => 'Toko UMKM Anda belum terdaftar. Silakan hubungi administrator.',
            ], 403);
        }

        // Keep track of stored file paths to perform cleanup on failure
        $storedPaths = [];

        DB::beginTransaction();
        try {
            $product = Product::create([
                'umkm_id'     => $umkm->id,
                'name'        => $request->name,
                'slug'        => Str::slug($request->name) . '-' . Str::random(6),
                'description' => $request->description,
                'price'       => $request->price,
                'stock'       => $request->stock,
                'category'    => $request->category,
                'weight'      => $request->weight,
                'is_active'   => true,
            ]);

            // Create variants if provided
            if ($request->variants) {
                foreach ($request->variants as $variant) {
                    $product->variants()->create([
                        'name'  => $variant['name'],
                        'value' => $variant['value'],
                        'price_modifier' => $variant['price_modifier'] ?? 0,
                        'stock' => $variant['stock'] ?? 0,
                    ]);
                }
            }

            // Handle uploaded images (support both 'images' and 'images[]' form names)
            $incomingFiles = $request->allFiles();
            $files = $incomingFiles['images'] ?? $incomingFiles['images[]'] ?? null;
            if (!empty($files)) {
                if (!is_array($files)) {
                    $files = [$files];
                }

                $disk = app()->environment('production') ? 's3' : 'public';
                $isFirst = $product->images()->count() === 0;

                foreach ($files as $image) {
                    // store file
                    $path = $image->store("products/{$product->id}", $disk);
                    $storedPaths[] = $path;

                    $productImage = $product->images()->create([
                        'url'    => Storage::disk($disk)->url($path),
                        'is_primary' => $isFirst,
                    ]);

                    if ($isFirst) $isFirst = false;
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Produk berhasil ditambahkan.',
                'data'    => $product->fresh()->load('variants', 'images'),
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();

            // Attempt to cleanup stored files to avoid orphaned files
            try {
                $disk = app()->environment('production') ? 's3' : 'public';
                if (!empty($storedPaths)) {
                    foreach ($storedPaths as $p) {
                        Storage::disk($disk)->delete($p);
                    }
                }
            } catch (\Exception $_) {
                // ignore cleanup failures
            }

            return response()->json([
                'success' => false,
                'message' => 'Gagal menambahkan produk: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * PUT /api/umkm/products/{id}  (UMKM only)
     */
    /**
     * PUT /api/umkm/products/{id}  (UMKM only)
     *
     * NOTE: For multipart/form-data uploads the frontend MUST send a POST request
     * with `_method=PUT` (HTTP method spoofing) because browsers/clients may not
     * properly send multipart bodies with real PUT requests and Laravel may not
     * populate files. Use POST + `_method=PUT` when uploading images.
     */
    public function update(Request $request, $id)
    {
        // Validate allowed fields and optional images
        $request->validate([
            'name'        => 'sometimes|string|max:150',
            'description' => 'sometimes|string',
            'price'       => 'sometimes|numeric|min:0',
            'stock'       => 'sometimes|integer|min:0',
            'category'    => 'sometimes|string|max:50',
            'weight'      => 'sometimes|numeric|min:0',
            'is_active'   => 'sometimes|boolean',
            'images'      => 'nullable|array|max:5',
            'images.*'    => 'image|mimes:jpeg,png,webp|max:5120',
        ]);

        $umkm = Umkm::where('user_id', auth('api')->id())->first();
        if (!$umkm) {
            return response()->json([
                'success' => false,
                'message' => 'Toko UMKM Anda belum terdaftar. Silakan hubungi administrator.',
            ], 403);
        }

        $product = Product::where('umkm_id', $umkm->id)->find($id);
        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Produk tidak ditemukan atau bukan milik toko Anda.',
            ], 404);
        }

        DB::beginTransaction();
        try {
            // Update basic fields
            $product->update($request->only([
                'name', 'description', 'price', 'stock',
                'category', 'weight', 'is_active',
            ]));

            // Handle uploaded images (support both 'images' and 'images[]' form names)
            $incomingFiles = $request->allFiles();
            $files = $incomingFiles['images'] ?? $incomingFiles['images[]'] ?? null;

            if (!empty($files)) {
                if (!is_array($files)) {
                    $files = [$files];
                }

                $disk = app()->environment('production') ? 's3' : 'public';

                // Remove existing files from storage for this product to avoid orphaned files
                try {
                    Storage::disk($disk)->deleteDirectory("products/{$product->id}");
                } catch (\Exception $_) {
                    // ignore storage deletion errors
                }

                // Remove existing DB records for images
                $product->images()->delete();

                $isFirst = true;
                foreach ($files as $image) {
                    $path = $image->store("products/{$product->id}", $disk);
                    $product->images()->create([
                        'url' => Storage::disk($disk)->url($path),
                        'is_primary' => $isFirst,
                    ]);
                    if ($isFirst) $isFirst = false;
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Produk berhasil diperbarui.',
                'data'    => $product->fresh()->load('variants', 'images'),
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui produk: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * GET /api/umkm/products/{id}  (UMKM only — single own product)
     */
    public function myProductDetail($id)
    {
        $umkm = Umkm::where('user_id', auth('api')->id())->first();
        if (!$umkm) {
            return response()->json(['success' => false, 'message' => 'Toko UMKM Anda belum terdaftar.'], 403);
        }

        $product = Product::with(['images', 'variants'])->where('umkm_id', $umkm->id)->find($id);
        if (!$product) {
            return response()->json(['success' => false, 'message' => 'Produk tidak ditemukan.'], 404);
        }

        return response()->json(['success' => true, 'data' => $product]);
    }

    /**
     * DELETE /api/umkm/products/{productId}/images/{imageId}  (UMKM only)
     */
    public function deleteImage($productId, $imageId)
    {
        $umkm = Umkm::where('user_id', auth('api')->id())->first();
        if (!$umkm) {
            return response()->json(['success' => false, 'message' => 'Toko UMKM Anda belum terdaftar.'], 403);
        }

        $product = Product::where('umkm_id', $umkm->id)->find($productId);
        if (!$product) {
            return response()->json(['success' => false, 'message' => 'Produk tidak ditemukan.'], 404);
        }

        $image = $product->images()->find($imageId);
        if (!$image) {
            return response()->json(['success' => false, 'message' => 'Gambar tidak ditemukan.'], 404);
        }

        // Delete file from storage
        $disk = app()->environment('production') ? 's3' : 'public';
        $relativePath = str_replace(Storage::disk($disk)->url(''), '', $image->url);
        Storage::disk($disk)->delete($relativePath);

        $image->delete();

        return response()->json(['success' => true, 'message' => 'Gambar berhasil dihapus.']);
    }

    /**
     * DELETE /api/umkm/products/{id}  (UMKM only)
     */
    public function destroy($id)
    {
        $umkm = Umkm::where('user_id', auth('api')->id())->first();
        if (!$umkm) {
            return response()->json([
                'success' => false,
                'message' => 'Toko UMKM Anda belum terdaftar. Silakan hubungi administrator.',
            ], 403);
        }

        $product = Product::where('umkm_id', $umkm->id)->find($id);
        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Produk tidak ditemukan atau bukan milik toko Anda.',
            ], 404);
        }

        $product->update(['is_active' => false]);

        return response()->json(['success' => true, 'message' => 'Produk berhasil dihapus.']);
    }

    /**
     * POST /api/umkm/products/{id}/images  (UMKM only)
     */
    public function uploadImages(Request $request, $id)
    {
        $incomingFiles = $request->allFiles();
        $files = $incomingFiles['images'] ?? $incomingFiles['images[]'] ?? null;

        if (empty($files)) {
            return response()->json([
                'success' => false,
                'message' => 'Gambar produk wajib diupload.',
            ], 422);
        }

        if (!is_array($files)) {
            $files = [$files];
        }

        $request->merge(['images' => $files]);

        $request->validate([
            'images'   => 'required|array|max:5',
            'images.*' => 'image|mimes:jpeg,png,webp|max:5120',
        ]);

        $umkm = Umkm::where('user_id', auth('api')->id())->first();
        if (!$umkm) {
            return response()->json([
                'success' => false,
                'message' => 'Toko UMKM Anda belum terdaftar. Silakan hubungi administrator.',
            ], 403);
        }

        $product = Product::where('umkm_id', $umkm->id)->find($id);
        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Produk tidak ditemukan atau bukan milik toko Anda.',
            ], 404);
        }

        $uploaded = [];
        $uploadErrors = [];
        
        foreach ($request->file('images') as $image) {
            try {
                // Use 'public' disk for development, which serves from storage/app/public
                // This is more reliable than S3 in development environments
                $disk = app()->environment('production') ? 's3' : 'public';
                $path = $image->store("products/{$product->id}", $disk);
                $productImage = $product->images()->create([
                    'url'    => Storage::disk($disk)->url($path),
                    'is_primary' => $product->images()->count() === 0,
                ]);
                $uploaded[] = $productImage;
            } catch (\Exception $e) {
                $uploadErrors[] = $image->getClientOriginalName() . ': ' . $e->getMessage();
            }
        }

        if (empty($uploaded) && !empty($uploadErrors)) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal upload semua gambar: ' . implode(', ', $uploadErrors),
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => count($uploaded) . ' gambar berhasil diupload.',
            'data'    => $uploaded,
        ]);
    }
}
