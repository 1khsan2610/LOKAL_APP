# Platform LOKAL - API Endpoints Reference

**API Base URL:** `https://api.lokal.id/v1` (Production)  
**Dev URL:** `http://localhost:8000/api/v1`

## Authentication Endpoints

### 1. Request OTP
```
POST /auth/request-otp
Content-Type: application/json

{
  "phone_number": "081234567890"
}

Response: 200 OK
{
  "success": true,
  "message": "OTP berhasil dikirim. Berlaku 5 menit.",
  "phone_number": "0812****7890"
}
```

### 2. Verify OTP & Get Token
```
POST /auth/verify-otp
Content-Type: application/json

{
  "phone_number": "081234567890",
  "code": "123456",
  "name": "John Doe",
  "role": "consumer"  // consumer, umkm, or producer
}

Response: 200 OK
{
  "success": true,
  "message": "Verifikasi berhasil",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { ... }
}
```

### 3. Refresh Token
```
POST /auth/refresh
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### 4. Logout
```
DELETE /auth/logout
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "message": "Logout berhasil"
}
```

---

## Product Endpoints

### 1. Get All Products (with filters)
```
GET /products?search=mie&category=makanan&min_price=5000&max_price=50000&min_rating=4&per_page=20
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": [{ product }, ...],
  "pagination": { ... }
}
```

### 2. Get Product Details
```
GET /products/{id}
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": { product }
}
```

### 3. Create Product (UMKM only)
```
POST /products
Content-Type: multipart/form-data
Authorization: Bearer <token>

{
  "name": "Mie Ayam",
  "description": "Mie ayam lezat homemade",
  "category": "Makanan",
  "price": 15000,
  "cost_price": 8000,
  "stock": 50,
  "weight": 300,
  "images": [file1, file2, ...]
}

Response: 201 Created
{
  "success": true,
  "message": "Produk berhasil dibuat",
  "data": { product }
}
```

### 4. Update Product (UMKM owner only)
```
PATCH /products/{id}
Content-Type: application/json
Authorization: Bearer <token>

{
  "price": 16000,
  "stock": 45,
  "is_active": true
}

Response: 200 OK
{
  "success": true,
  "message": "Produk berhasil diperbarui",
  "data": { product }
}
```

### 5. Delete Product
```
DELETE /products/{id}
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "message": "Produk berhasil dihapus"
}
```

---

## Market/UMKM Endpoints

### 1. Get Nearby UMKM (for map)
```
GET /umkm/nearby?latitude=-6.9174&longitude=107.6191&radius=5
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": [{ umkm }, ...],
  "pagination": { ... }
}
```

### 2. Get All Verified UMKM
```
GET /umkm?search=toko&min_rating=4
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": [{ umkm }, ...],
  "pagination": { ... }
}
```

### 3. Get UMKM Details
```
GET /umkm/{id}
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": { umkm }
}
```

---

## Order Endpoints

### 1. Create Order
```
POST /orders
Content-Type: application/json
Authorization: Bearer <token>

{
  "items": [
    {
      "product_id": 1,
      "quantity": 2
    },
    {
      "product_id": 3,
      "quantity": 1
    }
  ],
  "delivery_address": "Jalan Merdeka No. 123, Bandung",
  "notes": "Tolong dikemas dengan baik"
}

Response: 201 Created
{
  "success": true,
  "message": "Pesanan berhasil dibuat",
  "data": {
    "order": { ... },
    "payment": {
      "snap_token": "...",
      "payment_id": 123
    }
  }
}
```

### 2. Get My Orders
```
GET /orders?status=completed&start_date=2025-05-01&end_date=2025-05-31
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": [{ order }, ...],
  "pagination": { ... }
}
```

### 3. Get Order Details
```
GET /orders/{id}
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": { order }
}
```

### 4. Update Order Status (UMKM only)
```
PATCH /orders/{id}/status
Content-Type: application/json
Authorization: Bearer <token>

{
  "status": "completed"  // pending, confirmed, processing, completed, cancelled
}

Response: 200 OK
{
  "success": true,
  "message": "Status pesanan berhasil diubah",
  "data": { order }
}
```

### 5. Get UMKM Orders (UMKM only)
```
GET /umkm/orders?status=pending&start_date=2025-05-01
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": [{ order }, ...],
  "pagination": { ... }
}
```

---

## Review Endpoints

### 1. Create Review
```
POST /reviews
Content-Type: application/json
Authorization: Bearer <token>

{
  "order_id": 1,
  "product_id": 5,
  "rating": 5,
  "comment": "Produk bagus, cepat sampai!"
}

Response: 201 Created
{
  "success": true,
  "message": "Ulasan berhasil dikirim. Anda mendapat 5 Lokal Coin!",
  "data": { review }
}
```

### 2. Get Product Reviews
```
GET /products/{id}/reviews?rating=5
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": [{ review }, ...],
  "pagination": { ... }
}
```

### 3. Get UMKM Reviews
```
GET /umkm/{id}/reviews?rating=4
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": [{ review }, ...],
  "pagination": { ... }
}
```

---

## Wallet (Lokal Coin) Endpoints

### 1. Get Balance
```
GET /wallet/balance
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": {
    "user_id": 1,
    "balance": 250.50,
    "total_earned": 500.00,
    "total_spent": 249.50
  }
}
```

### 2. Get Transaction History
```
GET /wallet/history?type=earn&source=transaction_reward&start_date=2025-05-01&per_page=20
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": [{ transaction }, ...],
  "pagination": { ... }
}
```

### 3. Check Expiring Coins
```
GET /wallet/expiring-coins
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": {
    "total_expiring": 50.00,
    "expiring_date": "2025-06-12"
  }
}
```

---

## Payment Endpoints

### 1. Get Payment Status
```
GET /payments/status?transaction_id=ORD-20250512123456-1234
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "status": "success",
  "data": { ... }
}
```

### 2. Midtrans Webhook (POST)
```
POST /payments/midtrans-webhook
Content-Type: application/json

{
  "transaction_time": "2025-05-12 12:34:56",
  "transaction_status": "settlement",
  "payment_type": "qris",
  "order_id": "ORD-20250512123456-1234",
  "gross_amount": "150000.00",
  "fraud_status": "accept",
  ...
}

Response: 200 OK
{
  "success": true,
  "message": "Notification processed"
}
```

---

## UMKM Analytics Endpoints

### 1. Get Analytics Summary (UMKM owner only)
```
GET /umkm/analytics/summary?date_range=month
Authorization: Bearer <token>

Response: 200 OK
{
  "success": true,
  "data": {
    "umkm_id": 1,
    "business_name": "Toko Mie Ayam Andalan",
    "rating": 4.8,
    "total_reviews": 25,
    "summary": {
      "total_revenue": 1500000.00,
      "total_orders": 50,
      "completed_orders": 48,
      "total_products": 10,
      "active_products": 8,
      "conversion_rate": 96
    },
    "top_products": [ ... ],
    "recent_reviews": [ ... ],
    "period": {
      "start_date": "2025-05-01",
      "end_date": "2025-05-31",
      "range": "month"
    }
  }
}
```

---

## Error Responses

### 401 Unauthorized
```json
{
  "message": "Unauthenticated."
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "Anda tidak memiliki akses untuk resource ini."
}
```

### 422 Validation Error
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["Email harus valid"],
    "phone_number": ["Nomor telepon tidak valid"]
  }
}
```

### 500 Server Error
```json
{
  "success": false,
  "message": "Internal Server Error"
}
```

---

## Rate Limiting

- OTP/Login: **5 requests per minute per IP**
- General API: **100 requests per minute per token**
- Payment endpoints: **10 requests per minute per token**

---

## Headers Required

All requests (except login/OTP) should include:
```
Authorization: Bearer <your_token>
Accept: application/json
Content-Type: application/json
```

---

**Last Updated:** May 2025
**API Version:** 1.0.0
