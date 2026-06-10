# Software Requirements Specification (SRS)

# Platform LOKAL v1.3.0

*Platform Digital Berbasis Mobile untuk Optimalisasi Sirkulasi Ekonomi Lokal*

| **Nama** | **NPM** |
| --- | --- |
| Linda Anjarini | 20241320058 |
| Kiara Evi Nurdiati Putri Rahmatillah | 20241320067 |
| Najwa Alifah | 20241320077 |
| Ikhsan | 20241320083 |
| Naufal Al Farros | 20241320091 |
| Ikbal Maulana Aspahni | 20241320053 |
| Fito Zulhian Jabatami | 20241320074 |

**PROGRAM STUDI SISTEM INFORMASI**

FAKULTAS ILMU KOMPUTER DAN SISTEM INFORMASI

UNIVERSITAS KEBANGSAAN REPUBLIK INDONESIA

TAHUN 2026

| **Atribut** | **Nilai** |
| --- | --- |
| Versi Dokumen | 1.3.0 - Juni 2026 |
| Status | Draft Revisi |
| Dibuat oleh | Tim Pengembang Platform LOKAL |
| Perubahan Utama | Metode register diganti ke Register Account (backend-driven); Role Produsen dihapus |
| Database | MySQL 8.0 |

---

## Revision History

| **Name** | **Date** | **Reason For Changes** | **Version** |
| --- | --- | --- | --- |
| Tim Pengembang LOKAL | April 2026 | Dokumen Teknis v1.1 dirilis | 1.1.0 |
| Tim Pengembang LOKAL | Juni 2026 | Autentikasi diganti ke Email + Password (OTP dihapus) | 1.2.0 |
| Tim Pengembang LOKAL | Juni 2026 | Metode register diubah ke Register Account (backend-driven via tombol di app); Role Produsen dihapus dari sistem | 1.3.0 |

---

## 1. Introduction

### 1.1 Purpose

Dokumen SRS ini mendefinisikan kebutuhan perangkat lunak Platform LOKAL v1.3.0 - aplikasi mobile ekosistem ekonomi digital tertutup (closed-loop) untuk mengoptimalkan sirkulasi ekonomi lokal di Kota Bandung dan sekitarnya. Pada versi ini terdapat dua perubahan utama: (1) Mekanisme pembuatan akun diperbarui - pengguna menekan tombol 'Register Account' di aplikasi, lalu backend secara otomatis membuatkan akun dan mengirimkan kredensial via email; (2) Role Produsen dihapus dari sistem. Platform kini hanya mengelola dua role pengguna aktif: Konsumen dan UMKM.

### 1.2 Document Conventions

Dokumen mengikuti standar IEEE 830-1998. Prioritas: Tinggi / Sedang / Rendah. Kode fungsional: F-XX; non-fungsional: NF-XX. Istilah teknis didefinisikan di Appendix A.

### 1.3 Intended Audience and Reading Suggestions

- **Developer Backend/Frontend/Mobile:** Bab 3, 4, dan 5
- **Tim QA/Tester:** Bab 4 (test case) dan Bab 5 (pengujian performa)
- **Manajer Proyek:** Bab 1, 2, dan Bab 4 (scope dan prioritas)
- **Pemangku Kepentingan Bisnis:** Bab 1 dan 2
- **Arsitek Sistem:** Bab 3, 4, dan Appendix B

### 1.4 Product Scope

Platform LOKAL adalah aplikasi mobile (Android & iOS) yang menghubungkan konsumen dengan UMKM lokal menggunakan peta interaktif, sistem insentif token Lokal Coin, dan analitik pasar berbasis ML. Tujuan utama: mengurangi kebocoran ekonomi lokal, memberi akses digital bagi UMKM, dan membangun ekosistem ekonomi komunitas berkelanjutan. Fase pilot: Kota Bandung, Kab. Bandung, Kab. Bandung Barat, dan Kota Cimahi.

### 1.5 References

- Dokumen Teknis Sistem LOKAL v1.3.0 - Juni 2026
- IEEE Std 830-1998: Recommended Practice for Software Requirements Specifications
- UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi (UU PDP)
- Regulasi OJK dan Bank Indonesia terkait sistem pembayaran digital
- Midtrans API Docs - https://docs.midtrans.com
- Laravel 11 - https://laravel.com/docs/11.x
- Flutter 3.19 - https://docs.flutter.dev

---

## 2. Overall Description

### 2.1 Product Perspective

Platform LOKAL adalah produk baru berupa marketplace berbasis lokasi yang menghubungkan penjual UMKM dan pembeli (Konsumen) dalam ekosistem tertutup. Bukan lembaga keuangan - seluruh transaksi melalui Midtrans.

**Komponen utama:**

- Mobile App (Flutter)
- API Backend (Laravel 11)
- ML Service (Python/FastAPI)
- n8n Workflow Engine
- MySQL 8.0
- Layanan eksternal: Midtrans, Google Maps API, SMTP Server

### 2.2 Product Functions

- **Autentikasi & Manajemen Pengguna:** Register Account (backend-driven), login Email+Password, JWT RS256, verifikasi UMKM.
- **Peta Pasar & Katalog Produk:** Peta interaktif UMKM radius 0.5-10 km, CRUD produk, filter multi-kriteria.
- **Transaksi & Pembayaran:** Keranjang multi-UMKM, checkout via Midtrans (GoPay, OVO, DANA, VA, QRIS).
- **Lokal Coin & Insentif:** Reward 2% per transaksi, diskon maks. 20%, kadaluwarsa 6 bulan.
- **Rekomendasi Harga ML:** Analisis harga pasar lokal asinkron via Python/FastAPI.
- **Dashboard Analitik UMKM:** Grafik penjualan, produk terlaris, pendapatan bersih, real-time.
- **Notifikasi & Otomasi:** Push notification otomatis via n8n untuk event transaksi.

### 2.3 User Classes and Characteristics

| **Role** | **Deskripsi** | **Karakteristik** |
| --- | --- | --- |
| Konsumen | Pembeli produk UMKM lokal | Pengguna smartphone awam, frekuensi harian-mingguan |
| UMKM / Penjual | Pelaku usaha lokal | Kapasitas teknis terbatas; wajib terverifikasi NIB/SIUP sebelum berjualan |
| Administrator | Tim internal LOKAL | Akses panel admin terpisah (di luar cakupan SRS ini) |

> *Catatan: Role Produsen telah dihapus dari sistem sejak versi 1.3.0.*

### 2.4 Operating Environment

- **Mobile:** Android min. API 24 (7.0) & iOS min. 14.0; Flutter 3.19 + Riverpod + Dio.
- **Backend:** VPS Indonesia, Ubuntu 22.04, 8 vCPU, 16 GB RAM; PHP 8.3/Laravel 11 via Docker.
- **Database & Cache:** MySQL 8.0 + Redis 7.2-alpine; Object Storage: MinIO (S3-compatible).
- **Koneksi:** Internet aktif min. 3G/HSPA; data pengguna di server wilayah Indonesia (UU PDP).

### 2.5 Design and Implementation Constraints

- Regulasi UU PDP: Data pribadi wajib disimpan di server dalam wilayah Indonesia.
- Regulasi OJK/BI: Transaksi keuangan hanya melalui payment gateway berizin (Midtrans).
- Lokal Coin tidak dapat dikonversi ke fiat; maks. 20% dari nilai transaksi; hangus setelah 6 bulan.
- Teknologi wajib: Flutter, Laravel 11/PHP 8.3, MySQL 8.0, Docker.
- API response time maks. 500ms untuk endpoint kritikal; kapasitas pilot: 10.000 concurrent users.
- Password wajib di-hash menggunakan bcrypt (cost factor min. 12) sebelum disimpan di database.
- Proses Register Account diinisiasi oleh pengguna melalui tombol di aplikasi; backend menangani pembuatan akun dan pengiriman kredensial via email.

### 2.6 User Documentation

- Panduan Pengguna Konsumen (in-app): Onboarding interaktif, tutorial Peta Pasar & Lokal Coin.
- Panduan Pengguna UMKM (in-app + PDF): Tutorial manajemen produk, register account, dan dashboard.
- FAQ In-App & Pusat Bantuan Online.
- TBD: Video tutorial onboarding UMKM (v1.4.0).

### 2.7 Assumptions and Dependencies

- **Asumsi:** Pengguna memiliki smartphone kompatibel, internet aktif, dan alamat email aktif; UMKM bersedia mengunggah NIB/SIUP.
- **Dependensi eksternal:** Midtrans (pembayaran), Google Maps Platform (peta), Docker Hub, GitHub Actions (CI/CD), SMTP Server untuk pengiriman kredensial & verifikasi email.

---

## 3. External Interface Requirements

### 3.1 User Interfaces

- **Navigasi:** Bottom navigation bar 5 tab (Beranda, Peta Pasar, Keranjang, Dompet, Profil).
- **Peta Interaktif:** Google Maps SDK; marker UMKM dengan info window; filter radius 0.5-10 km.
- **Layar Register Account:** Tombol 'Register Account' yang memicu proses backend. Form pengisian: Nama Lengkap, Email, Nomor HP, Password, Pilihan Peran (Konsumen / UMKM), Persetujuan S&K. Untuk UMKM, terdapat langkah kedua: data usaha & upload dokumen legalitas.
- **Layar Login:** Form email + password dengan tombol 'Lupa Password' (reset via email).
- **Checkout Flow:** 3 langkah - Keranjang > Konfirmasi & Pembayaran > Status Pesanan.
- **Dashboard UMKM:** Line chart & bar chart penjualan, kartu ringkasan metrik.
- **Responsivitas & Aksesibilitas:** Mendukung 360-480dp (portrait) & tablet 600dp+; WCAG 2.1 level AA.

### 3.2 Hardware Interfaces

- **GPS/Lokasi:** Akurasi min. 50 meter; izin lokasi saat aplikasi digunakan.
- **Kamera & Penyimpanan:** Untuk unggah foto produk UMKM (izin kamera & galeri).
- **Push Notification:** FCM (Android) & APNs (iOS).
- **Koneksi Internet:** Min. 3G/HSPA; mode offline terbatas (riwayat transaksi dari cache lokal).

### 3.3 Software Interfaces

- **Midtrans:** SNAP API + webhook SHA-512; format JSON/HTTPS.
- **SMTP Server:** Pengiriman email kredensial akun baru, verifikasi, dan reset password (Laravel Mail + queue).
- **Google Maps Platform:** Maps SDK + Geocoding API + Distance Matrix API.
- **ML Service (internal):** FastAPI Python 3.11 + scikit-learn; endpoint `http://ml-service:8000/api/price-recommendation` (asinkron).
- **n8n:** Self-hosted workflow automation; trigger HTTP webhook dari Laravel.
- **MinIO:** Object storage S3-compatible untuk foto produk & dokumen legalitas UMKM.

### 3.4 Communications Interfaces

- **Protokol:** HTTPS/TLS 1.2 min. (TLS 1.3 direkomendasikan); REST API format JSON.
- **Base URL API:** `https://api.lokal.id/v1`; autentikasi Bearer Token JWT RS256.
- **Rate Limiting:** Register Account 5 req/menit per IP; login 10 req/menit per IP; reset password 3 req/menit per IP; endpoint umum 100 req/menit per token.
- **Push Notification:** FCM/APNs; tidak menggunakan WebSocket pada versi MVP.

---

## 4. System Features

Platform LOKAL memiliki 7 fitur sistem utama:

| **Kode** | **Fitur** | **Deskripsi Singkat** | **Prioritas** |
| --- | --- | --- | --- |
| F-01 | Autentikasi & Pengguna | Register Account (backend-driven), login Email+Password, JWT, verifikasi UMKM | Tinggi |
| F-02 | Peta Pasar & Produk | Peta interaktif UMKM radius 0.5-10 km, CRUD katalog produk | Tinggi |
| F-03 | Transaksi & Pembayaran | Keranjang multi-UMKM, checkout Midtrans (GoPay/OVO/DANA/VA/QRIS) | Tinggi |
| F-04 | Lokal Coin & Insentif | Reward 2%/transaksi, diskon maks. 20%, kadaluwarsa 6 bulan | Sedang |
| F-05 | Rekomendasi Harga ML | Analisis harga produk serupa radius 5 km secara asinkron | Sedang |
| F-06 | Dashboard Analitik UMKM | Grafik penjualan, produk terlaris, pendapatan bersih, real-time | Tinggi |
| F-07 | Notifikasi & Otomasi | Push notification via n8n untuk event transaksi | Tinggi |

### 4.1 F-01: Autentikasi & Pengguna

#### 4.1.1 Description and Priority

Mengelola identitas pengguna menggunakan mekanisme Register Account yang diinisiasi dari aplikasi mobile. Pengguna menekan tombol 'Register Account', mengisi form, dan backend secara otomatis membuatkan akun serta mengirimkan konfirmasi via email. Login menggunakan Email dan Password (bcrypt + JWT RS256). Role yang tersedia: Konsumen dan UMKM.

**Prioritas: TINGGI.**

#### 4.1.2 Functional Requirements

| **Kode** | **Kebutuhan** | **Keterangan** |
| --- | --- | --- |
| REQ-F01-01 | Tombol 'Register Account' tersedia di layar onboarding dan login; menekan tombol ini memulai proses pendaftaran akun | Backend menerima data form dan membuat akun baru secara otomatis |
| REQ-F01-02 | Registrasi dua peran: Konsumen dan UMKM, masing-masing dengan form yang berbeda | Role Produsen telah dihapus |
| REQ-F01-03 | Form Konsumen: Nama Lengkap, Email, Nomor HP, Password, Konfirmasi Password, Persetujuan S&K | Proses 1 langkah; setelah submit backend membuat akun & kirim email verifikasi |
| REQ-F01-04 | Form UMKM - Langkah 1: Nama Pemilik, Nama Usaha, Email Usaha, Nomor HP, Password, Konfirmasi Password, Persetujuan S&K | Proses 2 langkah |
| REQ-F01-05 | Form UMKM - Langkah 2: Alamat Usaha, Kategori Usaha, Upload NIB/SIUP | Akun berstatus `pending_verification` hingga admin verifikasi dokumen |
| REQ-F01-06 | Validasi email unik dan format valid saat registrasi | Error jika email sudah terdaftar atau format salah |
| REQ-F01-07 | Password min. 8 karakter; kombinasi huruf & angka; di-hash bcrypt cost 12 | Validasi di sisi client & server |
| REQ-F01-08 | Setelah backend memproses Register Account, sistem mengirim email verifikasi dengan link aktivasi (berlaku 24 jam) | Akun tidak aktif sebelum email diverifikasi |
| REQ-F01-09 | Login menggunakan email + password; respons berupa JWT RS256 | Access token 24 jam, refresh token 30 hari |
| REQ-F01-10 | Maks. 5 percobaan login gagal sebelum akun dikunci sementara 15 menit | Notifikasi email dikirim saat akun dikunci |
| REQ-F01-11 | Fitur Lupa Password: reset via tautan email (berlaku 1 jam, sekali pakai) | Tautan diinvalidasi setelah digunakan |
| REQ-F01-12 | Pengguna baru otomatis mendapat 50 Lokal Coin saat aktivasi akun | Diberikan setelah verifikasi email berhasil |
| REQ-F01-13 | Logout: invalidasi JWT dan refresh token di server (blacklist via Redis) | Semua sesi aktif dapat diakhiri |

### 4.2 F-02: Peta Pasar & Produk

#### 4.2.1 Description and Priority

Fitur inti: peta interaktif UMKM terdekat dan katalog produk.

**Prioritas: TINGGI.**

#### 4.2.2 Functional Requirements

- **REQ-F02-01:** Peta interaktif Google Maps SDK; marker setiap UMKM aktif dalam radius yang ditentukan.
- **REQ-F02-02:** Radius pencarian 0.5-10 km; default 5 km.
- **REQ-F02-03:** Pencarian produk berdasarkan nama, kategori, harga, jarak, dan rating.
- **REQ-F02-04:** CRUD produk oleh UMKM; maks. 5 foto per produk (maks. 2 MB/foto).
- **REQ-F02-05:** Pagination produk default 20 item/halaman; koordinat disimpan tipe POINT MySQL.

### 4.3 F-03: Transaksi & Pembayaran

#### 4.3.1 Description and Priority

Mengelola seluruh alur transaksi dari pemilihan produk hingga konfirmasi.

**Prioritas: TINGGI.**

#### 4.3.2 Functional Requirements

- **REQ-F03-01:** Keranjang belanja multi-UMKM; validasi stok saat checkout.
- **REQ-F03-02:** Pembayaran via GoPay, OVO, DANA, VA Bank, QRIS melalui Midtrans.
- **REQ-F03-03:** Link/QR pembayaran kadaluwarsa 30 menit; webhook Midtrans divalidasi SHA-512.
- **REQ-F03-04:** Riwayat transaksi lengkap dengan filter tanggal & status; mendukung alur refund.

### 4.4 F-04: Lokal Coin & Insentif

- **REQ-F04-01:** Kredit otomatis 2% nilai transaksi saat status 'completed'; 5 koin per ulasan valid.
- **REQ-F04-02:** Maks. 20% nilai transaksi dapat dibayar dengan Lokal Coin; tidak bisa dikonversi ke fiat.
- **REQ-F04-03:** Koin hangus otomatis setelah 6 bulan; notifikasi 30 hari sebelum kadaluwarsa.
- **REQ-F04-04:** Setiap transaksi koin tercatat di riwayat dompet.

### 4.5 F-05: Rekomendasi Harga ML

- **REQ-F05-01:** Rekomendasi asinkron saat UMKM tambah produk baru; analisis radius 5 km.
- **REQ-F05-02:** Respons mencakup harga saran, rentang harga, dan jumlah produk serupa yang dianalisis.
- **REQ-F05-03:** Respons maks. 3 detik; graceful degradation jika ML Service tidak tersedia.

### 4.6 F-06: Dashboard Analitik UMKM

- **REQ-F06-01:** Grafik penjualan harian/mingguan/bulanan; data diperbarui maks. 5 menit setelah transaksi.
- **REQ-F06-02:** Menampilkan total pendapatan, pertumbuhan %, jumlah order, produk terlaris, rating, pelanggan baru.
- **REQ-F06-03:** Filter rentang tanggal kustom; hanya diakses akun UMKM terverifikasi (Bearer+UMKM role).

### 4.7 F-07: Notifikasi & Otomasi

- **REQ-F07-01:** Notifikasi konfirmasi pesanan (konsumen & UMKM), pembayaran berhasil/gagal, update status pengiriman.
- **REQ-F07-02:** Notifikasi peringatan stok menipis (< 10 unit) kepada UMKM.
- **REQ-F07-03:** Pengguna dapat mengatur preferensi notifikasi; semua alur diimplementasikan via n8n.

---

## 5. Other Nonfunctional Requirements

| **Kategori** | **Persyaratan** | **Target** |
| --- | --- | --- |
| Performa | Waktu respons API endpoint kritikal | < 500ms |
| Performa | Waktu respons ML Service | < 3 detik |
| Skalabilitas | Pengguna konkuren fase pilot | 10.000 concurrent |
| Ketersediaan | Uptime sistem produksi | >= 99.5%/bulan |
| Keamanan | Enkripsi client-server | HTTPS/TLS 1.2+ |
| Keamanan | Hash password | bcrypt cost 12 |
| Keamanan | Enkripsi data sensitif di DB | AES-256 |
| Privasi | Lokasi penyimpanan data | Server Indonesia (UU PDP) |
| Portabilitas | Platform mobile | Android API 24+ & iOS 14+ |
| Pemeliharaan | Deployment & rollback | Zero-downtime (Docker+Watchtower) |
| Kegunaan | Waktu onboarding pengguna baru | <= 5 menit |

### 5.1 Performance Requirements

- **NF-PERF-01:** API kritikal (autentikasi, peta, checkout) maks. 500ms pada 1.000 concurrent request.
- **NF-PERF-02:** ML Service maks. 3 detik; graceful degradation jika melebihi batas.
- **NF-PERF-03:** Render peta 100+ marker UMKM < 2 detik di perangkat kelas menengah.
- **NF-PERF-04:** Query geospasial produk < 200ms menggunakan indeks SPATIAL MySQL.

### 5.2 Safety Requirements

- **NF-SAFE-01:** Rollback otomatis jika pembayaran gagal; stok tidak dikurangi saat order pending.
- **NF-SAFE-02:** Audit log immutable untuk seluruh transaksi keuangan dan perubahan status order.
- **NF-SAFE-03:** Idempotency untuk webhook Midtrans guna mencegah double processing.

### 5.3 Security Requirements

- **NF-SEC-01:** HTTPS/TLS 1.2+ untuk semua komunikasi client-server.
- **NF-SEC-02:** JWT RS256; disimpan di Android Keystore / iOS Keychain.
- **NF-SEC-03:** Rate limiting: Register Account 5/menit per IP, login 10/menit per IP, reset password 3/menit per IP.
- **NF-SEC-04:** Password di-hash dengan bcrypt cost factor 12; tidak pernah disimpan plaintext.
- **NF-SEC-05:** Tautan reset password di-hash SHA-256 dan berlaku satu kali (invalidasi setelah digunakan).
- **NF-SEC-06:** Data sensitif (email, nomor HP, alamat) dienkripsi AES-256 di database.
- **NF-SEC-07:** Mematuhi UU PDP; data pengguna tersimpan di server Indonesia; proteksi OWASP Top 10.

### 5.4 Software Quality Attributes

- **Availability:** Uptime >= 99.5%/bulan; maintenance terjadwal 00.00-04.00 WIB.
- **Maintainability:** PSR-12 coding standard; OpenAPI 3.0 docs; CI/CD GitHub Actions.
- **Portability:** Docker container; dapat berpindah ke cloud provider manapun.
- **Reliability:** Backup otomatis harian; Redis untuk session & cache.
- **Testability:** Unit test coverage min. 80%; Postman Collection untuk integration testing.

### 5.5 Business Rules

- **BR-01:** Lokal Coin hanya berlaku sebagai diskon dalam ekosistem LOKAL; tidak dapat dikonversi ke fiat.
- **BR-02:** Maks. 20% nilai transaksi dibayar dengan Lokal Coin; hangus setelah 6 bulan tidak digunakan.
- **BR-03:** Hanya UMKM terverifikasi yang dapat berjualan; semua transaksi melalui Midtrans berizin OJK.
- **BR-04:** Platform berperan sebagai marketplace (bukan lembaga keuangan).
- **BR-05:** Pembuatan akun hanya dapat dilakukan melalui fitur 'Register Account' resmi di aplikasi; backend bertanggung jawab penuh atas pembuatan akun.

---

## 6. Other Requirements

- **Database:** MySQL 8.0; tipe POINT untuk koordinat UMKM; JSON untuk atribut produk variabel; backup otomatis pukul 02.00 WIB, retensi 30 hari.
- **Internationalization:** MVP dalam Bahasa Indonesia; multi-bahasa (Inggris, Sunda) direncanakan v2.0; mata uang IDR.
- **Legal:** Mematuhi UU PDP No. 27/2022; regulasi OJK/BI; Syarat & Ketentuan + Kebijakan Privasi disetujui saat Register Account; data tidak digunakan untuk iklan pihak ketiga tanpa persetujuan.
- **Reuse:** Modul autentikasi JWT & koin sebagai reusable Laravel package; ML model dapat dilatih ulang per wilayah; n8n workflow templates dapat diimpor.
- **Email Service:** SMTP server (atau layanan seperti Mailgun/SendGrid) wajib dikonfigurasi untuk pengiriman email verifikasi, kredensial akun baru, dan reset password.

---

## Appendix A: Glossary

| **Istilah** | **Definisi** |
| --- | --- |
| UMKM | Usaha Mikro, Kecil, dan Menengah - target utama platform LOKAL. |
| Register Account | Fitur di aplikasi mobile yang memungkinkan pengguna membuat akun baru. Pengguna menekan tombol ini lalu mengisi form; backend secara otomatis membuat akun dan mengirimkan konfirmasi via email. |
| Lokal Coin | Token reward internal; diperoleh dari transaksi & ulasan; diskon maks. 20%; tidak bisa dicairkan. |
| Closed-loop Economy | Ekosistem ekonomi tertutup di mana nilai berputar dalam komunitas lokal. |
| JWT | JSON Web Token berbasis RFC 7519; digunakan autentikasi setiap request API. |
| Bcrypt | Algoritma hashing password adaptif (cost factor 12) untuk menyimpan password pengguna secara aman. |
| Email Verification | Proses konfirmasi kepemilikan email melalui tautan aktivasi yang dikirim setelah Register Account berhasil. |
| Password Reset | Mekanisme pemulihan akses menggunakan tautan sekali pakai yang dikirim ke email terdaftar. |
| Midtrans | Payment gateway Indonesia berizin BI/OJK (GoPay, OVO, DANA, VA, QRIS). |
| QRIS | Quick Response Code Indonesian Standard - standar QR pembayaran nasional BI. |
| n8n | Platform workflow automation open-source untuk orkestrasi notifikasi & distribusi koin. |
| UU PDP | UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi. |
| OJK | Otoritas Jasa Keuangan - pengawas sektor jasa keuangan Indonesia. |
| MVP | Minimum Viable Product - versi produk dengan fitur minimum untuk diuji pengguna awal. |
| TBD | To Be Determined - informasi yang belum tersedia saat penulisan dokumen. |

---

## Appendix B: Analysis Models

### B.1 API Endpoint Summary

Base URL: `https://api.lokal.id/v1`

| **Method** | **Endpoint** | **Deskripsi** | **Auth** |
| --- | --- | --- | --- |
| POST | /auth/register-account | Register Account baru (nama, email, password, peran) | Publik |
| POST | /auth/login | Login dengan email + password; dapatkan JWT | Publik |
| POST | /auth/verify-email | Verifikasi email dengan token aktivasi | Publik |
| POST | /auth/forgot-password | Kirim link reset password ke email | Publik |
| POST | /auth/reset-password | Reset password menggunakan token dari email | Publik |
| POST | /auth/refresh | Refresh access token menggunakan refresh token | Publik |
| DELETE | /auth/logout | Invalidasi token aktif (blacklist JWT) | Bearer |
| GET/PATCH | /users/me | Ambil / perbarui profil pengguna | Bearer |
| PATCH | /users/me/password | Ubah password (perlu password lama) | Bearer |
| GET | /products | Daftar produk dengan filter lokasi | Bearer |
| POST | /products | Tambah produk baru (UMKM) | Bearer+UMKM |
| GET/PATCH/DELETE | /products/{id} | Detail / update / hapus produk | Bearer/Bearer+UMKM |
| GET | /umkm/nearby | Daftar UMKM terdekat untuk peta | Bearer |
| POST | /orders | Buat pesanan dari keranjang | Bearer |
| GET | /orders | Riwayat pesanan pengguna | Bearer |
| PATCH | /orders/{id}/status | Update status pesanan (UMKM) | Bearer+UMKM |
| POST | /orders/{id}/review | Berikan ulasan produk | Bearer |
| GET | /wallet/balance | Saldo & ringkasan Lokal Coin | Bearer |
| GET | /wallet/history | Riwayat transaksi Lokal Coin | Bearer |
| GET | /umkm/analytics/summary | Ringkasan performa penjualan | Bearer+UMKM |
| GET/PATCH | /notifications | Daftar / tandai baca notifikasi | Bearer |

### B.2 Arsitektur Komponen

- **Client Layer:** Flutter 3.19 (Android API 24+ & iOS 14+) - modul Auth (Register Account), Market Map, Checkout, Wallet, Dashboard.
- **API Gateway Layer:** Nginx 1.25 - reverse proxy, SSL termination, rate limiting.
- **Backend Layer:** Laravel 11 API + n8n Workflow Engine + ML Service (Python/FastAPI).
- **Data Layer:** MySQL 8.0 + Redis 7.2 + MinIO Object Storage.
- **External Services:** Midtrans, Google Maps Platform, SMTP Server.

### B.3 Alur Register Account (Backend-Driven)

| **Langkah** | **Aktor** | **Aksi** | **Endpoint** |
| --- | --- | --- | --- |
| 1 | Pengguna | Menekan tombol 'Register Account' di layar onboarding/login | - |
| 2 | Pengguna | Mengisi form registrasi (nama, email, password, pilih peran: Konsumen/UMKM) | POST /auth/register-account |
| 3 | Backend | Validasi input, hash password (bcrypt cost 12), simpan ke DB dengan status unverified | - |
| 4 | Backend | Kirim email verifikasi dengan token aktivasi (berlaku 24 jam) | - |
| 5 | Pengguna | Klik link di email untuk aktivasi akun | POST /auth/verify-email |
| 6 | Backend | Aktifkan akun, beri 50 Lokal Coin secara otomatis | - |
| 7 | Pengguna | Login dengan email + password | POST /auth/login |
| 8 | Backend | Verifikasi password (bcrypt compare), generate JWT RS256, return access+refresh token | - |

### B.4 Alur Reset Password

1. Pengguna klik 'Lupa Password', masukkan email terdaftar.
2. Backend generate token reset (SHA-256, berlaku 1 jam), simpan hash di DB.
3. Backend kirim email berisi link reset dengan token.
4. Pengguna klik link, masukkan password baru + konfirmasi.
5. Backend validasi token, hash password baru, update DB, invalidasi token.
6. Backend kirim notifikasi email bahwa password berhasil diubah.

---

## Appendix C: To Be Determined List

| **No.** | **Item TBD** | **Target Resolusi** |
| --- | --- | --- |
| TBD-01 | Integrasi API logistik pihak ketiga (JNE, SiCepat, AnterAja) | Sprint 3 - Mei 2026 |
| TBD-02 | Video tutorial onboarding UMKM | v1.4.0 - Q3 2026 |
| TBD-03 | Dukungan multi-bahasa (Inggris, Sunda) | v2.0.0 - 2026 |
| TBD-04 | Threshold stok menipis: global atau per-produk? | Sprint 2 - April 2026 |
| TBD-05 | Algoritma ML spesifik (Linear Regression, Random Forest, dll.) | Sprint 4 - Mei 2026 |
| TBD-06 | Spesifikasi teknis panel admin verifikasi UMKM | Dokumen terpisah - Q2 2026 |
| TBD-07 | Mekanisme penyelesaian sengketa konsumen-UMKM | v1.5.0 - Q4 2026 |
| TBD-08 | Target concurrent users fase produksi penuh | Setelah evaluasi pilot |
| TBD-09 | Pemilihan SMTP provider (self-hosted Postfix, Mailgun, atau SendGrid) | Sprint 1 - Juli 2026 |
| TBD-10 | Desain UI detail layar Register Account (wireframe tahap 2 untuk UMKM) | Sprint 2 - Juli 2026 |

---

## Appendix D: Kesesuaian dengan Panduan Tugas Besar Kelas A2

| **Persyaratan Panduan** | **Status** | **Keterangan** |
| --- | --- | --- |
| Tema: Ketahanan Ekonomi / Digitalisasi Jasa Lokal | SESUAI | Platform LOKAL fokus pada sirkulasi ekonomi lokal & digitalisasi UMKM |
| Deskripsi Proyek & Latar Belakang Masalah | SESUAI | Tercakup di Bab 1.4 Product Scope |
| Business Process / Alur Kerja Sistem | SESUAI | Tercakup di Appendix B.3 & B.4 (alur Register Account & Reset Password) |
| Kebutuhan Fungsional | SESUAI | Tercakup di Bab 4 (F-01 s/d F-07) |
| Class Diagram (UML Lanjut) | PERLU DITAMBAHKAN | Belum ada di SRS; wajib ditambahkan sebagai lampiran di GitHub |
| Sequence Diagram | PERLU DITAMBAHKAN | Activity Diagram ada (Appendix B.4 v1.0) namun Sequence Diagram spesifik belum ada |
| Component Diagram | SEBAGIAN | Arsitektur komponen ada di B.2; perlu digambarkan dalam format diagram UML formal |
| Deployment Diagram (Docker topology) | SEBAGIAN | Disebutkan di B.2; perlu diagram visual topologi container Docker |
| Desain Kontrak API (REST endpoint list) | SESUAI | Tercakup lengkap di Appendix B.1 |
| Versi Dokumen & Catatan Perubahan | SESUAI | Revision History ada; versi 1.3.0 sudah diperbarui |
| Backend Laravel (RESTful API, bukan Blade) | SESUAI | Tercantum di Bab 2.1 & 2.4 |
| Frontend Flutter (mobile) | SESUAI | Flutter 3.19 digunakan sebagai client layer |
| Docker (Dockerfile & Docker Compose) | SESUAI | Tercantum di Bab 2.4 & 2.5 sebagai constraint wajib |
| Integrasi teknologi tambahan | SESUAI | Midtrans, Google Maps, n8n, ML Service (FastAPI), SMTP |
| Penelitian lapangan & notulensi | PERLU DILENGKAPI | Tidak termasuk dalam SRS; perlu dibuat sebagai dokumen terpisah di folder GitHub |
| Upload ke GitHub (clone/push/pull/merge) | DI LUAR CAKUPAN SRS | Harus dipastikan tim menggunakan Git commands (bukan upload langsung) |

