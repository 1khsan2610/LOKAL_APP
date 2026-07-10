# 📸 Panduan Image Sync Backend Laravel & Frontend Flutter

## 🎯 Gambaran Umum
Sistem telah diintegrasikan untuk sinkronisasi gambar produk antara frontend Flutter dan backend Laravel. Ketika UMKM mengunggah gambar produk melalui aplikasi Flutter, gambar tersebut:
1. ✅ Disimpan di storage server (local/S3)
2. ✅ Direkam di database (tabel `product_images`)
3. ✅ Dapat diakses melalui API dengan URL lengkap

---

## 🔄 Flow Proses Upload

### Skenario: UMKM Upload Produk Baru dengan Gambar

```
┌─── Flutter (Client) ────────────────────────────────┐
│                                                     │
│ 1. User buka AddEditProductScreen                   │
│ 2. Tekan "Pilih Gambar" → ImagePicker              │
│ 3. Pilih 1-5 gambar (JPEG/PNG/WebP, max 5MB)       │
│                                                     │
│    ✓ Gambar ditampilkan preview                    │
│    ✓ User bisa hapus gambar yang salah             │
│                                                     │
│ 4. Isi data produk (nama, harga, stok, dst)        │
│ 5. Klik "Simpan"                                    │
│                                                     │
└────────────────────────────────────────────────────┘
         │
         │ Step A: Create Product (POST /api/umkm/products)
         │ ├─ name, price, stock, category, weight, description
         │ └─ Returns: product_id
         ▼
┌─── Backend (Laravel) ───────────────────────────────┐
│                                                     │
│ ProductController::store()                          │
│ ├─ Validasi input                                   │
│ ├─ Cek UMKM ownership                               │
│ └─ CREATE Product record                            │
│                                                     │
└────────────────────────────────────────────────────┘
         │
         │ Step B: Upload Images (POST /api/umkm/products/{id}/images)
         │ ├─ Kirim: FormData dengan file gambar
         │ └─ Header: Content-Type: multipart/form-data
         ▼
┌─── Backend (Laravel) ───────────────────────────────┐
│                                                     │
│ ProductController::uploadImages()                   │
│ ├─ Validasi file (tipe, ukuran)                     │
│ ├─ Simpan ke storage/app/public/products/{id}      │
│ ├─ Generate URL publik                              │
│ └─ CREATE ProductImage records di database          │
│                                                     │
│ Response:                                            │
│ {                                                   │
│   "success": true,                                  │
│   "message": "2 gambar berhasil diupload.",        │
│   "data": [                                         │
│     {                                               │
│       "id": 1,                                      │
│       "product_id": 5,                              │
│       "url": "http://server/storage/products/5/...",│
│       "is_primary": true,                           │
│       "created_at": "2026-07-07T10:30:00Z"         │
│     }                                               │
│   ]                                                 │
│ }                                                   │
│                                                     │
└────────────────────────────────────────────────────┘
         │
         ▼
┌─── Flutter (Client) ────────────────────────────────┐
│                                                     │
│ Menerima response sukses                            │
│ ├─ Update local state                               │
│ ├─ Tampilkan notif: "Produk & gambar berhasil      │
│ │  disimpan"                                        │
│ └─ Navigasi ke manage_product_screen                │
│                                                     │
└────────────────────────────────────────────────────┘
```

---

## 📝 Endpoint API

### POST `/api/umkm/products` - Create Product
**Autentikasi:** ✅ Required (JWT)  
**Role:** UMKM only

**Request:**
```json
{
  "name": "Keripik Kentang Pedas",
  "description": "Keripik kentang renyah dengan rasa pedas pilihan",
  "price": 25000,
  "stock": 100,
  "category": "makanan",
  "weight": 250,
  "variants": [
    {
      "name": "Ukuran",
      "value": "500g",
      "price_modifier": 5000,
      "stock": 50
    }
  ]
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Produk berhasil ditambahkan.",
  "data": {
    "id": 42,
    "name": "Keripik Kentang Pedas",
    "price": 25000,
    "stock": 100,
    "category": "makanan",
    "variants": [...]
  }
}
```

---

### POST `/api/umkm/products/{id}/images` - Upload Images
**Autentikasi:** ✅ Required (JWT)  
**Role:** UMKM only  
**Max Files:** 5  
**Max Size:** 5MB per file  
**Allowed Types:** image/jpeg, image/png, image/webp

**Request (FormData):**
```
POST /api/umkm/products/42/images
Header: Authorization: Bearer {token}
Body (multipart/form-data):
  images: [file1.jpg, file2.jpg, ...]
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "2 gambar berhasil diupload.",
  "data": [
    {
      "id": 101,
      "product_id": 42,
      "url": "http://ekonomi_lokal.test/storage/products/42/abc123.jpg",
      "is_primary": true,
      "created_at": "2026-07-07T10:35:00Z"
    },
    {
      "id": 102,
      "product_id": 42,
      "url": "http://ekonomi_lokal.test/storage/products/42/def456.jpg",
      "is_primary": false,
      "created_at": "2026-07-07T10:35:01Z"
    }
  ]
}
```

**Error Response (422 Unprocessable):**
```json
{
  "success": false,
  "message": "Validasi gagal",
  "errors": {
    "images.0": ["File harus berupa gambar"],
    "images.1": ["File terlalu besar, maksimal 5MB"]
  }
}
```

---

### GET `/api/products/{id}` - Get Product dengan Images
**Autentikasi:** ❌ Public

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 42,
    "name": "Keripik Kentang Pedas",
    "price": 25000,
    "images": [
      {
        "id": 101,
        "product_id": 42,
        "url": "http://ekonomi_lokal.test/storage/products/42/abc123.jpg",
        "is_primary": true
      },
      {
        "id": 102,
        "product_id": 42,
        "url": "http://ekonomi_lokal.test/storage/products/42/def456.jpg",
        "is_primary": false
      }
    ]
  }
}
```

---

## 🗄️ Database Schema

### Tabel: `product_images`
```sql
CREATE TABLE product_images (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE INDEX idx_product_images_product_id ON product_images(product_id);
```

### Model: `ProductImage`
```php
class ProductImage extends Model {
    protected $fillable = ['product_id', 'url', 'is_primary'];
    protected $casts = ['is_primary' => 'boolean'];
    
    public function product() {
        return $this->belongsTo(Product::class);
    }
}
```

### Model: `Product`
```php
class Product extends Model {
    public function images() {
        return $this->hasMany(ProductImage::class)->orderBy('is_primary', 'desc');
    }
    
    public function getPrimaryImageAttribute() {
        return $this->images->where('is_primary', true)->first()?->url
            ?? $this->images->first()?->url
            ?? null;
    }
}
```

---

## 🎨 Frontend Implementation (Flutter)

### File: `lib/screens/umkm/add_edit_product_screen.dart`

**Key Features:**
- ✅ Image picker (multiple selection)
- ✅ Image preview sebelum upload
- ✅ Remove individual images
- ✅ Compress images (quality: 80)
- ✅ Fallback error handling

**Usage:**
```dart
Future<void> _pickImages() async {
  final picked = await _picker.pickMultiImage(imageQuality: 80);
  if (picked.isEmpty) return;
  setState(() => _pickedImages.addAll(picked));
}

Future<void> _save() async {
  // 1. Simpan produk
  int productId = await createProduct(data);
  
  // 2. Upload gambar
  if (_pickedImages.isNotEmpty) {
    await _api.uploadProductImages(productId, _pickedImages);
  }
}
```

### File: `lib/services/api_service.dart`

**Method: `uploadProductImages()`**
```dart
Future<Response> uploadProductImages(int productId, List<XFile> files) async {
  final formData = FormData();
  for (final file in files) {
    final bytes = await file.readAsBytes();
    formData.files.add(MapEntry(
      'images',
      MultipartFile.fromBytes(bytes, filename: file.name),
    ));
  }
  return _dio.post('/umkm/products/$productId/images', data: formData);
}
```

---

## ⚙️ Backend Implementation (Laravel)

### File: `app/Http/Controllers/Api/ProductController.php`

**Method: `uploadImages()`** (Line 223-293)

**Key Features:**
- ✅ Handle multiple file input formats (images[], images)
- ✅ Validate file type & size
- ✅ Verify UMKM ownership
- ✅ Set first image as primary
- ✅ Use local storage (dev) / S3 (production)
- ✅ Partial success handling

**Logic:**
```php
public function uploadImages(Request $request, $id) {
    // 1. Parse incoming files (flexible format handling)
    $files = $request->allFiles()['images'] ?? null;
    
    // 2. Validate
    $request->validate([
        'images' => 'required|array|max:5',
        'images.*' => 'image|mimes:jpeg,png,webp|max:5120',
    ]);
    
    // 3. Check UMKM ownership
    $product = Product::where('umkm_id', $umkm->id)->find($id);
    
    // 4. Loop upload setiap file
    foreach ($request->file('images') as $image) {
        $disk = app()->environment('production') ? 's3' : 'public';
        $path = $image->store("products/{$product->id}", $disk);
        
        $product->images()->create([
            'url' => Storage::disk($disk)->url($path),
            'is_primary' => $product->images()->count() === 0,
        ]);
    }
}
```

---

## 🔐 Security Features

### ✅ Implemented
1. **Authentication:** JWT token validation required
2. **Authorization:** Verify UMKM ownership (hanya pemilik produk bisa upload)
3. **File Validation:** Check MIME type, size, extension
4. **Disk Usage:** Separate directories per product (`products/{id}/`)
5. **Environment-aware:** Local disk (dev), S3 (prod)
6. **Error Handling:** Partial success, detailed error messages

### 🛡️ Best Practices
- ✅ Whitelist MIME types (JPEG, PNG, WebP)
- ✅ Limit file size (5MB max)
- ✅ Limit quantity (5 files max)
- ✅ Auto-compress on frontend (quality: 80)
- ✅ Filename randomization via Laravel storage
- ✅ SQL injection prevention via ORM

---

## 🚀 Peningkatan yang Bisa Dilakukan

### 1. **Fitur Delete Image**
```php
// Route: DELETE /api/umkm/products/{productId}/images/{imageId}
public function deleteImage($productId, $imageId) {
    $image = ProductImage::where('product_id', $productId)->find($imageId);
    // Delete file from storage
    Storage::disk($disk)->delete($image->url);
    // Delete record
    $image->delete();
}
```

### 2. **Set Primary Image**
```php
// Route: PATCH /api/umkm/products/{productId}/images/{imageId}/set-primary
public function setPrimary($productId, $imageId) {
    ProductImage::where('product_id', $productId)->update(['is_primary' => false]);
    ProductImage::find($imageId)->update(['is_primary' => true]);
}
```

### 3. **Image Optimization**
```php
// Gunakan intervention/image untuk resize & compress
use Intervention\Image\Facades\Image;

$image->resize(800, 800)->save(storage_path("app/public/{$path}"), 75);
```

### 4. **Progress Tracking**
```dart
// Flutter: Track upload progress dengan dio's onSendProgress
await _dio.post(
  '/umkm/products/$productId/images',
  data: formData,
  onSendProgress: (int sent, int total) {
    print('${(sent/total * 100).toStringAsFixed(0)}%');
  }
);
```

### 5. **Reorder Images**
```php
// Route: POST /api/umkm/products/{productId}/images/reorder
public function reorderImages(Request $request) {
    $order = $request->validate(['order' => 'required|array']);
    foreach ($order['order'] as $index => $imageId) {
        ProductImage::find($imageId)->update(['position' => $index]);
    }
}
```

### 6. **Image Caching**
```php
// Laravel route caching untuk image serving
Route::get('/image/{path}', [ImageController::class, 'serve'])
    ->cache(3600 * 24 * 30) // Cache 30 hari
    ->where('path', '.*');
```

---

## 🧪 Testing

### Test Coverage yang Ada
File: `tests/Feature/ProductImageUploadTest.php`

```php
test_umkm_can_upload_product_images_using_images_array_key() {
    // ✅ Test upload dengan FormData
    // ✅ Verify file saved
    // ✅ Verify database record created
}
```

### Test yang Bisa Ditambahkan
```php
// Test: File validation (size, type)
test_fails_with_invalid_file_types()
test_fails_with_files_exceeding_size()

// Test: Authorization
test_fails_if_not_product_owner()

// Test: Primary image logic
test_first_image_marked_as_primary()

// Test: Error recovery
test_partial_success_on_mixed_valid_invalid_files()
```

---

## 📱 Usage Example

### Step-by-Step di Frontend:
```dart
// 1. User klik "Pilih Gambar"
await _pickImages(); // Show image picker

// 2. User pilih gambar dan klik "Simpan"
int productId = await _api.createProduct(data);

// 3. Upload gambar
await _api.uploadProductImages(productId, _pickedImages);

// 4. Success
showSnackBar('Produk dan gambar berhasil disimpan');
```

### Di Backend (Automatic):
```
1. Terima multipart request
2. Validate files
3. Store di storage/app/public/products/{id}/
4. Create ProductImage records
5. Return URLs
```

### Di Client (Saat View Produk):
```dart
// GET /api/products/{id}
final product = await _api.getProduct(id);

// Akses gambar
Image.network(product.images[0].url);

// Atau gunakan primary
Image.network(product.primaryImage);
```

---

## 🔗 Related Files

**Backend:**
- [ProductController.php](backend/app/Http/Controllers/Api/ProductController.php)
- [ProductImage Model](backend/app/Models/ProductImage.php)
- [Product Model](backend/app/Models/Product.php)
- [API Routes](backend/routes/api.php)
- [ProductImageUploadTest.php](backend/tests/Feature/ProductImageUploadTest.php)

**Frontend:**
- [AddEditProductScreen.dart](frontend/lib/screens/umkm/add_edit_product_screen.dart)
- [ApiService.dart](frontend/lib/services/api_service.dart)
- [ProductModel.dart](frontend/lib/models/product_model.dart)

**Database:**
- Migration: `database/migrations/XXXX_create_product_images_table.php`

---

## 📞 Troubleshooting

### ❌ Issue: "Gambar tidak terupload"
**Solusi:**
- Cek ukuran file (max 5MB)
- Cek format file (JPEG, PNG, WebP)
- Cek connection internet
- Cek token autentikasi (expire?)
- Lihat response error message di console

### ❌ Issue: "CORS error saat upload"
**Solusi:**
- Pastikan `config/cors.php` allow frontend URL
- Check header `Access-Control-Allow-Origin`
- Lihat error di browser dev tools → Network tab

### ❌ Issue: "404 saat akses gambar"
**Solusi:**
- Run `php artisan storage:link` (create symlink)
- Check storage folder permissions (chmod 755)
- Verify file ada di `storage/app/public/products/{id}/`

### ❌ Issue: "Database record tidak terbuat"
**Solusi:**
- Check migration sudah dijalankan
- Check ProductImage model fillable fields
- Check SQL error di `storage/logs/laravel.log`

---

## 📊 Data Flow Summary

```
Flutter App
    ↓ (Pick images)
ImagePicker (XFile list)
    ↓ (Create FormData)
ApiService.uploadProductImages()
    ↓ (HTTP POST multipart/form-data)
ProductController.uploadImages()
    ↓ (Validate & Store)
Storage (storage/app/public/products/{id}/)
ProductImage (Database)
    ↓ (Return URLs)
Flutter App (Display images)
```

---

## ✅ Checklist Implementasi

- [x] Database migration (product_images table)
- [x] ProductImage model
- [x] Product relationships
- [x] Laravel controller (upload logic)
- [x] API routes (POST /api/umkm/products/{id}/images)
- [x] Flutter image picker
- [x] ApiService method (uploadProductImages)
- [x] FormData construction
- [x] File validation (backend & frontend)
- [x] Error handling
- [x] Unit tests
- [ ] Delete image endpoint (recommended improvement)
- [ ] Set primary image endpoint (recommended improvement)
- [ ] Image optimization/resizing (recommended improvement)
- [ ] Upload progress tracking (recommended improvement)
- [ ] Image caching (recommended improvement)

---

**Last Updated:** 2026-07-07  
**Status:** ✅ Production Ready (Core features implemented)  
**Next Steps:** Implement recommended improvements above
