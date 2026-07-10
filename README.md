# 🌿 EkonomiLokal — Platform E-Commerce UMKM Digital

Platform e-commerce berbasis Flutter (frontend) + Laravel 11 (backend) untuk mendukung UMKM lokal Indonesia.

---

## 📁 Struktur Project

```
ekonomi_lokal/
├── backend/          # Laravel 11 API
│   ├── app/
│   │   ├── Http/Controllers/Api/
│   │   │   ├── AuthController.php
│   │   │   ├── ProductController.php
│   │   │   ├── OrderController.php
│   │   │   ├── PaymentController.php
│   │   │   ├── AiChatController.php
│   │   │   └── ...
│   │   ├── Models/
│   │   ├── Services/
│   │   │   ├── CoinService.php
│   │   │   └── NotificationService.php
│   │   └── Http/Middleware/
│   ├── database/migrations/
│   ├── routes/api.php
│   ├── docker-compose.yml
│   └── Dockerfile
└── frontend/         # Flutter App
    ├── lib/
    │   ├── main.dart
    │   ├── models/
    │   ├── providers/
    │   ├── screens/
    │   │   ├── auth/
    │   │   ├── home/
    │   │   ├── product/
    │   │   ├── cart/
    │   │   ├── checkout/
    │   │   ├── order/
    │   │   ├── profile/
    │   │   ├── wallet/
    │   │   ├── notification/
    │   │   ├── map/
    │   │   ├── admin/
    │   │   └── umkm/
    │   ├── services/
    │   ├── utils/
    │   └── widgets/
    └── pubspec.yaml
```

---

## 🚀 Cara Menjalankan

### Prerequisites
- **Docker Desktop** (terinstall dan berjalan)
- **Flutter SDK** >= 3.2.0
- **Android Studio** / **Xcode** (untuk emulator)

---

### 🔧 Backend (Laravel + Docker)

#### 1. Masuk ke folder backend
```bash
cd ekonomi_lokal/backend
```

#### 2. Copy environment file
```bash
cp .env.example .env
```

#### 3. Edit `.env` sesuai kebutuhan
```env
# Midtrans (daftar di https://midtrans.com)
MIDTRANS_SERVER_KEY=SB-Mid-server-xxxx
MIDTRANS_CLIENT_KEY=SB-Mid-client-xxxx
MIDTRANS_IS_PRODUCTION=false

# Gemini AI (daftar di https://aistudio.google.com)
GEMINI_API_KEY=AIzaxxxxxxxxxx

# FCM (Firebase Cloud Messaging)
FCM_SERVER_KEY=AAAAxxxxxxxxxx
```

#### 4. Jalankan Docker Compose
```bash
docker-compose up -d
```

#### 5. Generate app key & JWT secret
```bash
docker exec ekonomi_lokal_app php artisan key:generate
docker exec ekonomi_lokal_app php artisan jwt:secret
```

#### 6. Jalankan migrasi & seeder
```bash
docker exec ekonomi_lokal_app php artisan migrate --seed
```

#### 7. Link storage
```bash
docker exec ekonomi_lokal_app php artisan storage:link
```

**API berjalan di:** `http://localhost:8000/api`

---

### 📱 Frontend (Flutter)

#### 1. Masuk ke folder frontend
```bash
cd ekonomi_lokal/frontend
```

#### 2. Install dependencies
```bash
flutter pub get
```

#### 3. Setup Firebase (untuk push notification)
- Buat project di [Firebase Console](https://console.firebase.google.com)
- Download `google-services.json` → taruh di `android/app/`
- Download `GoogleService-Info.plist` → taruh di `ios/Runner/`

#### 4. Konfigurasi API URL
Edit `lib/services/api_service.dart`:
```dart
// Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000/api';

// iOS Simulator
// static const String baseUrl = 'http://localhost:8000/api';

// Device fisik (ganti dengan IP komputer kamu)
// static const String baseUrl = 'http://192.168.1.100:8000/api';

// Production
// static const String baseUrl = 'https://api.ekonomilokal.id/api';
```

#### 5. Jalankan aplikasi
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Dengan device tertentu
flutter devices
flutter run -d <device_id>
```

---

## 🔑 Akun Demo

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@ekonomilokal.id | password123 |
| UMKM | busari@test.com | password123 |
| Konsumen | budi@test.com | password123 |

---

## 📦 Services yang Berjalan (Docker)

| Service | Port | Keterangan |
|---------|------|------------|
| Laravel App | 8000 | API Backend |
| MySQL | 3306 | Database |
| Redis | 6379 | Cache & Queue |
| MinIO | 9000 | Object Storage (gambar) |
| MinIO Console | 9001 | UI MinIO |

---

## 🗺️ API Endpoints

### Auth
```
POST   /api/auth/register-account
POST   /api/auth/login
POST   /api/auth/logout
GET    /api/auth/me
POST   /api/auth/refresh
POST   /api/auth/forgot-password
POST   /api/auth/reset-password
```

### Products
```
GET    /api/products              # List produk (filter & pagination)
GET    /api/products/search?q=   # Pencarian produk
GET    /api/products/flash-sale  # Flash sale products
GET    /api/products/{id}        # Detail produk
GET    /api/products/{id}/reviews
```

### Orders
```
GET    /api/orders               # Daftar pesanan
POST   /api/orders               # Buat pesanan baru
GET    /api/orders/{id}          # Detail pesanan
PATCH  /api/orders/{id}/cancel
PATCH  /api/orders/{id}/confirm-received
```

### Payment (Midtrans)
```
POST   /api/payment/create       # Create Snap token
GET    /api/payment/status/{id}
POST   /api/payment/notification # Webhook Midtrans (public)
```

### Cart
```
GET    /api/cart
POST   /api/cart
PUT    /api/cart/{itemId}
DELETE /api/cart/{itemId}
DELETE /api/cart               # Clear all
```

### Wallet & Coin
```
GET    /api/wallet
GET    /api/wallet/transactions
```

### UMKM Dashboard
```
GET    /api/umkm/my-store
POST   /api/umkm/products
PUT    /api/umkm/products/{id}
DELETE /api/umkm/products/{id}
GET    /api/umkm/orders
PATCH  /api/umkm/orders/{id}/status
GET    /api/umkm/analytics/summary
```

### Admin
```
GET    /api/admin/dashboard
GET    /api/admin/users
GET    /api/admin/umkm
GET    /api/admin/orders
GET    /api/admin/analytics
PATCH  /api/admin/umkm/{id}/verify
```

### AI Chat (Gemini)
```
POST   /api/ai/chat
  Body: { "message": "string", "history": [] }
```

---

## 🎨 Fitur Lengkap

### 👤 Role & Permission
| Fitur | Konsumen | UMKM | Admin |
|-------|----------|------|-------|
| Belanja & Checkout | ✅ | ✅ | ✅ |
| Kelola Produk | ❌ | ✅ | ✅ |
| Dashboard Analitik UMKM | ❌ | ✅ | ✅ |
| Admin Panel | ❌ | ❌ | ✅ |
| Verifikasi UMKM | ❌ | ❌ | ✅ |

### 🛒 E-Commerce
- Katalog produk dengan kategori & filter
- Flash sale dengan countdown timer
- Pencarian produk real-time
- Keranjang belanja
- Checkout multi-step
- Riwayat & tracking pesanan
- Ulasan produk

### 💳 Pembayaran
- Midtrans Payment Gateway
- BCA Transfer, Mandiri, GoPay, OVO, DANA, QRIS
- Notifikasi webhook otomatis

### 🪙 Lokal Coin
- Reward otomatis setiap pembelian
- Diskon hingga 20% dari subtotal
- Coin kadaluwarsa 90 hari
- Riwayat transaksi coin

### 🗺️ Peta UMKM
- Google Maps integration
- Filter UMKM terdekat berdasarkan radius
- Navigasi ke lokasi UMKM

### 🔔 Notifikasi
- Push notification (FCM/APNs)
- Notifikasi pesanan & pembayaran
- Promo & Lokal Coin notification

### 🤖 AI Chat (Gemini)
- Chatbot berbasis Google Gemini
- Context-aware tentang produk UMKM
- Rate limiting 30 req/menit per user

---

## 🔒 Keamanan
- JWT RS256 authentication
- Role-based access control (RBAC)
- Rate limiting per endpoint
- Input validation & sanitization
- Midtrans signature verification
- HTTPS enforced di production

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x + Provider |
| Backend | Laravel 11 + PHP 8.2 |
| Database | MySQL 8.0 |
| Cache/Queue | Redis 7 |
| Storage | MinIO (S3-compatible) |
| Auth | JWT (tymon/jwt-auth) |
| Payment | Midtrans Snap |
| AI Chat | Google Gemini 1.5 Flash |
| Push Notif | FCM (Firebase) |
| Container | Docker + Docker Compose |
| Maps | Google Maps Flutter |

---

## 📞 Support

Untuk pertanyaan teknis, hubungi tim developer EkonomiLokal.
