# 📊 Image Sync Architecture & Troubleshooting Guide

## 🏗️ System Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                          EKONOMI LOKAL SYSTEM                         │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  ╔═══════════════════════════╗        ╔═══════════════════════════╗  │
│  ║   FLUTTER FRONTEND        ║        ║    LARAVEL BACKEND        ║  │
│  ║   (Mobile/Web)            ║        ║    (API Server)           ║  │
│  ╠═══════════════════════════╣        ╠═══════════════════════════╣  │
│  ║                           ║        ║                           ║  │
│  ║ ┌─────────────────────┐   ║        ║ ┌─────────────────────┐  ║  │
│  ║ │ ImagePicker Plugin  │───┼────┐   ║ │ ProductController   │  ║  │
│  ║ │ (camera/gallery)    │   ║    │   ║ │ uploadImages()      │  ║  │
│  ║ └─────────────────────┘   ║    │   ║ │ deleteImage()       │  ║  │
│  ║ ┌─────────────────────┐   ║    │   ║ │ setPrimaryImage()   │  ║  │
│  ║ │ ApiService          │   ║    │   ║ └─────────────────────┘  ║  │
│  ║ │ uploadProductImages │───┼──→ HTTP (POST/DELETE/PATCH)       ║  │
│  ║ └─────────────────────┘   ║    │   ║ ┌─────────────────────┐  ║  │
│  ║ ┌─────────────────────┐   ║    │   ║ │ ProductImage Model  │  ║  │
│  ║ │ XFile List          │   ║    │   ║ │ - id                │  ║  │
│  ║ │ (picked images)     │   ║    │   ║ │ - product_id        │  ║  │
│  ║ └─────────────────────┘   ║    │   ║ │ - url               │  ║  │
│  ║                           ║    │   ║ │ - is_primary        │  ║  │
│  │                           │    │   ║ │ - file_size         │  ║  │
│  ║ FormData (multipart)      ║    │   ║ │ - mime_type         │  ║  │
│  ║ ├─ Content-Type           ║    │   ║ │ - position          │  ║  │
│  ║ ├─ Authorization          ║    │   ║ │ - created_at        │  ║  │
│  ║ ├─ images[0]: binary      ║    │   ║ └─────────────────────┘  ║  │
│  ║ └─ images[1]: binary      ║    │   ║ ┌─────────────────────┐  ║  │
│  ╚═══════════════════════════╝    │   ║ │ Umkm Authorization  │  ║  │
│                                   │   ║ │ - Verify ownership  │  ║  │
│                                   │   ║ │ - Check permissions │  ║  │
│                                   │   ║ └─────────────────────┘  ║  │
│                                   │   ╚═══════════════════════════╝  │
│                                   │                                 │
│  ╔═══════════════════════════╗    │   ╔═══════════════════════════╗  │
│  ║ Image Display             ║    │   ║ FILE STORAGE              ║  │
│  ║ ┌─────────────────────┐   ║    │   ║ ┌─────────────────────┐  ║  │
│  ║ │ Image.network(url)  │←──┼────┼───→ /storage/app/public/  │  ║  │
│  ║ │ with caching        │   ║    │   ║ └─products/           ║  │  │
│  ║ └─────────────────────┘   ║    │   ║ ──{productId}/        ║  ║  │
│  │                           │    │   ║ ────{filename.jpg}    ║  ║  │
│  ║ Cache:                    ║    │   ║ ────{filename.png}    ║  ║  │
│  ║ ├─ 30 days expiry         ║    │   ║ ────{filename.webp}   ║  ║  │
│  ║ ├─ ETag validation        ║    │   ║                       ║  ║  │
│  ║ └─ CDN ready              ║    │   ║ OR (production):       ║  ║  │
│  ╚═══════════════════════════╝    │   ║ ├─ AWS S3 Bucket      ║  ║  │
│                                   │   ║ └─ With CloudFront    ║  ║  │
│                                   │   ╚═══════════════════════╝  ║  │
│                                   │                              │  │
│                                   │   ╔═════════════════════════╗│  │
│                                   │   ║ DATABASE                 ║  │
│                                   │   ║ ┌─────────────────────┐ ║  │
│                                   └──→ │ product_images      │ ║  │
│                                       │ - Stores URLs       │ ║  │
│                                       │ - Metadata          │ ║  │
│                                       │ - Relationships     │ ║  │
│                                       └─────────────────────┘ ║  │
│                                       ┌─────────────────────┐ ║  │
│                                       │ products            │ ║  │
│                                       │ - Foreign key       │ ║  │
│                                       │ - has many images   │ ║  │
│                                       └─────────────────────┘ ║  │
│                                       ╚═════════════════════════╝  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Authentication & Authorization Flow

```
REQUEST (Flutter)
      ↓
   [JWT Token in Authorization Header]
      ↓
   ProductController
      ↓
   ✅ Token Valid?
      ├─ NO → Response 401 Unauthorized
      │
      └─ YES → auth('api')->id() → Get User ID
           ↓
        Umkm::where('user_id', $userId)
           ↓
        ✅ Umkm Found?
           ├─ NO → Response 403 Forbidden
           │
           └─ YES → Continue
              ↓
           Product::where('umkm_id', $umkm_id)->find($id)
              ↓
           ✅ Product Belongs to UMKM?
              ├─ NO → Response 404 Not Found
              │
              └─ YES → Proceed with Upload
```

---

## 📤 Complete Upload Flow Sequence

```
┌──────────────┐                                          ┌──────────────┐
│  Flutter App │                                          │ Laravel API  │
└──────┬───────┘                                          └──────┬───────┘
       │                                                         │
       │  1. User taps "Pick Images"                            │
       │  ┌─────────────────────────┐                           │
       │  │ ImagePicker.pickMultiImage()                        │
       │  │ Returns: List<XFile>                                │
       │  └─────────────────────────┘                           │
       │                                                         │
       │  2. Display preview                                    │
       │  ┌──────────────┐                                       │
       │  │ Build UI     │                                       │
       │  │ Show images  │                                       │
       │  └──────────────┘                                       │
       │                                                         │
       │  3. User fills product data & clicks "Simpan"          │
       │                                                         │
       │  4. Create product first                               │
       ├─────────────────────────────────────────────────────→  │
       │ POST /api/umkm/products                                │
       │ {                                                      │
       │   "name": "Keripik",                                   │
       │   "price": 25000,                                      │
       │   ...                                                  │
       │ }                                                      │
       │                                                         │
       │←────────────────────────────────────────────────────── │
       │ 201 Created                                            │
       │ {                                                      │
       │   "success": true,                                     │
       │   "data": { "id": 42, ... }                            │
       │ }                                                      │
       │                                                         │
       │  5. Upload images                                      │
       ├─────────────────────────────────────────────────────→  │
       │ POST /api/umkm/products/42/images                      │
       │ [FormData]                                             │
       │ ├─ Content-Type: multipart/form-data                   │
       │ ├─ Authorization: Bearer {token}                       │
       │ ├─ images[0]: {binary}                                 │
       │ └─ images[1]: {binary}                                 │
       │                                                         │
       │                    [Backend Processing]                │
       │                    ↓                                   │
       │                ✅ Validate token                       │
       │                ✅ Verify UMKM                          │
       │                ✅ Check product ownership              │
       │                ✅ Validate files                       │
       │                   - Type: JPEG/PNG/WebP                │
       │                   - Size: < 5MB each                   │
       │                   - Count: < 5 files                   │
       │                ✅ Optimize images                      │
       │                   - Resize to 1200x1200               │
       │                   - Compress to 75% quality           │
       │                ✅ Store to disk                        │
       │                   /storage/products/42/               │
       │                ✅ Create DB records                    │
       │                   INSERT INTO product_images          │
       │                ✅ Generate URLs                        │
       │                                                         │
       │←────────────────────────────────────────────────────── │
       │ 200 OK                                                 │
       │ {                                                      │
       │   "success": true,                                     │
       │   "message": "2 gambar berhasil diupload.",            │
       │   "data": [                                            │
       │     {                                                  │
       │       "id": 101,                                       │
       │       "product_id": 42,                                │
       │       "url": "http://.../storage/products/42/a.jpg",   │
       │       "is_primary": true,                              │
       │       "file_size": 245678,                             │
       │       "mime_type": "image/jpeg",                       │
       │       "created_at": "2026-07-07T10:35:00Z"            │
       │     }                                                  │
       │   ]                                                    │
       │ }                                                      │
       │                                                         │
       │  6. Show success message                               │
       │  7. Navigate to product list                           │
       │                                                         │
└──────────────┘                                          └──────────────┘
```

---

## ⚠️ Error Handling Flow

```
Upload Request
    ↓
┌───────────────────────────────────┐
│ 1. File Size Check                │
└───────────────────────────────────┘
    ├─ ERROR: File > 5MB
    │  └─ Response 422 → "File terlalu besar"
    │
    └─ OK → Continue
    
    ↓
┌───────────────────────────────────┐
│ 2. File Type Check                │
└───────────────────────────────────┘
    ├─ ERROR: Not image
    │  └─ Response 422 → "File harus berupa gambar"
    │
    └─ OK → Continue
    
    ↓
┌───────────────────────────────────┐
│ 3. MIME Type Whitelist            │
└───────────────────────────────────┘
    ├─ ERROR: Not JPEG/PNG/WebP
    │  └─ Response 422 → "Format tidak didukung"
    │
    └─ OK → Continue
    
    ↓
┌───────────────────────────────────┐
│ 4. Authentication Check           │
└───────────────────────────────────┘
    ├─ ERROR: No token
    │  └─ Response 401 → "Unauthenticated"
    │
    ├─ ERROR: Invalid token
    │  └─ Response 401 → "Invalid token"
    │
    └─ OK → Continue
    
    ↓
┌───────────────────────────────────┐
│ 5. Authorization Check            │
└───────────────────────────────────┘
    ├─ ERROR: No UMKM
    │  └─ Response 403 → "Toko belum terdaftar"
    │
    ├─ ERROR: Not product owner
    │  └─ Response 404 → "Produk tidak ditemukan"
    │
    └─ OK → Continue
    
    ↓
┌───────────────────────────────────┐
│ 6. Storage Write Check            │
└───────────────────────────────────┘
    ├─ ERROR: Disk full / Permission denied
    │  └─ Response 500 → "Gagal menyimpan file"
    │
    └─ OK → Continue
    
    ↓
┌───────────────────────────────────┐
│ 7. Database Insert                │
└───────────────────────────────────┘
    ├─ ERROR: DB error
    │  └─ Response 500 → "Gagal menyimpan ke database"
    │
    └─ OK → Success 200
    
    ↓
✅ Response 200 OK dengan data
```

---

## 🔧 Database Schema Details

### product_images Table

```sql
CREATE TABLE product_images (
    -- Primary Key
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    
    -- Foreign Key (Product relationship)
    product_id BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    
    -- File Information
    url VARCHAR(500) NOT NULL,                    -- Full URL path
    file_size INT UNSIGNED NULLABLE,              -- Bytes
    mime_type VARCHAR(50) NULLABLE,               -- e.g. "image/jpeg"
    
    -- Image Management
    is_primary BOOLEAN DEFAULT FALSE,             -- Used in product listing
    position INT DEFAULT 0,                       -- For reordering
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes
    KEY idx_product_id (product_id),
    KEY idx_is_primary (is_primary),
    KEY idx_position (position)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Indexes Performance Impact

```
Query: Get all images for product
SELECT * FROM product_images 
WHERE product_id = 42 
ORDER BY is_primary DESC, position ASC
→ Uses idx_product_id → FAST ✅

Query: Get primary image only
SELECT * FROM product_images 
WHERE product_id = 42 AND is_primary = true
→ Uses idx_product_id + idx_is_primary → VERY FAST ✅
```

---

## 📲 Storage Paths & URLs

### Development Environment

```
Storage Root: storage/app/public/

Physical Path:
storage/app/public/products/
├─ 1/
│  ├─ 1688962500_abc123.jpg
│  ├─ 1688962501_def456.png
│  └─ 1688962502_ghi789.webp
├─ 2/
│  └─ 1688962600_xyz789.jpg
└─ 3/
   ├─ 1688962700_qwe123.jpg
   └─ 1688962701_asd456.jpg

Public URL (Symlink):
http://localhost/storage/products/{id}/{filename}
http://localhost/storage/products/1/1688962500_abc123.jpg

Access via Symlink (already set):
$ php artisan storage:link
→ Creates: public/storage → storage/app/public

Frontend: Image.network('http://localhost/storage/products/1/abc.jpg')
```

### Production Environment (S3)

```
S3 Bucket: ekonomi-lokal-prod

Key Path:
products/
├─ 1/abc123.jpg
├─ 1/def456.png
├─ 2/xyz789.jpg
└─ ...

Public URL (CloudFront):
https://cdn.ekonomi-lokal.com/products/{id}/{filename}
https://cdn.ekonomi-lokal.com/products/1/abc123.jpg

Frontend: 
// API returns: https://cdn.ekonomi-lokal.com/products/1/abc123.jpg
Image.network(productImage.url)
```

---

## 🚨 Common Issues & Solutions

### ❌ Issue 1: "404 - File not found"

**Symptoms:**
- Image uploaded successfully (DB record exists)
- URL returns 404
- Symlink exists

**Root Causes & Solutions:**

```
1. Symlink not created
   Solution:
   $ php artisan storage:link
   
2. Wrong storage disk
   Solution:
   Config: config/filesystems.php
   Check 'disks.public.url' = '/storage'
   
3. File permissions
   Solution:
   $ chmod -R 755 storage/app/public
   $ chmod -R 644 storage/app/public/products/*
   
4. Nginx configuration
   Solution:
   Ensure public/storage is aliased to storage/app/public
   location /storage {
       alias /path/to/app/storage/app/public;
   }
```

### ❌ Issue 2: "CORS Error on Frontend"

**Symptoms:**
- Upload works
- Image URL works in browser
- Image.network() fails in Flutter

**Root Causes & Solutions:**

```
1. Missing CORS headers
   Solution: Check config/cors.php
   'allowed_origins' => ['http://localhost:3000', 'http://10.0.0.1:8000'],
   
2. Image served from different domain
   Solution: Add CORS middleware
   // routes/api.php
   Route::get('/image/{path}', function() {
       return response()
           ->header('Access-Control-Allow-Origin', '*')
           ->header('Access-Control-Allow-Methods', 'GET')
           ...
   })
   
3. Flutter app CORS setting
   Solution: In pubspec.yaml
   dio:
     version: ^5.0.0
   # dio handles CORS automatically if headers are set
```

### ❌ Issue 3: "Upload fails silently"

**Symptoms:**
- No error message
- Network request shows 500
- Database record not created

**Debug Steps:**

```
1. Check Laravel logs
   $ tail -f storage/logs/laravel.log
   
2. Enable debug mode
   APP_DEBUG=true in .env
   
3. Check request validation
   Test with Postman/Insomnia
   
4. Check disk space
   $ df -h
   
5. Check file permissions
   $ ls -la storage/app/public/
```

### ❌ Issue 4: "Token expired error"

**Symptoms:**
- First upload works
- Second upload fails with 401

**Solution:**

```dart
// Frontend: Handle token refresh
Future<Response> uploadProductImages(...) async {
  try {
    return await _dio.post('/umkm/products/$productId/images', 
        data: formData);
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      // Token expired, refresh it
      await _refreshToken();
      // Retry upload
      return await _dio.post('/umkm/products/$productId/images', 
          data: formData);
    }
    rethrow;
  }
}
```

### ❌ Issue 5: "Images not loading after migration"

**Symptoms:**
- Works on local
- Fails on server
- Old images still work

**Solution:**

```
1. Check storage path in production
   APP_URL must match in .env
   
2. Ensure symlink exists
   $ php artisan storage:link
   
3. Check file ownership
   $ sudo chown -R www-data:www-data storage/
   
4. Verify image URLs in DB
   SELECT url FROM product_images;
   → URL should start with http:// and be accessible
```

---

## 📝 Monitoring & Maintenance

### Regular Checks

```bash
# Check storage usage
du -sh storage/app/public/

# Monitor image count
mysql> SELECT COUNT(*) FROM product_images;

# Find orphaned images (product deleted but image remains)
mysql> SELECT pi.* FROM product_images pi 
       LEFT JOIN products p ON pi.product_id = p.id 
       WHERE p.id IS NULL;

# Check for missing files (record exists but file doesn't)
mysql> SELECT pi.* FROM product_images pi 
       WHERE NOT EXISTS (
           SELECT 1 FROM information_schema.files f 
           WHERE f.file_name = pi.url
       );
```

### Cleanup Tasks

```php
// app/Console/Commands/CleanupOrphanedImages.php
public function handle() {
    $orphaned = ProductImage::whereDoesntHave('product')->get();
    foreach ($orphaned as $image) {
        Storage::disk('public')->delete($image->url);
        $image->delete();
    }
}

// Schedule in app/Console/Kernel.php
protected function schedule(Schedule $schedule) {
    $schedule->command('images:cleanup-orphaned')
        ->daily()
        ->at('02:00');
}
```

---

**Last Updated:** 2026-07-07  
**Status:** Documentation Complete
