# Platform LOKAL Backend API

Platform Digital Berbasis Mobile untuk Optimalisasi Sirkulasi Ekonomi Lokal

## Overview

Backend API untuk Platform LOKAL - aplikasi marketplace mobile yang menghubungkan konsumen dengan UMKM lokal menggunakan sistem token Lokal Coin dan analitik berbasis ML.

**Dokumentasi SRS:** Lihat file `SRS.md` untuk spesifikasi lengkap.

## Tech Stack

- **Framework:** Laravel 11 (PHP 8.3)
- **Database:** MySQL 8.0
- **Cache:** Redis 7.2
- **Storage:** MinIO (S3-compatible)
- **Payment:** Midtrans SNAP API
- **SMS:** Twilio
- **Automation:** n8n
- **ML:** Python/FastAPI

## Installation

### Prerequisites

- PHP 8.3+
- MySQL 8.0+
- Redis 7.2+
- Composer
- Docker (optional)

### Setup Steps

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd backend
   ```

2. **Install Dependencies**
   ```bash
   composer install
   ```

3. **Environment Configuration**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` dan sesuaikan konfigurasi:
   ```env
   # Database
   DB_HOST=127.0.0.1
   DB_DATABASE=lokal
   DB_USERNAME=root
   DB_PASSWORD=

   # Redis
   REDIS_HOST=127.0.0.1
   REDIS_PORT=6379
   CACHE_DRIVER=redis
   SESSION_DRIVER=redis

   # Midtrans Payment Gateway
   MIDTRANS_SERVER_KEY=your_server_key
   MIDTRANS_CLIENT_KEY=your_client_key
   MIDTRANS_IS_PRODUCTION=false

   # Twilio SMS
   TWILIO_ACCOUNT_SID=your_account_sid
   TWILIO_AUTH_TOKEN=your_auth_token
   TWILIO_FROM_NUMBER=+1234567890

   # Google Maps
   GOOGLE_MAPS_API_KEY=your_api_key

   # MinIO Storage
   MINIO_KEY=minioadmin
   MINIO_SECRET=minioadmin
   MINIO_URL=http://localhost:9000
   MINIO_ENDPOINT=http://minio:9000
   ```

4. **Generate Application Key**
   ```bash
   php artisan key:generate
   ```

5. **Run Migrations**
   ```bash
   php artisan migrate
   ```

6. **Seed Database (Optional)**
   ```bash
   php artisan db:seed
   ```

7. **Start Development Server**
   ```bash
   php artisan serve
   ```

   Server akan berjalan di `http://localhost:8000`

## API Documentation

### Base URL
```
http://localhost:8000/api/v1
```

### Authentication
Semua endpoint yang terlindungi memerlukan Bearer Token:
```
Authorization: Bearer <token>
```

### Key Endpoints

#### Authentication (F-01)
- `POST /auth/request-otp` - Minta OTP
- `POST /auth/verify-otp` - Verifikasi OTP & dapatkan token
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Logout

#### Products (F-02)
- `GET /products` - Daftar produk
- `GET /products/{id}` - Detail produk
- `POST /products` - Buat produk (UMKM)
- `PATCH /products/{id}` - Update produk (UMKM)
- `DELETE /products/{id}` - Hapus produk (UMKM)
- `GET /products/category/{category}` - Produk per kategori

#### Market/UMKM (F-02)
- `GET /umkm/nearby?latitude=...&longitude=...&radius=5` - UMKM terdekat
- `GET /umkm` - Daftar UMKM terverifikasi
- `GET /umkm/{id}` - Detail UMKM

#### Orders (F-03)
- `POST /orders` - Buat pesanan
- `GET /orders` - Riwayat pesanan (consumer)
- `GET /orders/{id}` - Detail pesanan
- `PATCH /orders/{id}/status` - Update status (UMKM)
- `GET /umkm/orders` - Pesanan UMKM

#### Wallet/Lokal Coin (F-04)
- `GET /wallet/balance` - Saldo koin
- `GET /wallet/history` - Riwayat transaksi
- `GET /wallet/expiring-coins` - Notifikasi koin kadaluarsa

#### Payments (F-03)
- `POST /payments/midtrans-webhook` - Webhook Midtrans
- `GET /payments/status` - Status pembayaran

#### Reviews & Ratings
- `POST /reviews` - Buat ulasan
- `GET /products/{id}/reviews` - Review produk
- `GET /umkm/{id}/reviews` - Review UMKM

#### Analytics (F-06)
- `GET /umkm/analytics/summary` - Dashboard UMKM

### Response Format

**Success Response:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {}
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error message",
  "errors": {}
}
```

## Features Implementation

### F-01: Authentication & Users
- ✅ OTP SMS via Twilio (6 digit, 5 menit)
- ✅ Multi-role: consumer, UMKM, producer
- ✅ JWT RS256 tokens
- ✅ Rate limiting: 5 req/menit per IP
- ✅ Automatic Lokal Coin 50 coins pada registrasi

### F-02: Market & Products
- ✅ Google Maps integration (nearby search)
- ✅ Product CRUD dengan foto (max 5 x 2MB)
- ✅ Geospatial queries (0.5-10 km radius)
- ✅ Full-text search & filtering
- ✅ Category & rating filters

### F-03: Transactions & Payments
- ✅ Multi-UMKM cart
- ✅ Midtrans SNAP payment
- ✅ Support: GoPay, OVO, DANA, VA, QRIS
- ✅ 30 menit payment expiration
- ✅ Webhook validation (SHA-512)
- ✅ Order status tracking

### F-04: Lokal Coin & Incentives
- ✅ 2% reward per transaction
- ✅ 5 coins per review
- ✅ Max 20% diskon per order
- ✅ 6 bulan expiration
- ✅ Auto-expire & notifications

### F-05: ML Price Recommendations
- 📝 Integration with Python/FastAPI service
- 📝 Async price analysis (5 km radius)
- 📝 Graceful degradation

### F-06: UMKM Analytics Dashboard
- ✅ Revenue tracking
- ✅ Sales graphs (daily/weekly/monthly)
- ✅ Top products
- ✅ Order metrics
- ✅ Real-time updates

### F-07: Notifications & Automation
- ✅ In-app notifications
- 📝 FCM/APNs push notifications
- 📝 SMS via Twilio/n8n
- 📝 Automated workflows via n8n

## Database Schema

### Core Tables
- `users` - User profiles (consumer, UMKM, producer)
- `umkm_profiles` - UMKM details & verification
- `products` - Product catalog
- `product_images` - Product photos
- `orders` - Pesanan
- `order_items` - Order line items
- `payments` - Payment records
- `reviews` - Product reviews

### Business Logic Tables
- `lokal_coin_balances` - User coin balance
- `lokal_coin_transactions` - Transaction history
- `notifications` - User notifications
- `otp_codes` - OTP verification

### Audit Tables
- `audit_logs` - Financial transaction logs

## Development Guidelines

### Code Style
- PSR-12 coding standard
- Laravel conventions
- Meaningful variable names
- Comprehensive comments

### Testing
```bash
# Run tests
php artisan test

# Run with coverage
php artisan test --coverage

# Specific test
php artisan test tests/Feature/AuthTest.php
```

### API Documentation
- OpenAPI 3.0 via Postman Collection
- Auto-generated docs via Scribe (planned)

## Deployment

### Docker Setup
```bash
# Build & run with Docker
docker-compose up -d

# Migrate database
docker-compose exec app php artisan migrate

# Seed data
docker-compose exec app php artisan db:seed
```

### Production Checklist
- [ ] Set `APP_ENV=production`
- [ ] Set `APP_DEBUG=false`
- [ ] Generate APP_KEY
- [ ] Enable HTTPS/TLS 1.2+
- [ ] Configure Redis sessions
- [ ] Enable rate limiting middleware
- [ ] Setup automated backups
- [ ] Configure error logging
- [ ] Setup monitoring & alerts

## Common Issues & Troubleshooting

### OTP SMS Not Received
- Check Twilio credentials in `.env`
- Verify phone number format (08xx... or +62xxx...)
- Check Twilio account balance

### Payment Gateway Issues
- Verify Midtrans credentials
- Check if in production/sandbox mode
- Review Midtrans webhook logs

### Database Connection
- Ensure MySQL is running
- Check credentials in `.env`
- Verify database exists

## Performance Targets

- API response time: < 500ms (90th percentile)
- ML Service: < 3 seconds
- Map rendering: < 2 seconds (100+ markers)
- Concurrent users: 10,000 (pilot phase)
- Uptime: >= 99.5% monthly

## Security

- HTTPS/TLS 1.2+ enforced
- Data encryption: AES-256
- Rate limiting on sensitive endpoints
- JWT RS256 tokens
- CORS protection
- Input validation & sanitization
- SQL injection prevention
- CSRF protection
- Audit logging for transactions

## Compliance

- ✅ UU PDP No. 27/2022 (Pelindungan Data Pribadi)
- ✅ OJK/BI regulations (Payment Gateway)
- ✅ OWASP Top 10 protection
- ✅ Server location: Indonesia

## Support & Contribution

Untuk issues atau pertanyaan:
- Create issue di GitHub
- Email: dev@lokal.id

## License

Proprietary - Platform LOKAL 2025

## References

- [Laravel 11 Docs](https://laravel.com/docs/11.x)
- [Midtrans Docs](https://docs.midtrans.com)
- [Twilio Docs](https://www.twilio.com/docs)
- [Google Maps API](https://developers.google.com/maps)

---

**Last Updated:** May 2025
**Version:** 1.1.0
