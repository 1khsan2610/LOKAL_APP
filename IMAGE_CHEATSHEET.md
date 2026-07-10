# 📋 Quick Reference: Image Upload Cheat Sheet

## 🚀 Quick Start (5 Minutes)

### What's Already Implemented?
✅ Product model with image relationships  
✅ ProductImage model & database table  
✅ API endpoint to upload images  
✅ Frontend image picker  
✅ Multi-file upload support  
✅ Storage management (dev/prod)  

### How It Works?
1. Flutter picks images via ImagePicker
2. Creates product via API
3. Uploads images to `/api/umkm/products/{id}/images`
4. Backend stores files + creates DB records
5. URLs returned to frontend for display

---

## 🔗 API Endpoints

### Create Product
```http
POST /api/umkm/products
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Product Name",
  "price": 25000,
  "stock": 100,
  "category": "makanan",
  "weight": 250,
  "description": "Description..."
}

✅ 201 Created
{
  "success": true,
  "data": { "id": 42, ... }
}
```

### Upload Images
```http
POST /api/umkm/products/{productId}/images
Authorization: Bearer {token}
Content-Type: multipart/form-data

Form Data:
- images[]: [file1.jpg, file2.jpg, ...]

✅ 200 OK
{
  "success": true,
  "data": [
    {
      "id": 101,
      "product_id": 42,
      "url": "http://server/storage/products/42/abc.jpg",
      "is_primary": true
    }
  ]
}
```

### Get Product with Images
```http
GET /api/products/{id}

✅ 200 OK
{
  "success": true,
  "data": {
    "id": 42,
    "name": "...",
    "images": [
      { "url": "...", "is_primary": true },
      { "url": "...", "is_primary": false }
    ]
  }
}
```

---

## 🎨 Frontend Code Snippets

### Pick Images
```dart
final picker = ImagePicker();
final picked = await picker.pickMultiImage(imageQuality: 80);
// Returns: List<XFile>
```

### Upload Images
```dart
// Already implemented in ApiService!
await apiService.uploadProductImages(productId, fileList);
```

### Display Image
```dart
Image.network(
  productImage.url,
  fit: BoxFit.cover,
  errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported),
)
```

---

## 🔙 Backend Code Reference

### ProductController.uploadImages() Location
**File:** `backend/app/Http/Controllers/Api/ProductController.php`  
**Lines:** 223-293  
**Method:** `public function uploadImages(Request $request, $id)`

### Key Methods
```php
// Store file
$path = $image->store("products/{$product->id}", $disk);

// Create record
$product->images()->create([
  'url' => Storage::disk($disk)->url($path),
  'is_primary' => $product->images()->count() === 0,
]);

// Get image
$product->images; // Returns collection
$product->primaryImage; // Returns primary image URL
```

### ProductImage Model
**File:** `backend/app/Models/ProductImage.php`

```php
class ProductImage extends Model {
    protected $fillable = ['product_id', 'url', 'is_primary'];
    
    public function product() {
        return $this->belongsTo(Product::class);
    }
}
```

---

## 🗄️ Database Quick Lookup

### product_images Table Structure
```sql
id (BIGINT)
product_id (BIGINT) - Foreign key
url (VARCHAR 500) - Full path/URL
is_primary (BOOLEAN) - True for main image
file_size (INT) - Optional
mime_type (VARCHAR 50) - Optional
position (INT) - For reordering
created_at, updated_at (TIMESTAMP)
```

### Get All Images for Product
```sql
SELECT * FROM product_images 
WHERE product_id = 42 
ORDER BY is_primary DESC, created_at ASC;
```

### Get Primary Image Only
```sql
SELECT * FROM product_images 
WHERE product_id = 42 AND is_primary = true;
```

---

## 📱 File Types & Limits

| Parameter | Limit | Reason |
|-----------|-------|--------|
| **Max file size** | 5 MB | Storage optimization |
| **Max files** | 5 per upload | API performance |
| **Allowed types** | JPEG, PNG, WebP | Web standards |
| **Min dimensions** | 300x300 px | Quality assurance |
| **Image quality** | 75% (optimized) | Compression |
| **Storage** | Local (dev) / S3 (prod) | Flexibility |

---

## 🛣️ File Path Examples

### Development
```
Disk: storage/app/public
URL:  http://localhost/storage/products/42/abc123.jpg
Path: storage/app/public/products/42/abc123.jpg
```

### Production (S3)
```
Disk: s3
URL:  https://cdn.example.com/products/42/abc123.jpg
Path: s3://bucket/products/42/abc123.jpg
```

---

## 🧪 Testing Commands

### Test Upload
```bash
cd backend
php artisan test tests/Feature/ProductImageUploadTest.php

# Or specific test
php artisan test tests/Feature/ProductImageUploadTest.php --filter test_upload_multiple_images
```

### Test with Postman
```
1. Create product first
   POST http://localhost/api/umkm/products
   
2. Note the product ID (e.g., 42)

3. Upload images
   POST http://localhost/api/umkm/products/42/images
   
   Headers:
   - Authorization: Bearer {your_token}
   
   Body (form-data):
   - images: [select files]
```

---

## 🔒 Security Checklist

- ✅ JWT authentication required
- ✅ UMKM ownership verification
- ✅ File type whitelist (JPEG/PNG/WebP)
- ✅ File size limit (5MB)
- ✅ File count limit (5 per request)
- ✅ Filename randomization
- ✅ SQL injection prevention (ORM)
- ✅ Disk permissions restricted
- ✅ Environment-specific storage
- ✅ Error messages don't leak paths

---

## 🐛 Quick Troubleshooting

### "404 - Image not found"
```bash
# Check symlink
php artisan storage:link

# Check file permissions
chmod -R 755 storage/app/public
```

### "Upload returns 422"
```
Check:
- File size < 5MB
- File type is JPEG/PNG/WebP
- Not more than 5 files
- Image dimensions > 300x300
```

### "Upload returns 401"
```
Check:
- Token is present
- Token is valid (not expired)
- Authorization header format: Bearer {token}
```

### "Upload returns 403"
```
Check:
- UMKM account exists
- User owns the UMKM
- UMKM is verified
```

### "Upload returns 500"
```
Check:
$ tail -f storage/logs/laravel.log

Common causes:
- Disk space full: df -h
- Permission denied: chmod -R 755 storage/
- Database error: Check schema
```

---

## 🚀 Next Steps to Improve

### 1. Delete Image (Easy) ⭐
```php
Route::delete('/umkm/products/{productId}/images/{imageId}', 
    [ProductController::class, 'deleteImage']);
```

### 2. Set Primary Image (Easy) ⭐
```php
Route::patch('/umkm/products/{productId}/images/{imageId}/set-primary',
    [ProductController::class, 'setPrimaryImage']);
```

### 3. Image Optimization (Medium) ⭐⭐
```php
// Resize to 1200x1200, compress to 75% quality
Image::make($image)->resize(1200, 1200)->encode('jpg', 75);
```

### 4. Upload Progress (Medium) ⭐⭐
```dart
await _dio.post(url, data: form,
    onSendProgress: (sent, total) => print('${sent/total*100}%'));
```

### 5. Image Reordering (Medium) ⭐⭐
```php
// Add 'position' field to ProductImage
// Allow PATCH to reorder by position
```

---

## 📚 File Reference

| File | Purpose | Language |
|------|---------|----------|
| ProductController.php | Main upload logic | PHP |
| ProductImage.php | Image model | PHP |
| Product.php | Product model | PHP |
| api.php | API routes | PHP |
| ApiService.dart | API client | Dart |
| AddEditProductScreen.dart | Image picker UI | Dart |
| ProductImageUploadTest.php | Tests | PHP |

---

## 💾 Useful SQL Queries

### Find unused images
```sql
SELECT pi.* FROM product_images pi
WHERE pi.product_id NOT IN (SELECT id FROM products);
```

### Count images per product
```sql
SELECT product_id, COUNT(*) as image_count 
FROM product_images 
GROUP BY product_id 
ORDER BY image_count DESC;
```

### Check storage usage
```sql
SELECT SUM(file_size) as total_bytes, 
       COUNT(*) as total_images 
FROM product_images;
```

### List all primary images
```sql
SELECT * FROM product_images WHERE is_primary = true;
```

---

## 🔄 Common Workflows

### Workflow 1: Upload New Product
```
1. Flutter: Create product data
2. API: POST /api/umkm/products → Get product_id
3. Flutter: Pick images
4. API: POST /api/umkm/products/{id}/images
5. Flutter: Show success, navigate to list
```

### Workflow 2: Update Product Images
```
1. Flutter: Get product with images
2. Flutter: Pick new images
3. API: POST /api/umkm/products/{id}/images → Add new
4. Flutter: Delete unwanted images (future feature)
5. API: DELETE /api/umkm/products/{id}/images/{imageId}
```

### Workflow 3: View Product
```
1. Flutter: GET /api/products/{id}
2. Backend: Return product + images
3. Flutter: Image.network(productImage.url)
4. Browser: Check cache (30 days)
5. Display: Load cached or fetch fresh
```

---

## 📊 Performance Tips

### For Faster Uploads
1. ✅ Compress on frontend (quality: 80)
2. ✅ Limit files per upload (5 max)
3. ✅ Show upload progress
4. ✅ Optimize images on backend

### For Faster Display
1. ✅ Cache images 30 days
2. ✅ Use CDN (S3 + CloudFront)
3. ✅ Lazy load below fold
4. ✅ Use ETag for validation

### For Better UX
1. ✅ Show preview before upload
2. ✅ Display upload progress
3. ✅ Allow image deletion
4. ✅ Allow primary image selection
5. ✅ Show error messages clearly

---

## 🎯 Success Criteria

Your image sync is working correctly if:

- ✅ Images upload successfully
- ✅ URLs are generated correctly
- ✅ Database records created
- ✅ Images load in frontend
- ✅ Primary image logic works
- ✅ Different products have separate folders
- ✅ Error messages are clear
- ✅ Tests pass
- ✅ No sensitive info in errors
- ✅ Storage quota monitored

---

**Need Help?** Check IMAGE_GUIDE.md or IMAGE_ARCHITECTURE.md  
**Want Improvements?** See IMAGE_IMPROVEMENTS.md  
**Having Issues?** See troubleshooting section above
