# 🌿 LOKAL — Platform Digital Ekonomi UMKM Lokal

**Platform E-Commerce Mobile** berbasis **Flutter** (frontend) + **Laravel 11** (backend) untuk mengoptimalkan sirkulasi ekonomi lokal Indonesia, khususnya di wilayah **Bandung Raya** (Kota Bandung, Kab. Bandung, Kab. Bandung Barat, dan Kota Cimahi).

---

## 📋 Daftar Isi

- [Profil & Pengenalan](#profil--pengenalan)
- [Latar Belakang](#latar-belakang)
- [Fitur & Fungsi](#fitur--fungsi)
- [Tampilan Aplikasi (Screens)](#tampilan-aplikasi-screens)
- [Cara Penggunaan](#cara-penggunaan)
- [Infrastruktur](#infrastruktur)
- [Arsitektur Sistem](#arsitektur-sistem)
- [Teknis Instalasi](#teknis-instalasi)
- [API Endpoints](#api-endpoints)
- [Akun Demo](#akun-demo)
- [Tech Stack](#tech-stack)
- [Security](#security)
- [Tim Pengembang](#tim-pengembang)

---

## Profil & Pengenalan

| **Atribut** | **Detail** |
|------------|------------|
| **Nama Aplikasi** | LOKAL (Platform Digital Berbasis Mobile untuk Optimalisasi Sirkulasi Ekonomi Lokal) |
| **Versi** | 1.5.0 — Juli 2026 |
| **Platform** | Android (min. API 24) & iOS (min. 14.0) |
| **Jenis** | Marketplace UMKM Lokal (Closed-loop Economy) |
| **Target Wilayah** | Bandung Raya (Kota Bandung, Kab. Bandung, Kab. Bandung Barat, Kota Cimahi) |

**LOKAL** adalah aplikasi marketplace berbasis lokasi yang menghubungkan **Konsumen** dengan **UMKM lokal** menggunakan:
- 🗺️ **Peta interaktif** untuk menemukan UMKM terdekat
- 🪙 **Lokal Coin** sebagai sistem reward cashback tertutup
- 🤖 **LOKAL AI Assistant** berbasis Google Gemini API
- 📊 **Dashboard analitik** untuk UMKM
- 💳 **Pembayaran digital** via Midtrans (GoPay, OVO, DANA, VA Bank, QRIS)
- 📦 **Tracking pesanan real-time**

---

## Latar Belakang

UMKM merupakan tulang punggung perekonomian Indonesia, namun masih menghadapi tantangan:
1. **Keterbatasan akses digital** — banyak UMKM belum memiliki platform online
2. **Kebocoran ekonomi lokal** — belanja masyarakat lebih banyak ke platform luar daerah
3. **Kesulitan pemasaran** — UMKM kesulitan menjangkau pelanggan potensial di sekitar lokasi
4. **Minimnya data analitik** — UMKM tidak memiliki data penjualan untuk pengembangan bisnis

**LOKAL** hadir sebagai solusi ekosistem ekonomi digital tertutup (closed-loop) yang memberdayakan UMKM lokal dengan teknologi mobile, peta interaktif, sistem insentif, dan AI assistant.

---

## Fitur & Fungsi

Platform LOKAL memiliki **12 fitur sistem utama**:

### 🔐 F-01: Autentikasi & Manajemen Pengguna
- Register Account (backend-driven) untuk role **Konsumen** dan **UMKM**
- Login dengan Email + Password (JWT RS256)
- Verifikasi email otomatis setelah registrasi
- Lupa password via link reset email
- 50 Lokal Coin gratis saat aktivasi akun baru
- Role-based access control: **Konsumen**, **UMKM**, **Admin**

### 🗺️ F-02: Peta Pasar & Katalog Produk
- Peta interaktif Google Maps dengan marker UMKM
- Filter radius pencarian 0.5–10 km
- Pencarian produk berdasarkan nama, kategori, harga, jarak, rating
- CRUD produk oleh UMKM (maks. 5 foto per produk)
- Flash sale dengan countdown timer
- Pagination 20 produk/halaman

### 🛒 F-03: Transaksi & Pembayaran
- Keranjang belanja multi-UMKM
- Checkout multi-step (Keranjang → Konfirmasi → Pembayaran → Sukses)
- Midtrans Payment Gateway: GoPay, OVO, DANA, VA Bank Transfer, QRIS
- Konfirmasi pembayaran **otomatis** via Webhook Midtrans
- Riwayat transaksi lengkap dengan filter

### 🪙 F-04: Lokal Coin & Insentif
- Cashback 2% dari total pembayaran otomatis
- Diskon maks. 20% per transaksi
- 5 koin bonus per ulasan valid
- Coin hangus setelah 6 bulan (notifikasi 30 hari sebelumnya)
- Tidak dapat dikonversi ke fiat (closed-loop)

### 📈 F-05: Rekomendasi Harga ML
- Analisis harga pasar lokal secara asinkron via Python/FastAPI
- Rekomendasi harga untuk produk baru UMKM
- Analisis radius 5 km dari produk sejenis

### 📊 F-06: Dashboard Analitik UMKM
- Grafik penjualan harian/mingguan/bulanan
- Total pendapatan & pertumbuhan %
- Produk terlaris
- Jumlah order, rating, pelanggan baru
- Filter rentang tanggal kustom

### 🔔 F-07: Notifikasi & Otomasi
- Push notification via FCM (Firebase Cloud Messaging)
- Notifikasi: konfirmasi pesanan, pembayaran, update status pengiriman
- Notifikasi stok menipis (< 10 unit)
- Manajemen preferensi notifikasi

### 📦 F-08: Sistem Pelacakan Pesanan (Order Tracking)
- Timeline vertikal riwayat status pesanan real-time
- Nomor resi (tracking number) dari UMKM saat status 'shipped'
- Riwayat perubahan status di tabel `order_histories`
- Status: Pending → Processing → Shipped/In Delivery → Completed/Cancelled

### 💳 F-09: Otomatisasi Pembayaran & Webhook Midtrans
- **Konfirmasi pembayaran OTOMATIS** via webhook (tidak manual)
- Validasi signature SHA-512 dari notifikasi Midtrans
- Distribusi dana otomatis:
  - 5% komisi platform → Admin Wallet
  - 95% + ongkos kirim → Saldo Tunai UMKM
  - 2% cashback Lokal Coin → Konsumen
- Idempotency untuk mencegah double processing

### 🤖 F-10: LOKAL AI Assistant
- Chatbot berbasis **Google Gemini 1.5 Flash**
- Membantu UMKM dan Konsumen dalam Bahasa Indonesia kasual
- 20 request/menit per token pengguna
- API Key tersimpan aman di backend (`.env`)
- Stateless — riwayat chat tidak disimpan di server

### 🏦 F-11: Manajemen Verifikasi Bank & Withdrawal
- UMKM mendaftarkan rekening bank (nama bank, nomor rekening, pemilik)
- Admin melakukan verifikasi (approve/reject) di Dashboard
- Tombol 'Tarik Dana' **disabled** jika bank belum diverifikasi
- Penarikan dana minimum Rp 50.000
- Riwayat penarikan tercatat di `wallet_histories`

### 🔄 F-12: Aturan Refund & Pembatalan Otomatis
- Refund koin otomatis saat pesanan dibatalkan
- Restore stok produk saat pembatalan
- Pembatalan oleh Konsumen (status 'pending'/'awaiting_payment')
- Pembatalan oleh UMKM (setelah diproses)
- Catatan di `order_histories` untuk setiap perubahan

---

## Tampilan Aplikasi (Screens)

### 📱 Halaman Umum

| **Screen** | **Deskripsi** |
|------------|---------------|
| **Splash Screen** | Animasi pembuka aplikasi |
| **Main Nav Screen** | Bottom navigation: Beranda, Peta Pasar, Keranjang, Dompet, Profil |

### 🔐 Autentikasi

| **Screen** | **Deskripsi** |
|------------|---------------|
| **Login Screen** | Form email + password, link lupa password & register |
| **Register Screen** | Pendaftaran Konsumen (1 langkah) & UMKM (2 langkah termasuk upload NIB/SIUP) |
| **Forgot Password Screen** | Input email untuk reset password |
| **Reset Password Screen** | Input password baru via token |

### 🏠 Beranda & Produk

| **Screen** | **Deskripsi** |
|------------|---------------|
| **Home Screen** | Banner promo, flash sale timer, rekomendasi produk, kategori UMKM |
| **Product Detail Screen** | Foto produk, deskripsi, harga, rating, tombol tambah ke keranjang |
| **Search Screen** | Pencarian produk real-time dengan filter kategori & harga |
| **Flash Sale Products** | Produk flash sale dengan countdown timer |

### 🗺️ Peta & Lokasi

| **Screen** | **Deskripsi** |
|------------|---------------|
| **Map Screen** | Google Maps dengan marker UMKM, info window, filter radius, navigasi |

### 🛒 Keranjang & Checkout

| **Screen** | **Deskripsi** |
|------------|---------------|
| **Cart Screen** | Daftar produk di keranjang, grouping per UMKM, edit qty, total harga |
| **Checkout Screen** | Konfirmasi alamat, pilih metode pembayaran, gunakan Lokal Coin |
| **Payment Screen** | WebView Midtrans Snap untuk pembayaran (GoPay/OVO/DANA/VA/QRIS) |
| **Order Success Screen** | Konfirmasi pesanan berhasil, tombol lihat detail pesanan |

### 📦 Pesanan & Tracking

| **Screen** | **Deskripsi** |
|------------|---------------|
| **Order List Screen** | Daftar pesanan dengan filter status (semua/pending/processing/shipped/completed) |
| **Order Detail Screen** | Detail pesanan, info pembayaran, alamat, tombol tracking |
| **Tracking Screen** | Timeline vertikal status pesanan, nomor resi, timestamp real-time |

### 👤 Profil & Pengaturan

| **Screen** | **Deskripsi** |
|------------|---------------|
| **Profile Screen** | Info pengguna, avatar, menu pengaturan |
| **Edit Profile Screen** | Ubah nama, email, nomor HP, avatar |
| **Change Password Screen** | Ganti password (perlu password lama) |
| **Address List Screen** | Daftar alamat pengiriman, set default |
| **Address Form Screen** | Tambah/edit alamat baru |
| **My Reviews Screen** | Ulasan produk yang pernah diberikan |
| **Wishlist Screen** | Produk favorit/disukai |

### 🪙 Dompet & Koin

| **Screen** | **Deskripsi** |
|------------|---------------|
| **Wallet Screen** | Saldo tunai & Lokal Coin, tombol Tarik Dana (disabled jika bank belum verifikasi) |
| **Coin History Screen** | Riwayat transaksi koin (kredit/debit) dengan filter tanggal |
| **Withdrawal Screen** | Form penarikan dana tunai (hanya jika bank terverifikasi) |

### 🏪 UMKM Dashboard

| **Screen** | **Deskripsi** |
|------------|---------------|
| **UMKM Dashboard** | Ringkasan pendapatan, jumlah order, produk terlaris, grafik penjualan |
| **Manage Product Screen** | Manajemen produk (tambah/edit/hapus) |
| **Add/Edit Product Screen** | Form tambah/edit produk dengan upload foto |
| **UMKM Order List** | Daftar pesanan masuk, update status (processing/shipped/cancelled) |
| **UMKM Analytics** | Grafik penjualan harian/mingguan/bulanan, filter tanggal |
| **Store Settings** | Pengaturan toko (nama, deskripsi, alamat, jam operasional) |
| **Bank Account Screen** | Pendaftaran & status verifikasi rekening bank |

### 🤖 AI Chat

| **Screen** | **Deskripsi** |
|------------|---------------|
| **AI Chat Screen** | Chat bubble dengan LOKAL AI Assistant (Google Gemini) |

### 🔔 Notifikasi

| **Screen** | **Deskripsi** |
|------------|---------------|
| **Notification Screen** | Daftar notifikasi, mark as read, mark all read |

### 🛠️ Chat (Antar Pengguna)

| **Screen** | **Deskripsi** |
|------------|---------------|
| **Chat List Screen** | Daftar percakapan dengan pelanggan/penjual |
| **Chat Screen** | Chat real-time antar pengguna |

### 👑 Admin Panel (Web)

Admin Dashboard berbasis **Laravel Blade** dengan fitur:
- Dashboard ringkasan (total user, UMKM, order, pendapatan)
- Manajemen Produk (CRUD, approve/hapus)
- Manajemen UMKM (verifikasi, edit, hapus)
- Manajemen Order (lihat, edit status)
- Verifikasi Bank UMKM (approve/reject)
- Manajemen Wallet & Coin
- Pengaturan Global Sistem
- Manajemen Pengguna

---

## Cara Penggunaan

### Untuk Konsumen

1. **Registrasi** → Buka aplikasi, tekan tombol "Register Account", isi data diri, verifikasi email
2. **Cari UMKM & Produk** → Gunakan Peta Pasar atau fitur pencarian
3. **Belanja** → Tambah produk ke keranjang, atur quantity
4. **Checkout** → Pilih alamat pengiriman, pilih metode pembayaran (bisa gunakan Lokal Coin untuk diskon)
5. **Bayar** → Selesaikan pembayaran via Midtrans Snap (GoPay/OVO/DANA/VA/QRIS)
6. **Tracking** → Pantau status pesanan dari timeline tracking
7. **Konfirmasi** → Konfirmasi pesanan diterima setelah barang sampai
8. **Review** → Berikan ulasan untuk produk yang dibeli

### Untuk UMKM

1. **Registrasi UMKM** → Daftar sebagai UMKM (2 langkah), upload NIB/SIUP, tunggu verifikasi Admin
2. **Kelola Toko** → Atur profil toko, jam operasional, alamat
3. **Tambah Produk** → Upload foto produk, atur harga, stok, kategori
4. **Daftar Bank** → Daftarkan rekening bank untuk pencairan dana, tunggu verifikasi Admin
5. **Proses Pesanan** → Lihat pesanan masuk, proses, input nomor resi saat kirim
6. **Analitik** → Pantau penjualan lewat dashboard dan grafik
7. **Tarik Dana** → Cairkan saldo tunai ke rekening bank yang sudah diverifikasi
8. **AI Assistant** → Tanya strategi bisnis atau cara penggunaan fitur ke LOKAL AI

### Untuk Admin

1. **Login** → Buka panel admin di `/admin` melalui browser
2. **Dashboard** → Pantau metrik utama platform
3. **Verifikasi UMKM** → Approve/reject pendaftaran UMKM
4. **Verifikasi Bank** → Approve/reject rekening bank UMKM
5. **Manajemen** → Kelola produk, pengguna, order, pengaturan sistem
6. **Wallet & Coin** → Pantau saldo dan riwayat transaksi

---

## Infrastruktur

### Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                          │
│  ┌─────────────────┐  ┌──────────────────────────┐      │
│  │  Flutter App     │  │  Admin Web (Blade)       │      │
│  │  (Android/iOS)   │  │  browser-based panel     │      │
│  └────────┬─────────┘  └──────────────────────────┘      │
└───────────┼──────────────────────────────────────────────┘
            │ HTTPS/JSON (JWT Bearer)
┌───────────┼──────────────────────────────────────────────┐
│           ▼           API GATEWAY LAYER                  │
│  ┌─────────────────────────────────────────────┐        │
│  │           Nginx 1.25 Reverse Proxy           │        │
│  │   SSL Termination, Rate Limiting, Static     │        │
│  └───────────────────┬─────────────────────────┘        │
└──────────────────────┼──────────────────────────────────┘
                       │
┌──────────────────────┼──────────────────────────────────┐
│                      ▼       BACKEND LAYER              │
│  ┌─────────────────────────────────────────────┐        │
│  │         Laravel 11 API (PHP 8.3)             │        │
│  │  ┌─────────┐ ┌──────────┐ ┌──────────────┐ │        │
│  │  │Auth     │ │Products  │ │Orders/Payment│ │        │
│  │  │Controller│ │Controller│ │Controller    │ │        │
│  │  ├─────────┤ ├──────────┤ ├──────────────┤ │        │
│  │  │Wallet   │ │AI Chat  │ │UMKM Dashboard│ │        │
│  │  │Controller│ │Controller│ │Controller    │ │        │
│  │  ├─────────┤ ├──────────┤ ├──────────────┤ │        │
│  │  │Admin    │ │Tracking │ │Bank Verify   │ │        │
│  │  │Controller│ │Controller│ │Controller    │ │        │
│  │  └─────────┘ └──────────┘ └──────────────┘ │        │
│  ├─────────────────────────────────────────────┤        │
│  │    n8n Workflow Engine (Automation)         │        │
│  ├─────────────────────────────────────────────┤        │
│  │    ML Service (Python/FastAPI)              │        │
│  │    Rekomendasi Harga (scikit-learn)         │        │
│  ├─────────────────────────────────────────────┤        │
│  │    LOKAL AI Assistant (Gemini API Integ.)   │        │
│  └─────────────────────────────────────────────┘        │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────┼──────────────────────────────────┐
│                      ▼         DATA LAYER                │
│  ┌───────────┐ ┌───────────┐ ┌──────────────────┐      │
│  │  MySQL 8.0 │  │ Redis 7   │  │  MinIO Object    │      │
│  │  Database  │  │ Cache &   │  │  Storage (S3)    │      │
│  │  (POINT    │  │ Queue     │  │  Foto Produk &   │      │
│  │   Spatial) │  │ Sessions  │  │  Dokumen UMKM    │      │
│  └───────────┘ └───────────┘ └──────────────────┘      │
└──────────────────────────────────────────────────────────┘
                       │
┌──────────────────────┼──────────────────────────────────┐
│                      ▼     EXTERNAL SERVICES             │
│  ┌───────────┐ ┌─────────────┐ ┌──────────────────┐    │
│  │  Midtrans  │  │  Google     │  │  Google Gemini   │    │
│  │  Payment   │  │  Maps       │  │  AI API          │    │
│  │  Gateway   │  │  Platform   │  │  (gemini-1.5     │    │
│  │  (Webhook) │  │             │  │   -flash)        │    │
│  └───────────┘ └─────────────┘ └──────────────────┘    │
│  ┌───────────┐ ┌─────────────┐                          │
│  │  FCM      │  │  SMTP       │                          │
│  │  Firebase │  │  Mail       │                          │
│  │  Cloud    │  │  Server     │                          │
│  │  Messaging│  │             │                          │
│  └───────────┘ └─────────────┘                          │
└──────────────────────────────────────────────────────────┘
```

### Docker Services

| **Service** | **Container Name** | **Port** | **Keterangan** |
|-------------|-------------------|----------|----------------|
| Laravel App | `ekonomi_lokal_app` | — | PHP-FPM, Laravel 11 API Backend |
| Nginx | `ekonomi_lokal_nginx` | 8080 → 80 | Web Server, Reverse Proxy |
| MySQL | `ekonomi_lokal_mysql` | — | Database (internal network) |
| Redis | `ekonomi_lokal_redis` | — | Cache & Queue (internal network) |
| MinIO | `ekonomi_lokal_minio` | 9000, 9001 | Object Storage S3-compatible |
| ML Service | — | — | Python/FastAPI (opsional terpisah) |
| n8n | — | — | Workflow Automation (opsional terpisah) |

---

## Arsitektur Sistem

### Komponen Utama

```
LOKAL Platform Architecture
├── Client Layer
│   ├── Flutter Mobile App (Android API 24+ & iOS 14+)
│   │   ├── Auth Module (Register Account, Login, Reset Password)
│   │   ├── Market Map Module (Google Maps, Radius Filter)
│   │   ├── Checkout Module (Cart, Midtrans Snap)
│   │   ├── Wallet Module (Coin, Saldo Tunai, Withdrawal)
│   │   ├── Dashboard Module (UMKM Analytics)
│   │   ├── Order Tracking Module (Timeline, Resi)
│   │   ├── AI Chat Module (Gemini Integration)
│   │   └── Bank Account Module (Verifikasi, Withdrawal)
│   └── Admin Web Panel (Laravel Blade)
│
├── API Gateway Layer
│   └── Nginx 1.25 (Reverse Proxy, SSL Termination, Rate Limiting)
│
├── Backend Layer
│   ├── Laravel 11 API (PHP 8.3)
│   │   ├── JWT Authentication (RS256)
│   │   ├── RBAC (Konsumen, UMKM, Admin)
│   │   ├── Order Management & Tracking
│   │   ├── Payment Processing & Webhook
│   │   ├── Wallet & Coin Service
│   │   ├── AI Chat (Gemini API Integration)
│   │   └── Admin Management
│   ├── ML Service (Python/FastAPI + scikit-learn)
│   └── n8n Workflow Engine
│
├── Data Layer
│   ├── MySQL 8.0 (POINT Spatial Index untuk UMKM)
│   ├── Redis 7 (Cache, Queue, Session)
│   └── MinIO (S3-compatible Object Storage)
│
└── External Services
    ├── Midtrans Payment Gateway (Webhook SHA-512)
    ├── Google Maps Platform (Maps SDK, Geocoding, Distance Matrix)
    ├── Google Gemini API (gemini-1.5-flash)
    ├── Firebase Cloud Messaging (Push Notification)
    └── SMTP Server (Email Verifikasi & Reset Password)
```

### Database Utama

| **Tabel** | **Keterangan** |
|-----------|---------------|
| `users` | Data pengguna (Konsumen, UMKM, Admin) dengan role & verifikasi |
| `umkm_stores` | Data toko UMKM (nama, alamat, koordinat POINT, status verifikasi) |
| `products` | Produk UMKM (nama, harga, stok, kategori, foto) |
| `orders` | Pesanan (status, tracking_number, subtotal, ongkir, coin_discount) |
| `order_histories` | Riwayat perubahan status pesanan untuk tracking |
| `payments` | Transaksi pembayaran via Midtrans |
| `cart_items` | Item keranjang belanja |
| `wallets` | Dompet (cash_balance, coin_balance, commission_balance) |
| `wallet_histories` | Riwayat mutasi wallet (credit/debit) |
| `umkm_bank_accounts` | Data rekening bank UMKM (status verifikasi) |
| `withdrawals` | Riwayat penarikan dana UMKM |
| `reviews` | Ulasan produk |
| `categories` | Kategori produk |
| `addresses` | Alamat pengiriman konsumen |
| `notifications` | Notifikasi push & in-app |
| `settings` | Pengaturan global platform |

---

## Teknis Instalasi

### Prerequisites

| **Kebutuhan** | **Versi Minimum** | **Keterangan** |
|--------------|------------------|----------------|
| Docker Desktop | — | Harus terinstall dan berjalan |
| Flutter SDK | >= 3.2.0 | Untuk menjalankan frontend mobile |
| Android Studio / Xcode | — | Untuk emulator/pembangunan APK/IPA |
| Git | — | Version control |
| PHP | 8.2+ | Untuk development tanpa Docker (opsional) |
| Composer | — | Manajemen dependency PHP |

---

### 🔧 Backend (Laravel 11 + Docker)

#### 1. Clone Repository

```bash
git clone https://github.com/1khsan2610/LOKAL_APP.git
cd LOKAL_APP/backend
```

#### 2. Copy Environment File

```bash
cp .env.example .env
```

#### 3. Konfigurasi `.env`

```env
APP_NAME=EkonomiLokal
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8080

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=ekonomi_lokal
DB_USERNAME=ekonomi_user
DB_PASSWORD=secret

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

# Midtrans (daftar di https://midtrans.com)
MIDTRANS_SERVER_KEY=SB-Mid-server-xxxx
MIDTRANS_CLIENT_KEY=SB-Mid-client-xxxx
MIDTRANS_IS_PRODUCTION=false

# Gemini AI (daftar di https://aistudio.google.com)
GEMINI_API_KEY=AIzaxxxxxxxxxx

# FCM (Firebase Cloud Messaging)
FCM_SERVER_KEY=AAAAxxxxxxxxxx

# MinIO (Object Storage)
MINIO_ENDPOINT=http://minio:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET=ekonomi-lokal
```

#### 4. Jalankan Docker Compose

```bash
docker-compose up -d
```

Perintah ini akan menjalankan 5 container:
- `ekonomi_lokal_app` — Laravel PHP-FPM
- `ekonomi_lokal_nginx` — Nginx Web Server (port 8080)
- `ekonomi_lokal_mysql` — MySQL 8.0 Database
- `ekonomi_lokal_redis` — Redis 7 Cache & Queue
- `ekonomi_lokal_minio` — MinIO Object Storage (port 9000, 9001)

#### 5. Generate App Key & JWT Secret

```bash
docker exec ekonomi_lokal_app php artisan key:generate
docker exec ekonomi_lokal_app php artisan jwt:secret
```

#### 6. Jalankan Migrasi & Seeder

```bash
docker exec ekonomi_lokal_app php artisan migrate --seed
```

Ini akan membuat tabel-tabel database dan mengisi data demo (produk, UMKM, pengguna).

#### 7. Link Storage

```bash
docker exec ekonomi_lokal_app php artisan storage:link
```

#### 8. Verifikasi

```bash
# Cek status container
docker ps

# Cek log aplikasi
docker logs ekonomi_lokal_app

# Cek health endpoint
curl http://localhost:8080/api/health
```

**Backend siap di:** `http://localhost:8080/api`

---

### 📱 Frontend (Flutter)

#### 1. Masuk ke Folder Frontend

```bash
cd ../frontend
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Setup Firebase (untuk Push Notification)

1. Buat project di [Firebase Console](https://console.firebase.google.com)
2. Tambahkan aplikasi Android (package name: sesuai `android/app/build.gradle`)
3. Download `google-services.json` → taruh di `android/app/`
4. Tambahkan aplikasi iOS → Download `GoogleService-Info.plist` → taruh di `ios/Runner/`

#### 4. Konfigurasi API URL

Edit **`lib/services/api_service.dart`**:

```dart
class ApiService {
  // Pilih salah satu sesuai environment:

  // Android Emulator (default)
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  // iOS Simulator
  // static const String baseUrl = 'http://localhost:8080/api';

  // Device fisik (ganti dengan IP komputer kamu)
  // static const String baseUrl = 'http://192.168.1.100:8080/api';

  // Production
  // static const String baseUrl = 'https://api.lokal.id/v1';
}
```

#### 5. Jalankan Aplikasi

```bash
# Lihat daftar device
flutter devices

# Jalankan di device tertentu
flutter run -d <device_id>

# Android langsung
flutter run

# iOS
flutter run -d ios

# Build APK Release
flutter build apk --release

# Build IPA Release (iOS)
flutter build ios --release
```

---

### 🖥️ Admin Panel (Web)

Panel admin dapat diakses melalui browser setelah backend berjalan:

```
http://localhost:8080/admin
```

Login dengan akun admin:

| **Email** | **Password** |
|-----------|-------------|
| admin@ekonomilokal.id | password123 |

Fitur panel admin:
- Dashboard real-time
- Manajemen Produk (CRUD + approve)
- Manajemen UMKM (verifikasi + CRUD)
- Manajemen Order (lihat, edit status)
- Verifikasi Rekening Bank UMKM
- Manajemen Wallet & Riwayat
- Pengaturan Global Sistem

---

## API Endpoints

### Public Endpoints

```
POST   /api/auth/register-account     # Register akun baru
POST   /api/auth/login                 # Login
POST   /api/auth/forgot-password       # Lupa password
POST   /api/auth/reset-password        # Reset password
POST   /api/auth/verify-email          # Verifikasi email
GET    /api/products                   # List produk (filter & pagination)
GET    /api/products/search?q=         # Pencarian produk
GET    /api/products/flash-sale        # Flash sale
GET    /api/products/{id}              # Detail produk
GET    /api/products/{id}/reviews      # Reviews produk
GET    /api/umkm                       # List UMKM
GET    /api/umkm/nearby                # UMKM terdekat
GET    /api/umkm/{id}                  # Detail UMKM
GET    /api/umkm/{id}/products         # Produk UMKM tertentu
POST   /api/payment/notification       # Webhook Midtrans (publik)
POST   /api/orders/process-payment-webhook  # Simulasi webhook (testing)
GET    /api/health                     # Health check
GET    /api/image/{path}               # Image proxy (CORS)
```

### Authenticated Endpoints (Bearer Token)

```
# Auth
POST   /api/auth/logout                # Logout
GET    /api/auth/me                     # Profil saya
POST   /api/auth/refresh                # Refresh token

# Profile
GET    /api/profile                     # Profil user
PUT    /api/profile                     # Update profil
POST   /api/profile/avatar              # Upload avatar
PUT    /api/profile/change-password     # Ganti password

# Addresses
GET    /api/addresses                   # List alamat
POST   /api/addresses                   # Tambah alamat
GET    /api/addresses/{id}              # Detail alamat
PUT    /api/addresses/{id}              # Update alamat
DELETE /api/addresses/{id}              # Hapus alamat
PATCH  /api/addresses/{id}/set-default  # Set alamat utama

# Cart
GET    /api/cart                        # Lihat keranjang
POST   /api/cart                        # Tambah item
PUT    /api/cart/{itemId}               # Update quantity
DELETE /api/cart/{itemId}               # Hapus item
DELETE /api/cart                        # Kosongkan keranjang

# Orders
GET    /api/orders                      # Daftar pesanan
POST   /api/orders                      # Buat pesanan
GET    /api/orders/{id}                 # Detail pesanan
PATCH  /api/orders/{id}/cancel          # Batalkan pesanan
PATCH  /api/orders/{id}/confirm-received # Konfirmasi diterima
GET    /api/orders/{id}/tracking        # Tracking pesanan

# Payment
POST   /api/payment/create              # Buat transaksi Midtrans
GET    /api/payment/status/{orderId}     # Cek status pembayaran

# Wallet & Coin
GET    /api/wallet                      # Saldo dompet
GET    /api/wallet/transactions         # Riwayat transaksi
POST   /api/wallet/redeem               # Redeem koin

# Reviews
GET    /api/reviews/me                  # Ulasan saya
POST   /api/reviews                     # Beri ulasan
PUT    /api/reviews/{id}                # Update ulasan
DELETE /api/reviews/{id}                # Hapus ulasan

# Notifications
GET    /api/notifications               # Daftar notifikasi
PATCH  /api/notifications/{id}/read     # Tandai baca
PATCH  /api/notifications/read-all      # Tandai semua baca
POST   /api/notifications/register-device  # Daftar device FCM

# AI Chat
POST   /api/ai/chat                     # Chat dengan LOKAL AI Assistant

# Chat (Antar Pengguna)
GET    /api/chat                        # Daftar chat
GET    /api/chat/unread-count           # Jumlah chat belum dibaca
GET    /api/chat/{id}                   # Detail chat
POST   /api/chat/send                   # Kirim pesan
POST   /api/chat/start-from-product     # Mulai chat dari produk
PATCH  /api/chat/{id}/mark-read         # Tandai chat sudah dibaca
```

### UMKM Endpoints (Bearer + Role: UMKM)

```
# Toko
GET    /api/umkm/my-store               # Data toko saya
PUT    /api/umkm/my-store               # Update toko

# Produk
GET    /api/umkm/products               # Produk saya
POST   /api/umkm/products               # Tambah produk
GET    /api/umkm/products/{id}          # Detail produk saya
PUT    /api/umkm/products/{id}          # Update produk
DELETE /api/umkm/products/{id}          # Hapus produk
POST   /api/umkm/products/{id}/images   # Upload foto
DELETE /api/umkm/products/{productId}/images/{imageId}  # Hapus foto

# Pesanan
GET    /api/umkm/orders                 # Pesanan masuk
PATCH  /api/umkm/orders/{id}/status     # Update status (+ resi jika shipped)

# Analitik
GET    /api/umkm/analytics/summary      # Ringkasan performa
GET    /api/umkm/analytics/sales        # Grafik penjualan

# Bank Account
GET    /api/umkm/bank-account           # Data bank
POST   /api/umkm/bank-account           # Daftar bank baru
PUT    /api/umkm/bank-account           # Update bank
```

### Admin Endpoints (Bearer + Role: Admin)

```
GET    /api/admin/dashboard              # Dashboard admin
GET    /api/admin/users                  # Daftar user
PATCH  /api/admin/users/{id}/status      # Ubah status user
GET    /api/admin/umkm                   # Daftar UMKM
PATCH  /api/admin/umkm/{id}/verify       # Verifikasi UMKM
GET    /api/admin/orders                 # Semua pesanan
GET    /api/admin/transactions           # Semua transaksi
GET    /api/admin/analytics              # Analitik platform
POST   /api/admin/products/{id}/approve  # Approve produk
DELETE /api/admin/products/{id}          # Hapus produk
POST   /api/admin/notifications/broadcast  # Broadcast notifikasi
```

---

## Akun Demo

| **Role** | **Email** | **Password** | **Deskripsi** |
|----------|-----------|-------------|---------------|
| 👑 **Admin** | admin@ekonomilokal.id | password123 | Akses penuh ke panel admin & API |
| 🏪 **UMKM** | busari@test.com | password123 | Toko UMKM terverifikasi dengan produk |
| 👤 **Konsumen** | budi@test.com | password123 | Pembeli dengan riwayat transaksi |

---

## Tech Stack

| **Layer** | **Teknologi** | **Versi** |
|-----------|--------------|-----------|
| **Frontend Mobile** | Flutter + Provider + Riverpod | 3.19 / 3.x |
| **Backend API** | Laravel | 11.x |
| **PHP Runtime** | PHP (via Docker) | 8.3 |
| **Database** | MySQL | 8.0 |
| **Cache & Queue** | Redis | 7 (alpine) |
| **Object Storage** | MinIO (S3-compatible) | latest |
| **Web Server** | Nginx | alpine |
| **Authentication** | JWT (tymon/jwt-auth) | RS256 |
| **Payment Gateway** | Midtrans Snap | — |
| **AI Chat** | Google Gemini 1.5 Flash | — |
| **Push Notification** | Firebase Cloud Messaging | — |
| **Maps** | Google Maps Flutter | — |
| **ML Service** | Python FastAPI + scikit-learn | — |
| **Workflow Automation** | n8n (self-hosted) | — |
| **Container** | Docker + Docker Compose | — |

---

## Security

| **Aspek** | **Implementasi** |
|-----------|-----------------|
| **Autentikasi** | JWT RS256, disimpan di Android Keystore / iOS Keychain |
| **OTP/Password** | Bcrypt cost factor 12, tidak pernah plaintext |
| **Enkripsi Data** | AES-256 untuk data sensitif (email, nomor HP, alamat) |
| **Komunikasi** | HTTPS/TLS 1.2+ untuk semua komunikasi |
| **Rate Limiting** | Register 5/menit, login 10/menit, AI chat 20/menit |
| **RBAC** | Role-based access control (Konsumen, UMKM, Admin) |
| **Webhook** | Validasi signature SHA-512 dari Midtrans |
| **API Key Gemini** | Disimpan di `.env` backend, tidak diekspos ke client |
| **Idempotency** | Mencegah double processing webhook |
| **Privasi Data** | Server Indonesia (UU PDP No. 27/2022) |
| **Gagal Login** | 5 percobaan gagal = akun dikunci 15 menit |

---

## Tim Pengembang

Proyek ini dikembangkan oleh mahasiswa **Program Studi Sistem Informasi** — **Fakultas Ilmu Komputer dan Sistem Informasi** — **Universitas Kebangsaan Republik Indonesia** (UKRI), Tahun 2026.

| **Nama** | **NPM** | **Peran** |
|----------|---------|-----------|
| Ikhsan | 20241320083 | Project Manager |
| Naufal Al Farros | 20241320091 | Frontend Mobile (Flutter) Developer |
| Linda Anjarini | 20241320058 | Backend Developer |
| Kiara Evi Nurdiati Putri Rahmatillah | 20241320067 | Frontend Mobile (Flutter) Developer |
| Najwa Alifah | 20241320077 | Backend Developer |
| Ikbal Maulana Aspahni | 20241320053 | QA |

---

## 📞 Support & Kontak

Untuk pertanyaan teknis, saran, atau pelaporan bug:

- **GitHub Issues**: [https://github.com/1khsan2610/LOKAL_APP/issues](https://github.com/1khsan2610/LOKAL_APP/issues)
- **Dokumentasi Lengkap**: [SRS_Ekonomi_Lokal](SRS/SRS_Ekonomi_Lokal.md)

---

<p align="center">
  <i>© 2026 Tim Pengembang Platform LOKAL — UKRI</i><br>
  <i>Mengoptimalkan Sirkulasi Ekonomi Lokal untuk Indonesia</i>
</p>