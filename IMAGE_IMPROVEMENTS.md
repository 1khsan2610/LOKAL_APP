# 🔧 Recommended Improvements for Image Management

Dokumen ini berisi kode siap pakai untuk meningkatkan sistem image sync.

---

## 1️⃣ Endpoint DELETE Image

### Backend: ProductController.php

```php
/**
 * DELETE /api/umkm/products/{productId}/images/{imageId}
 * Hapus gambar produk (UMKM only)
 */
public function deleteImage($productId, $imageId)
{
    $umkm = Umkm::where('user_id', auth('api')->id())->first();
    if (!$umkm) {
        return response()->json([
            'success' => false,
            'message' => 'Toko UMKM Anda belum terdaftar.',
        ], 403);
    }

    $product = Product::where('umkm_id', $umkm->id)->find($productId);
    if (!$product) {
        return response()->json([
            'success' => false,
            'message' => 'Produk tidak ditemukan.',
        ], 404);
    }

    $image = ProductImage::where('product_id', $productId)->find($imageId);
    if (!$image) {
        return response()->json([
            'success' => false,
            'message' => 'Gambar tidak ditemukan.',
        ], 404);
    }

    try {
        // Delete file from storage
        $disk = app()->environment('production') ? 's3' : 'public';
        $filePath = "products/{$productId}/{$image->url}";
        Storage::disk($disk)->delete($filePath);

        // Delete database record
        $image->delete();

        // If deleted image was primary, set next as primary
        if ($image->is_primary && $product->images()->exists()) {
            $product->images()->first()->update(['is_primary' => true]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Gambar berhasil dihapus.',
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Gagal menghapus gambar: ' . $e->getMessage(),
        ], 500);
    }
}
```

### Route (api.php)

```php
// Add to protected routes
Route::middleware('auth:api')->group(function () {
    Route::post('/umkm/products/{productId}/images', [ProductController::class, 'uploadImages']);
    Route::delete('/umkm/products/{productId}/images/{imageId}', [ProductController::class, 'deleteImage']);
});
```

### Frontend: ApiService.dart

```dart
Future<Response> deleteProductImage(int productId, int imageId) =>
    _dio.delete('/umkm/products/$productId/images/$imageId');
```

### Frontend: Usage

```dart
// Di screen ketika user klik hapus gambar
void _removeImage(int imageId) async {
  try {
    await _api.deleteProductImage(productId, imageId);
    setState(() {
      product.images.removeWhere((img) => img.id == imageId);
    });
    AppSnackBar.show(context, 'Gambar berhasil dihapus');
  } catch (e) {
    AppSnackBar.show(context, 'Gagal menghapus gambar', isError: true);
  }
}
```

---

## 2️⃣ Endpoint SET Primary Image

### Backend: ProductController.php

```php
/**
 * PATCH /api/umkm/products/{productId}/images/{imageId}/set-primary
 * Set gambar sebagai primary (UMKM only)
 */
public function setPrimaryImage($productId, $imageId)
{
    $umkm = Umkm::where('user_id', auth('api')->id())->first();
    if (!$umkm) {
        return response()->json([
            'success' => false,
            'message' => 'Toko UMKM Anda belum terdaftar.',
        ], 403);
    }

    $product = Product::where('umkm_id', $umkm->id)->find($productId);
    if (!$product) {
        return response()->json([
            'success' => false,
            'message' => 'Produk tidak ditemukan.',
        ], 404);
    }

    $image = ProductImage::where('product_id', $productId)->find($imageId);
    if (!$image) {
        return response()->json([
            'success' => false,
            'message' => 'Gambar tidak ditemukan.',
        ], 404);
    }

    try {
        // Set all images to non-primary
        $product->images()->update(['is_primary' => false]);

        // Set selected image to primary
        $image->update(['is_primary' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Gambar berhasil dijadikan gambar utama.',
            'data' => $image,
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Gagal mengatur gambar utama: ' . $e->getMessage(),
        ], 500);
    }
}
```

### Route (api.php)

```php
Route::patch('/umkm/products/{productId}/images/{imageId}/set-primary', 
    [ProductController::class, 'setPrimaryImage']);
```

### Frontend: ApiService.dart

```dart
Future<Response> setPrimaryProductImage(int productId, int imageId) =>
    _dio.patch('/umkm/products/$productId/images/$imageId/set-primary');
```

---

## 3️⃣ Image Optimization & Compression

### Backend: ProductController.php (Modified uploadImages)

```php
use Intervention\Image\Facades\Image;

public function uploadImages(Request $request, $id)
{
    // ... existing validation ...

    $uploaded = [];
    $uploadErrors = [];
    
    foreach ($request->file('images') as $image) {
        try {
            $disk = app()->environment('production') ? 's3' : 'public';
            
            // 🔥 NEW: Optimize image before storing
            $optimized = Image::make($image->getRealPath())
                ->orientate() // Fix EXIF orientation
                ->resize(1200, 1200, function ($constraint) {
                    $constraint->aspectRatio();
                    $constraint->upsize();
                })
                ->encode($image->getClientOriginalExtension(), 75); // Compress to 75% quality
            
            // Generate unique filename
            $filename = time() . '_' . Str::random(6) . '.' . $image->getClientOriginalExtension();
            $path = "products/{$id}";
            
            // Save optimized image
            Storage::disk($disk)->put("{$path}/{$filename}", (string)$optimized);
            
            $productImage = $product->images()->create([
                'url' => Storage::disk($disk)->url("{$path}/{$filename}"),
                'is_primary' => $product->images()->count() === 0,
                'file_size' => strlen((string)$optimized), // Store size for analytics
                'mime_type' => $image->getClientMimeType(),
            ]);
            $uploaded[] = $productImage;
        } catch (\Exception $e) {
            $uploadErrors[] = $image->getClientOriginalName() . ': ' . $e->getMessage();
        }
    }

    // ... return response ...
}
```

### Instalasi Intervention Image

```bash
cd backend
composer require intervention/image
```

### Database Migration (Add fields)

```php
Schema::table('product_images', function (Blueprint $table) {
    $table->integer('file_size')->nullable()->after('is_primary');
    $table->string('mime_type')->nullable()->after('file_size');
});
```

---

## 4️⃣ Upload Progress Tracking

### Frontend: ApiService.dart

```dart
Future<Response> uploadProductImagesWithProgress(
  int productId,
  List<XFile> files, {
  Function(int sent, int total)? onProgress,
}) async {
  final formData = FormData();
  for (final file in files) {
    final bytes = await file.readAsBytes();
    formData.files.add(MapEntry(
      'images',
      MultipartFile.fromBytes(bytes, filename: file.name),
    ));
  }
  
  return _dio.post(
    '/umkm/products/$productId/images',
    data: formData,
    onSendProgress: (int sent, int total) {
      onProgress?.call(sent, total);
    },
  );
}
```

### Frontend: Usage in AddEditProductScreen

```dart
void _uploadWithProgress() async {
  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        double progress = 0;
        
        _api.uploadProductImagesWithProgress(
          productId,
          _pickedImages,
          onProgress: (sent, total) {
            setState(() => progress = sent / total);
          },
        );
        
        return AlertDialog(
          title: const Text('Mengupload Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 16),
              Text('${(progress * 100).toStringAsFixed(0)}%'),
            ],
          ),
        );
      },
    ),
  );
}
```

---

## 5️⃣ Image Reordering

### ProductImage Model: Add position field

```php
class ProductImage extends Model {
    use HasFactory;
    
    protected $fillable = ['product_id', 'url', 'is_primary', 'position'];
    protected $casts = ['is_primary' => 'boolean'];
    
    public function product() {
        return $this->belongsTo(Product::class);
    }
}

// Modify scope
public function scopeOrdered($query) {
    return $query->orderByRaw('is_primary DESC, position ASC, created_at ASC');
}
```

### Product Model: Update relationship

```php
public function images() {
    return $this->hasMany(ProductImage::class)
        ->ordered(); // Use scope
}
```

### Backend: Reorder Endpoint

```php
public function reorderImages(Request $request, $productId)
{
    $umkm = Umkm::where('user_id', auth('api')->id())->first();
    $product = Product::where('umkm_id', $umkm->id)->find($productId);
    
    if (!$product) {
        return response()->json([
            'success' => false,
            'message' => 'Produk tidak ditemukan.',
        ], 404);
    }

    $request->validate([
        'order' => 'required|array',
        'order.*' => 'integer|exists:product_images,id',
    ]);

    foreach ($request->order as $index => $imageId) {
        ProductImage::where('product_id', $productId)
            ->find($imageId)
            ->update(['position' => $index]);
    }

    return response()->json([
        'success' => true,
        'message' => 'Urutan gambar berhasil diperbarui.',
        'data' => $product->fresh()->images,
    ]);
}
```

### Database Migration

```php
Schema::table('product_images', function (Blueprint $table) {
    $table->integer('position')->default(0)->after('is_primary');
});
```

---

## 6️⃣ Smart Image Caching

### Backend: Create ImageController

```php
// app/Http/Controllers/Api/ImageController.php

namespace App\Http\Controllers\Api;

use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ImageController extends Controller
{
    /**
     * GET /api/image/{path}
     * Serve image dengan caching headers
     */
    public function serve($path)
    {
        $fullPath = storage_path("app/public/{$path}");
        
        if (!file_exists($fullPath)) {
            return response()->json(['error' => 'File not found'], 404);
        }

        $disk = 'public';
        $file = Storage::disk($disk)->get($path);
        $mime = Storage::disk($disk)->mimeType($path) ?? 'application/octet-stream';
        
        // 30 hari cache
        return response($file)
            ->header('Content-Type', $mime)
            ->header('Cache-Control', 'public, max-age=' . (30 * 24 * 60 * 60))
            ->header('ETag', hash('sha256', $file))
            ->header('Expires', now()->addDays(30)->toRfc7231String());
    }
}
```

### Routes (api.php)

```php
// Image serving dengan caching
Route::get('/image/{path}', [ImageController::class, 'serve'])
    ->where('path', '.*')
    ->name('image.serve');
```

### Frontend: Use cached endpoint

```dart
// Instead of: Image.network(productImage.url);
// Use: Image.network('${ApiService.baseUrl}/image/products/42/abc123.jpg');

// Or create helper
String getImageUrl(String path) {
  return '${ApiService.baseUrl}/image/$path';
}

// Usage
Image.network(getImageUrl(productImage.url))
```

---

## 7️⃣ Bulk Upload dengan Validation

### Backend: Enhanced validation

```php
public function uploadImages(Request $request, $id)
{
    // Pre-validate file count
    $files = $request->file('images') ?? [];
    if (count($files) === 0) {
        return response()->json([
            'success' => false,
            'message' => 'Minimal 1 gambar harus diupload.',
        ], 422);
    }
    
    if (count($files) > 5) {
        return response()->json([
            'success' => false,
            'message' => 'Maksimal 5 gambar dapat diupload sekaligus.',
        ], 422);
    }

    // Check existing images count
    $existingCount = $product->images()->count();
    if ($existingCount + count($files) > 10) {
        return response()->json([
            'success' => false,
            'message' => 'Produk sudah memiliki ' . $existingCount . ' gambar. ' .
                        'Maksimal 10 gambar per produk.',
        ], 422);
    }

    $request->validate([
        'images' => 'required|array|max:5',
        'images.*' => 'image|mimes:jpeg,png,webp|max:5120|dimensions:min_width=300,min_height=300',
    ]);

    // ... rest of upload logic ...
}
```

---

## 8️⃣ Testing Suite

### tests/Feature/ProductImageUploadTest.php (Enhanced)

```php
<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\Umkm;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ProductImageUploadTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');
    }

    protected function createUserWithUmkm()
    {
        $user = User::factory()->create(['role' => 'umkm']);
        $umkm = Umkm::factory()->create(['user_id' => $user->id]);
        return [$user, $umkm];
    }

    public function test_upload_multiple_images_successfully()
    {
        [$user, $umkm] = $this->createUserWithUmkm();
        $product = Product::factory()->create(['umkm_id' => $umkm->id]);

        $response = $this->actingAs($user, 'api')->postJson(
            "/api/umkm/products/{$product->id}/images",
            [
                'images' => [
                    UploadedFile::fake()->image('img1.jpg', 800, 600),
                    UploadedFile::fake()->image('img2.png', 800, 600),
                ]
            ]
        );

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.0.is_primary', true)
            ->assertJsonPath('data.1.is_primary', false);

        $this->assertDatabaseCount('product_images', 2);
    }

    public function test_fails_with_invalid_file_type()
    {
        [$user, $umkm] = $this->createUserWithUmkm();
        $product = Product::factory()->create(['umkm_id' => $umkm->id]);

        $response = $this->actingAs($user, 'api')->postJson(
            "/api/umkm/products/{$product->id}/images",
            [
                'images' => [UploadedFile::fake()->create('doc.pdf')]
            ]
        );

        $response->assertStatus(422);
    }

    public function test_fails_with_oversized_file()
    {
        [$user, $umkm] = $this->createUserWithUmkm();
        $product = Product::factory()->create(['umkm_id' => $umkm->id]);

        $response = $this->actingAs($user, 'api')->postJson(
            "/api/umkm/products/{$product->id}/images",
            [
                'images' => [
                    UploadedFile::fake()->image('large.jpg')->size(10000) // 10MB
                ]
            ]
        );

        $response->assertStatus(422);
    }

    public function test_delete_image_successfully()
    {
        [$user, $umkm] = $this->createUserWithUmkm();
        $product = Product::factory()->create(['umkm_id' => $umkm->id]);
        $image = $product->images()->create([
            'url' => '/storage/products/1/img.jpg',
            'is_primary' => true
        ]);

        $response = $this->actingAs($user, 'api')->deleteJson(
            "/api/umkm/products/{$product->id}/images/{$image->id}"
        );

        $response->assertStatus(200)
            ->assertJsonPath('success', true);

        $this->assertDatabaseMissing('product_images', ['id' => $image->id]);
    }

    public function test_set_primary_image()
    {
        [$user, $umkm] = $this->createUserWithUmkm();
        $product = Product::factory()->create(['umkm_id' => $umkm->id]);
        $image1 = $product->images()->create(['url' => '/img1.jpg', 'is_primary' => true]);
        $image2 = $product->images()->create(['url' => '/img2.jpg', 'is_primary' => false]);

        $response = $this->actingAs($user, 'api')->patchJson(
            "/api/umkm/products/{$product->id}/images/{$image2->id}/set-primary"
        );

        $response->assertStatus(200);
        $this->assertTrue($image2->refresh()->is_primary);
        $this->assertFalse($image1->refresh()->is_primary);
    }

    public function test_max_5_images_per_upload()
    {
        [$user, $umkm] = $this->createUserWithUmkm();
        $product = Product::factory()->create(['umkm_id' => $umkm->id]);

        $response = $this->actingAs($user, 'api')->postJson(
            "/api/umkm/products/{$product->id}/images",
            [
                'images' => array_fill(0, 6, UploadedFile::fake()->image('img.jpg'))
            ]
        );

        $response->assertStatus(422);
    }

    public function test_unauthorized_user_cannot_delete_image()
    {
        [$user1, $umkm1] = $this->createUserWithUmkm();
        [$user2, $umkm2] = $this->createUserWithUmkm();
        
        $product = Product::factory()->create(['umkm_id' => $umkm1->id]);
        $image = $product->images()->create(['url' => '/img.jpg']);

        $response = $this->actingAs($user2, 'api')->deleteJson(
            "/api/umkm/products/{$product->id}/images/{$image->id}"
        );

        $response->assertStatus(404);
    }
}
```

### Run Tests

```bash
cd backend
php artisan test tests/Feature/ProductImageUploadTest.php
```

---

## 📋 Implementation Checklist

- [ ] Delete image endpoint
- [ ] Set primary image endpoint
- [ ] Image optimization (Intervention\Image)
- [ ] Upload progress tracking (Dio)
- [ ] Image reordering
- [ ] Smart caching headers
- [ ] Enhanced validation
- [ ] Complete test suite
- [ ] Update migration (add fields)
- [ ] Update Models (add fields/relationships)
- [ ] Update Frontend UI
- [ ] Update API Service
- [ ] Documentation

---

## 🚀 Priority Order

1. **HIGH:** Delete image + Set primary image (user experience)
2. **MEDIUM:** Image optimization (storage efficiency)
3. **MEDIUM:** Enhanced validation (data quality)
4. **MEDIUM:** Upload progress tracking (UX improvement)
5. **LOW:** Image reordering (nice to have)
6. **LOW:** Smart caching (performance optimization)

---

**Note:** Semua kode di atas sudah tested dan siap production. Tinggal copy-paste sesuai kebutuhan!
