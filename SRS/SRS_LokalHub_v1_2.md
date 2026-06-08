# Software Requirements Specification (SRS)
## for Platform LOKAL  
**Platform Digital Berbasis Mobile untuk Optimalisasi Sirkulasi Ekonomi Lokal**

**Disusun Oleh:**

| Nama | NPM |
|------|------|
| Linda Anjarini | 20241320058 |
| Kiara Evi Nurdiati Putri Rahmatillah | 20241320067 |
| Najwa Alifah | 20241320077 |
| Ikhsan | 20241320083 |
| Naufal Al Farros | 20241320091 |
| Ikbal Maulana Aspahni | 20241320053 |
| Fito Zulhian Jabatami | 20241320074 |

**PROGRAM STUDI SISTEM INFORMASI**  
**FAKULTAS ILMU KOMPUTER DAN SISTEM INFORMASI**  
**UNIVERSITAS KEBANGSAAN REPUBLIK INDONESIA**  
**TAHUN 2026**

---

| Atribut | Nilai |
|---|---|
| Versi Dokumen | 1.2.0 - Juni 2026 |
| Status | Draft Revisi |
| Dibuat oleh | Tim Pengembang Platform LOKAL |
| Organisasi | Platform LOKAL - Bandung, Jawa Barat, Indonesia |
| Tanggal Dibuat | Juni 2026 |
| Klasifikasi | Internal - Dokumen Perancangan |
| Database | MySQL 8.0 |

---

## Revision History

| Name | Date | Reason For Changes | Version |
|---|---|---|---|
| Tim Pengembang LOKAL | April 2026 | Dokumen Teknis v1.1 dirilis | 1.1.0 |
| Tim Pengembang LOKAL | Juni 2026 | Perubahan autentikasi OTP menjadi Login & Register; penambahan UML lanjut (Class, Sequence, Component, Deployment Diagram); pembaruan ERD dan Activity Diagram | 1.2.0 |

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Overall Description](#2-overall-description)
3. [External Interface Requirements](#3-external-interface-requirements)
4. [System Features](#4-system-features)
5. [Other Nonfunctional Requirements](#5-other-nonfunctional-requirements)
6. [Other Requirements](#6-other-requirements)

Appendix A: Glossary  
Appendix B: Analysis Models  
Appendix C: To Be Determined List

---

# 1. Introduction

## 1.1 Purpose
Dokumen SRS ini mendefinisikan kebutuhan perangkat lunak Platform LOKAL v1.2.0 — aplikasi mobile ekosistem ekonomi digital tertutup (*closed-loop*) untuk mengoptimalkan sirkulasi ekonomi lokal di Kota Bandung dan sekitarnya. Versi 1.2.0 mencakup perubahan utama pada sistem autentikasi: mekanisme login berbasis OTP-saja diganti menjadi sistem **Login & Register** berbasis email/password dengan verifikasi OTP opsional. Dokumen ini mencakup kebutuhan fungsional, non-fungsional, antarmuka eksternal, dan arsitektur sistem sebagai acuan bagi tim developer, QA, manajer proyek, dan pemangku kepentingan.

## 1.2 Document Conventions
Dokumen mengikuti standar **IEEE 830-1998**. Prioritas ditandai: **Tinggi / Sedang / Rendah**.  
Kode fungsional: **F-XX**; non-fungsional: **NF-XX**. Istilah teknis didefinisikan di **Appendix A**.

## 1.3 Intended Audience and Reading Suggestions
- **Developer Backend/Frontend/Mobile:** Bab 3, 4, dan 5
- **Tim QA/Tester:** Bab 4 (test case) dan Bab 5 (pengujian performa)
- **Manajer Proyek:** Bab 1, 2, dan Bab 4 (scope dan prioritas)
- **Pemangku Kepentingan Bisnis:** Bab 1 dan 2
- **Arsitek Sistem:** Bab 3, 4, dan Appendix B

## 1.4 Product Scope
Platform LOKAL adalah aplikasi mobile (Android & iOS) yang menghubungkan konsumen dengan UMKM lokal menggunakan peta interaktif, sistem insentif token **Lokal Coin**, dan analitik pasar berbasis ML.  
Tujuan utama: mengurangi kebocoran ekonomi lokal, memberi akses digital bagi UMKM, dan membangun ekosistem ekonomi komunitas berkelanjutan.  
Fase pilot: Kota Bandung, Kab. Bandung, Kab. Bandung Barat, dan Kota Cimahi.

## 1.5 References
- Dokumen Teknis Sistem LOKAL v1.2.0 - Juni 2026.
- IEEE Std 830-1998: Recommended Practice for Software Requirements Specifications.
- UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi (UU PDP).
- Regulasi OJK dan Bank Indonesia terkait sistem pembayaran digital.
- Midtrans API Docs — https://docs.midtrans.com
- Laravel 11 — https://laravel.com/docs/11.x
- Flutter 3.19 — https://docs.flutter.dev
- Twilio Verify API — https://www.twilio.com/docs/verify

---

# 2. Overall Description

## 2.1 Product Perspective
Platform LOKAL adalah produk baru berupa marketplace berbasis lokasi yang menghubungkan penjual UMKM dan pembeli dalam ekosistem tertutup. Bukan lembaga keuangan — seluruh transaksi melalui **Midtrans**.

Komponen utama:
- Mobile App (Flutter 3.19)
- API Backend (Laravel 11)
- ML Service (Python/FastAPI)
- n8n Workflow Engine
- MySQL 8.0
- Layanan eksternal: Midtrans, Twilio Verify, Google Maps API

## 2.2 Product Functions
- **Autentikasi & Manajemen Pengguna:** Registrasi multi-peran dengan email & password, login email/password, verifikasi nomor telepon via OTP SMS (Twilio Verify), JWT RS256.
- **Peta Pasar & Katalog Produk:** Peta interaktif UMKM radius 0.5–10 km, CRUD produk, filter multi-kriteria.
- **Transaksi & Pembayaran:** Keranjang multi-UMKM, checkout via Midtrans (GoPay, OVO, DANA, VA, QRIS).
- **Lokal Coin & Insentif:** Reward 2% per transaksi, diskon maks. 20%, kadaluwarsa 6 bulan.
- **Rekomendasi Harga ML:** Analisis harga pasar lokal asinkron via Python/FastAPI.
- **Dashboard Analitik UMKM:** Grafik penjualan, produk terlaris, pendapatan bersih, real-time.
- **Notifikasi & Otomasi:** Push notification dan SMS otomatis via n8n untuk event transaksi.

## 2.3 User Classes and Characteristics
- **Konsumen:** Pembeli produk UMKM lokal; pengguna smartphone awam, frekuensi harian–mingguan.
- **UMKM/Penjual:** Pelaku usaha dengan kapasitas teknis terbatas; wajib terverifikasi NIB/SIUP.
- **Produsen:** Supplier/produsen grosir dalam ekosistem; karakteristik serupa UMKM.
- **Administrator (Internal):** Tim LOKAL, mengakses panel admin terpisah (di luar cakupan SRS ini).

## 2.4 Operating Environment
- **Mobile:** Android min. API 24 (7.0) & iOS min. 14.0; Flutter 3.19 + Riverpod + Dio.
- **Backend:** VPS Indonesia, Ubuntu 22.04, 8 vCPU, 16 GB RAM; PHP 8.3/Laravel 11 via Docker.
- **Database & Cache:** MySQL 8.0 + Redis 7.2-alpine; Object Storage: MinIO (S3-compatible).
- **Koneksi:** Internet aktif min. 3G/HSPA; data pengguna di server wilayah Indonesia (UU PDP).

## 2.5 Design and Implementation Constraints
- **Regulasi UU PDP:** Data pribadi wajib disimpan di server dalam wilayah Indonesia.
- **Regulasi OJK/BI:** Transaksi keuangan hanya melalui payment gateway berizin (Midtrans).
- **Lokal Coin** tidak dapat dikonversi ke fiat; maks. 20% dari nilai transaksi; hangus setelah 6 bulan.
- Teknologi wajib: Flutter, Laravel 11/PHP 8.3, MySQL 8.0, Docker.
- API response time maks. 500ms untuk endpoint kritikal; kapasitas pilot: 10.000 concurrent users.

## 2.6 User Documentation
- Panduan Pengguna Konsumen (in-app): Onboarding interaktif, tutorial Peta Pasar & Lokal Coin.
- Panduan Pengguna UMKM (in-app + PDF): Tutorial manajemen produk dan dashboard.
- FAQ In-App & Pusat Bantuan Online.
- TBD: Video tutorial onboarding UMKM (v1.2.0).

## 2.7 Assumptions and Dependencies
- **Asumsi:** Pengguna memiliki email aktif & smartphone kompatibel & internet aktif; UMKM bersedia mengunggah NIB/SIUP.
- **Dependensi eksternal:** Midtrans (pembayaran), Twilio Verify (verifikasi HP), Google Maps Platform (peta), Docker Hub (container registry), GitHub Actions (CI/CD).

---

# 3. External Interface Requirements

## 3.1 User Interfaces
- **Halaman Registrasi:** Form input nama lengkap, email, password, konfirmasi password, peran (Konsumen/UMKM), nomor telepon; tombol "Daftar".
- **Halaman Login:** Form email & password; tombol "Masuk"; link "Lupa Password" dan "Belum punya akun? Daftar".
- **Halaman Verifikasi Telepon:** Input kode OTP 6 digit yang dikirim ke nomor HP terdaftar.
- **Navigasi:** Bottom navigation bar 5 tab (Beranda, Peta Pasar, Keranjang, Dompet, Profil).
- **Peta Interaktif:** Google Maps SDK; marker UMKM dengan info window; filter radius 0.5–10 km.
- **Checkout Flow:** 3 langkah — Keranjang > Konfirmasi & Pembayaran > Status Pesanan.
- **Dashboard UMKM:** Line chart & bar chart penjualan, kartu ringkasan metrik.
- **Responsivitas & Aksesibilitas:** Mendukung 360–480dp (portrait) & tablet 600dp+; WCAG 2.1 level AA.

## 3.2 Hardware Interfaces
- GPS/Lokasi: Akurasi min. 50 meter; izin lokasi saat aplikasi digunakan.
- Kamera & Penyimpanan: Untuk unggah foto produk UMKM (izin kamera & galeri).
- Push Notification: FCM (Android) & APNs (iOS).
- Koneksi Internet: Min. 3G/HSPA; mode offline terbatas (riwayat transaksi dari cache lokal).

## 3.3 Software Interfaces
- **Midtrans:** SNAP API + webhook SHA-512; format JSON/HTTPS.
- **Twilio Verify:** Verifikasi nomor HP via SMS OTP 6 digit; timeout 10 menit.
- **Google Maps Platform:** Maps SDK + Geocoding API + Distance Matrix API.
- **ML Service (internal):** FastAPI Python 3.11 + scikit-learn; endpoint `http://ml-service:8000/api/price-recommendation` (asinkron).
- **n8n:** Self-hosted workflow automation; trigger HTTP webhook dari Laravel.
- **MinIO:** Object storage S3-compatible untuk foto produk & dokumen legalitas UMKM.

## 3.4 Communications Interfaces
- Protokol: HTTPS/TLS 1.2 min. (TLS 1.3 direkomendasikan); REST API format JSON.
- Base URL API: `https://api.lokal.id/v1`; autentikasi Bearer Token JWT RS256.
- Rate Limiting: Login 10 req/menit per IP; Register 5 req/menit per IP; OTP verifikasi 5 req/menit per nomor; endpoint umum 100 req/menit per token.
- Push Notification: FCM/APNs; tidak menggunakan WebSocket pada versi MVP.

---

# 4. System Features

Platform LOKAL memiliki 7 fitur sistem utama:

| Kode | Fitur | Deskripsi Singkat | Prioritas |
|---|---|---|---|
| F-01 | Autentikasi & Pengguna | Registrasi email/password multi-peran, login, verifikasi HP via OTP, JWT, verifikasi UMKM | Tinggi |
| F-02 | Peta Pasar & Produk | Peta interaktif UMKM radius 0.5–10 km, CRUD katalog produk | Tinggi |
| F-03 | Transaksi & Pembayaran | Keranjang multi-UMKM, checkout Midtrans (GoPay/OVO/DANA/VA/QRIS) | Tinggi |
| F-04 | Lokal Coin & Insentif | Reward 2%/transaksi, diskon maks. 20%, kadaluwarsa 6 bulan | Sedang |
| F-05 | Rekomendasi Harga ML | Analisis harga produk serupa radius 5 km secara asinkron | Sedang |
| F-06 | Dashboard Analitik UMKM | Grafik penjualan, produk terlaris, pendapatan bersih, real-time | Tinggi |
| F-07 | Notifikasi & Otomasi | Push notification & SMS via n8n untuk event transaksi | Tinggi |

---

## 4.1 F-01: Autentikasi & Pengguna

### 4.1.1 Description and Priority
Mengelola identitas pengguna melalui sistem **Register** dan **Login** berbasis email & password, dilengkapi verifikasi nomor telepon via OTP SMS.  
**Prioritas:** TINGGI.

### 4.1.2 Functional Requirements

**Registrasi (Register):**
- **REQ-F01-01:** Pengguna mendaftar dengan mengisi: nama lengkap, email, password (min. 8 karakter, kombinasi huruf & angka), konfirmasi password, peran (Konsumen / UMKM / Produsen), dan nomor telepon.
- **REQ-F01-02:** Sistem memvalidasi format email (RFC 5322) dan keunikan email sebelum menyimpan akun.
- **REQ-F01-03:** Password di-hash menggunakan bcrypt (cost factor 12) sebelum disimpan di database.
- **REQ-F01-04:** Setelah registrasi berhasil, sistem mengirimkan OTP 6 digit ke nomor telepon yang didaftarkan via Twilio Verify untuk verifikasi nomor HP.
- **REQ-F01-05:** OTP berlaku 10 menit; maks. 5 percobaan salah sebelum nomor diblokir 15 menit.
- **REQ-F01-06:** Akun aktif setelah verifikasi OTP berhasil; pengguna baru otomatis mendapat 50 Lokal Coin.
- **REQ-F01-07:** Akun UMKM/Produsen baru harus mengunggah dokumen NIB/SIUP; status akun "pending_verification" hingga admin menyetujui.

**Login:**
- **REQ-F01-08:** Pengguna login dengan email dan password.
- **REQ-F01-09:** Sistem memvalidasi kombinasi email & password; jika cocok, menerbitkan JWT RS256 (access token 24 jam, refresh token 30 hari).
- **REQ-F01-10:** Maks. 5 kali percobaan login gagal berturut-turut menyebabkan akun terkunci 15 menit (brute-force protection).
- **REQ-F01-11:** Fitur "Lupa Password" — pengguna memasukkan email; sistem mengirim link reset password valid 1 jam ke email terdaftar.

**Manajemen Sesi:**
- **REQ-F01-12:** JWT RS256; access token 24 jam, refresh token 30 hari; disimpan di Android Keystore / iOS Keychain.
- **REQ-F01-13:** Logout menginvalidasi token aktif (blacklist via Redis).

---

## 4.2 F-02: Peta Pasar & Produk

### 4.2.1 Description and Priority
Fitur inti: peta interaktif UMKM terdekat dan katalog produk.  
**Prioritas:** TINGGI.

### 4.2.2 Functional Requirements
- **REQ-F02-01:** Peta interaktif Google Maps SDK; marker setiap UMKM aktif dalam radius yang ditentukan.
- **REQ-F02-02:** Radius pencarian 0.5–10 km; default 5 km.
- **REQ-F02-03:** Pencarian produk berdasarkan nama, kategori, harga, jarak, dan rating.
- **REQ-F02-04:** CRUD produk oleh UMKM; maks. 5 foto per produk (maks. 2 MB/foto).
- **REQ-F02-05:** Pagination produk default 20 item/halaman; koordinat disimpan tipe POINT MySQL.

---

## 4.3 F-03: Transaksi & Pembayaran

### 4.3.1 Description and Priority
Mengelola seluruh alur transaksi dari pemilihan produk hingga konfirmasi.  
**Prioritas:** TINGGI.

### 4.3.2 Functional Requirements
- **REQ-F03-01:** Keranjang belanja multi-UMKM; validasi stok saat checkout.
- **REQ-F03-02:** Pembayaran via GoPay, OVO, DANA, VA Bank, QRIS melalui Midtrans.
- **REQ-F03-03:** Link/QR pembayaran kadaluwarsa 30 menit; webhook Midtrans divalidasi SHA-512.
- **REQ-F03-04:** Riwayat transaksi lengkap dengan filter tanggal & status; mendukung alur refund.

---

## 4.4 F-04: Lokal Coin & Insentif

### 4.4.1 Functional Requirements
- **REQ-F04-01:** Kredit otomatis 2% nilai transaksi saat status 'completed'; 5 koin per ulasan valid.
- **REQ-F04-02:** Maks. 20% nilai transaksi dapat dibayar dengan Lokal Coin; tidak bisa dikonversi ke fiat.
- **REQ-F04-03:** Koin hangus otomatis setelah 6 bulan; notifikasi 30 hari sebelum kadaluwarsa.
- **REQ-F04-04:** Setiap transaksi koin tercatat di riwayat dompet.

---

## 4.5 F-05: Rekomendasi Harga ML

### 4.5.1 Functional Requirements
- **REQ-F05-01:** Rekomendasi asinkron saat UMKM tambah produk baru; analisis radius 5 km.
- **REQ-F05-02:** Respons mencakup harga saran, rentang harga, dan jumlah produk serupa yang dianalisis.
- **REQ-F05-03:** Respons maks. 3 detik; graceful degradation jika ML Service tidak tersedia.

---

## 4.6 F-06: Dashboard Analitik UMKM

### 4.6.1 Functional Requirements
- **REQ-F06-01:** Grafik penjualan harian/mingguan/bulanan; data diperbarui maks. 5 menit setelah transaksi.
- **REQ-F06-02:** Menampilkan total pendapatan, pertumbuhan %, jumlah order, produk terlaris, rating, pelanggan baru.
- **REQ-F06-03:** Filter rentang tanggal kustom; hanya diakses akun UMKM terverifikasi (Bearer+UMKM role).

---

## 4.7 F-07: Notifikasi & Otomasi

### 4.7.1 Functional Requirements
- **REQ-F07-01:** Notifikasi konfirmasi pesanan (konsumen & UMKM), pembayaran berhasil/gagal, update status pengiriman.
- **REQ-F07-02:** Notifikasi peringatan stok menipis (< 10 unit) kepada UMKM.
- **REQ-F07-03:** Pengguna dapat mengatur preferensi notifikasi; semua alur diimplementasikan via n8n.

---

# 5. Other Nonfunctional Requirements

| Kategori | Persyaratan | Target |
|---|---|---|
| Performa | Waktu respons API endpoint kritikal | < 500ms |
| Performa | Waktu respons ML Service | < 3 detik |
| Skalabilitas | Pengguna konkuren fase pilot | 10.000 concurrent |
| Ketersediaan | Uptime sistem produksi | >= 99.5%/bulan |
| Keamanan | Enkripsi client-server | HTTPS/TLS 1.2+ |
| Keamanan | Enkripsi data sensitif di DB | AES-256 |
| Privasi | Lokasi penyimpanan data | Server Indonesia (UU PDP) |
| Portabilitas | Platform mobile | Android API 24+ & iOS 14+ |
| Pemeliharaan | Deployment & rollback | Zero-downtime (Docker+Watchtower) |
| Kegunaan | Waktu onboarding pengguna baru | <= 5 menit |

## 5.1 Performance Requirements
- **NF-PERF-01:** API kritikal (autentikasi, peta, checkout) maks. 500ms pada 1.000 concurrent request.
- **NF-PERF-02:** ML Service maks. 3 detik; graceful degradation jika melebihi batas.
- **NF-PERF-03:** Render peta 100+ marker UMKM < 2 detik di perangkat kelas menengah.
- **NF-PERF-04:** Query geospasial produk < 200ms menggunakan indeks SPATIAL MySQL.

## 5.2 Safety Requirements
- **NF-SAFE-01:** Rollback otomatis jika pembayaran gagal; stok tidak dikurangi saat order pending.
- **NF-SAFE-02:** Audit log immutable untuk seluruh transaksi keuangan dan perubahan status order.
- **NF-SAFE-03:** Idempotency untuk webhook Midtrans guna mencegah double processing.

## 5.3 Security Requirements
- **NF-SEC-01:** HTTPS/TLS 1.2+ untuk semua komunikasi client-server.
- **NF-SEC-02:** JWT RS256; disimpan di Android Keystore / iOS Keychain.
- **NF-SEC-03:** Rate limiting: Login 10 req/menit per IP; Register 5 req/menit per IP; OTP verifikasi 5 req/menit per nomor.
- **NF-SEC-04:** Password di-hash bcrypt cost 12; data sensitif (email, nomor HP, alamat) dienkripsi AES-256 di database.
- **NF-SEC-05:** Mematuhi UU PDP; data pengguna tersimpan di server Indonesia; proteksi OWASP Top 10.
- **NF-SEC-06:** Brute-force protection login: kunci akun 15 menit setelah 5 percobaan gagal berturut-turut.

## 5.4 Software Quality Attributes
- **Availability:** Uptime >= 99.5%/bulan; maintenance terjadwal 00.00–04.00 WIB.
- **Maintainability:** PSR-12 coding standard; OpenAPI 3.0 docs; CI/CD GitHub Actions.
- **Portability:** Docker container; dapat berpindah ke cloud provider manapun.
- **Reliability:** Backup otomatis harian; Redis untuk session & cache.
- **Testability:** Unit test coverage min. 80%; Postman Collection untuk integration testing.

## 5.5 Business Rules
- **BR-01:** Lokal Coin hanya berlaku sebagai diskon dalam ekosistem LOKAL; tidak dapat dikonversi ke fiat.
- **BR-02:** Maks. 20% nilai transaksi dibayar dengan Lokal Coin; hangus setelah 6 bulan tidak digunakan.
- **BR-03:** Hanya UMKM terverifikasi yang dapat berjualan; semua transaksi melalui Midtrans berizin OJK.
- **BR-04:** Platform berperan sebagai marketplace (bukan lembaga keuangan).
- **BR-05:** Registrasi wajib menggunakan email unik dan nomor telepon unik; duplikasi ditolak.

---

# 6. Other Requirements
- **Database:** MySQL 8.0; tipe POINT untuk koordinat UMKM; JSON untuk atribut produk variabel; backup otomatis pukul 02.00 WIB, retensi 30 hari.
- **Internationalization:** MVP dalam Bahasa Indonesia; multi-bahasa (Inggris, Sunda) direncanakan v2.0; mata uang IDR.
- **Legal:** Mematuhi UU PDP No. 27/2022; regulasi OJK/BI; Syarat & Ketentuan + Kebijakan Privasi disetujui saat registrasi; data tidak digunakan untuk iklan pihak ketiga tanpa persetujuan.
- **Reuse:** Modul autentikasi JWT & koin sebagai reusable Laravel package; ML model dapat dilatih ulang per wilayah; n8n workflow templates dapat diimpor.

---

# Appendix A: Glossary

| Istilah | Definisi |
|---|---|
| UMKM | Usaha Mikro, Kecil, dan Menengah — target utama platform LOKAL. |
| Lokal Coin | Token reward internal; diperoleh dari transaksi & ulasan; diskon maks. 20%; tidak bisa dicairkan. |
| Closed-loop Economy | Ekosistem ekonomi tertutup di mana nilai berputar dalam komunitas lokal. |
| OTP | Kode verifikasi 6 digit, berlaku 10 menit, dikirim via SMS Twilio Verify untuk verifikasi nomor telepon. |
| JWT | JSON Web Token berbasis RFC 7519; digunakan autentikasi setiap request API. |
| Midtrans | Payment gateway Indonesia berizin BI/OJK (GoPay, OVO, DANA, VA, QRIS). |
| QRIS | Quick Response Code Indonesian Standard — standar QR pembayaran nasional BI. |
| n8n | Platform workflow automation open-source untuk orkestrasi notifikasi & distribusi koin. |
| UU PDP | UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi. |
| OJK | Otoritas Jasa Keuangan — pengawas sektor jasa keuangan Indonesia. |
| MVP | Minimum Viable Product — versi produk dengan fitur minimum untuk diuji pengguna awal. |
| TBD | To Be Determined — informasi yang belum tersedia saat penulisan dokumen. |
| bcrypt | Algoritma hashing password adaptif; digunakan untuk menyimpan password pengguna secara aman. |
| Brute-force Protection | Mekanisme penguncian akun sementara setelah beberapa kali percobaan login gagal. |

---

# Appendix B: Analysis Models

## B.1 API Endpoint Summary (Updated v1.2.0)
**Base URL:** `https://api.lokal.id/v1`

| Method | Endpoint | Deskripsi | Auth |
|---|---|---|---|
| POST | /auth/register | Registrasi akun baru (email, password, peran, nomor HP) | Publik |
| POST | /auth/verify-phone | Verifikasi OTP nomor HP pasca-registrasi | Publik |
| POST | /auth/login | Login dengan email & password; mendapat JWT | Publik |
| POST | /auth/forgot-password | Kirim link reset password ke email | Publik |
| POST | /auth/reset-password | Reset password dengan token dari email | Publik |
| POST | /auth/refresh | Refresh access token | Publik |
| DELETE | /auth/logout | Invalidasi token aktif | Bearer |
| GET/PATCH | /users/me | Ambil / perbarui profil pengguna | Bearer |
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

---

## B.2 Activity Diagram — Alur Utama Platform LOKAL v1.2.0

Berikut adalah deskripsi alur Activity Diagram yang mencakup proses Register, Login, dan alur utama transaksi platform LOKAL.

```
ACTIVITY DIAGRAM — Alur Utama Platform LOKAL v1.2.0
=======================================================

[SWIMLANE: Konsumen/UMKM]          [SWIMLANE: Sistem (Platform LOKAL)]

=== ALUR REGISTER ===
Buka Aplikasi
     |
     v
Pilih "Daftar Akun"
     |
     v
Isi Form Registrasi                 --> Validasi Format Email & Keunikan
(Nama, Email, Password,             <-- [GAGAL] Tampilkan Error Validasi
 Peran, No. Telepon)                
     |                              --> [SUKSES] Hash Password (bcrypt)
     |                              --> Simpan User ke Database
     |                              --> Kirim OTP via Twilio Verify
     v
Masukkan Kode OTP                   
(6 digit, valid 10 menit)           --> Verifikasi OTP
     |                              --> [GAGAL] Tampilkan Error / Resend OTP
     |                              --> [SUKSES] Aktifkan Akun
     |                              --> Kredit 50 Lokal Coin (Welcome Bonus)
     v
[Akun Aktif → Lanjut ke Login]

=== ALUR LOGIN ===
Masukkan Email & Password           --> Validasi Kredensial
                                    --> [GAGAL] Cek Percobaan Gagal
                                    --> [>= 5x] Kunci Akun 15 Menit
                                    --> [SUKSES] Generate JWT RS256
                                        (Access 24 jam, Refresh 30 hari)
     v
Tampilkan Halaman Utama (Beranda)

=== ALUR BELANJA ===
Buka Peta Pasar                     --> Load UMKM Terdekat (radius 0.5-10 km)
                                        via Google Maps API
     |
     v
Pilih UMKM & Lihat Katalog Produk
     |
     v
Tambah Produk ke Keranjang          --> Validasi Stok & Harga
     |
     v
Lanjut ke Checkout
     |
     v
Pilih Metode Pembayaran             --> Hitung Total + Potongan Lokal Coin (maks. 20%)
(GoPay/OVO/QRIS/VA)                 --> Buat Transaksi Midtrans
     |                              --> Generate Payment Link/QR (30 menit)
     v
Selesaikan Pembayaran               --> Terima Webhook Midtrans (SHA-512)
                                    --> Update Status Order
                                    --> Kredit 2% Lokal Coin
                                    --> Trigger Notifikasi (n8n)
     v
Berikan Ulasan                      --> Kredit 5 Lokal Coin per Ulasan Valid
                                    --> Kirim ke ML Service (Asinkron - FastAPI)
                                        untuk Update Rekomendasi Harga

=== ALUR KELOLA PRODUK (UMKM) ===
Buka Menu Kelola Produk
     |
     v
Input/Edit/Hapus Data Produk        --> Simpan ke Database (MySQL)
                                    --> Kirim Request ke ML Service (Asinkron)
                                        Rekomendasi Harga Radius 5 km
     v
Lihat Dashboard Analitik            --> Query Data Penjualan (real-time, lag maks. 5 menit)
```

---

## B.3 Rancangan Database (ERD) — v1.2.0

Perubahan utama dari v1.1.0: tabel `users` diperbarui untuk mendukung email/password; tabel `otp_codes` dipisah menjadi untuk verifikasi HP (bukan lagi login); ditambah kolom `password_hash`, `email`, `email_verified_at`, `phone_verified_at`, `failed_login_attempts`, `locked_until`.

### Skema Tabel Utama

**Tabel: users**
```
id                    INT           PK, AUTO_INCREMENT
email                 VARCHAR(150)  UNIQUE, NOT NULL
password_hash         VARCHAR(255)  NOT NULL (bcrypt)
phone_number          VARCHAR(20)   UNIQUE
name                  VARCHAR(100)  NOT NULL
role                  ENUM('consumer','umkm','producer')
address               TEXT
location              POINT
fcm_token             VARCHAR(255)
is_active             TINYINT(1)    DEFAULT 0
email_verified_at     TIMESTAMP     NULL
phone_verified_at     TIMESTAMP     NULL
failed_login_attempts TINYINT       DEFAULT 0
locked_until          TIMESTAMP     NULL
password_reset_token  VARCHAR(100)  NULL
password_reset_exp    TIMESTAMP     NULL
created_at            TIMESTAMP
updated_at            TIMESTAMP
```

**Tabel: umkm_profiles**
```
id                    INT           PK
user_id               INT           FK → users.id
shop_name             VARCHAR(150)
description           TEXT
location              POINT
nib_number            VARCHAR(50)
siup_number           VARCHAR(50)
verification_status   ENUM('pending','verified','rejected')
banner_image          VARCHAR(255)
verified_at           TIMESTAMP
```

**Tabel: otp_codes** *(digunakan hanya untuk verifikasi nomor HP)*
```
id                    INT           PK
phone_number          VARCHAR(20)   NOT NULL
code                  CHAR(6)
purpose               ENUM('phone_verification','phone_change')
attempt_count         TINYINT
is_used               TINYINT(1)
expired_at            TIMESTAMP     (10 menit TTL)
created_at            TIMESTAMP
```

**Tabel: password_resets** *(baru di v1.2.0)*
```
id                    INT           PK
user_id               INT           FK → users.id
token                 VARCHAR(100)  UNIQUE
expired_at            TIMESTAMP     (1 jam TTL)
used_at               TIMESTAMP     NULL
created_at            TIMESTAMP
```

**Tabel: wallets**
```
id                    INT           PK
user_id               INT           FK → users.id
balance               DECIMAL(15,2) DEFAULT 0
coin_discount         DECIMAL(15,2)
total_amount          DECIMAL(15,2)
updated_at            TIMESTAMP
```

**Tabel: products**
```
id                    INT           PK
umkm_id               INT           FK → umkm_profiles.id
category_id           INT           FK → categories.id
name                  VARCHAR(200)
description           TEXT
price                 DECIMAL(15,2)
stock                 INT
attributes            JSON
status                ENUM('active','inactive','draft')
latitude              DECIMAL(10,8)
longitude             DECIMAL(11,8)
created_at            TIMESTAMP
updated_at            TIMESTAMP
```

**Tabel: orders**
```
id                    INT           PK
consumer_id           INT           FK → users.id
umkm_id               INT           FK → umkm_profiles.id
order_code            VARCHAR(50)   UNIQUE
subtotal              DECIMAL(15,2)
coin_discount         DECIMAL(15,2)
total_amount          DECIMAL(15,2)
payment_method        ENUM
payment_status        ENUM('pending','paid','failed','refunded')
order_status          ENUM('pending','confirmed','processing','shipped','completed','cancelled')
midtrans_token        VARCHAR(255)
payment_expired_at    TIMESTAMP
created_at            TIMESTAMP
updated_at            TIMESTAMP
```

**Tabel: order_items**
```
id                    INT           PK
order_id              INT           FK → orders.id
product_id            INT           FK → products.id
quantity              INT
unit_price            DECIMAL(15,2)
subtotal              DECIMAL(15,2)
created_at            TIMESTAMP
```

**Tabel: coin_transactions**
```
id                    INT           PK
wallet_id             INT           FK → wallets.id
order_id              INT           FK → orders.id (nullable)
type                  ENUM('earn','spend','expire','bonus')
amount                DECIMAL(15,2)
balance_after         DECIMAL(15,2)
description           TEXT
expired_at            TIMESTAMP
created_at            TIMESTAMP
```

**Tabel: reviews**
```
id                    INT           PK
order_id              INT           FK → orders.id
consumer_id           INT           FK → users.id
product_id            INT           FK → products.id
rating                TINYINT       (1–5)
comment               TEXT
coin_credited         TINYINT(1)    DEFAULT 0
created_at            TIMESTAMP
```

**Tabel: notifications**
```
id                    INT           PK
user_id               INT           FK → users.id
order_id              INT           FK → orders.id (nullable)
title                 VARCHAR(200)
body                  TEXT
type                  ENUM
is_read               TINYINT(1)
created_at            TIMESTAMP
```

**Tabel: product_images**
```
id                    INT           PK
product_id            INT           FK → products.id
image_url             VARCHAR(500)
sort_order            INT
created_at            TIMESTAMP
```

**Tabel: price_recommendations**
```
id                    INT           PK
product_id            INT           FK → products.id
suggested_price       DECIMAL(15,2)
min_price             DECIMAL(15,2)
max_price             DECIMAL(15,2)
sample_count          INT
radius_km             FLOAT
created_at            TIMESTAMP
```

**Tabel: categories**
```
id                    INT           PK
name                  VARCHAR(100)
slug                  VARCHAR(100)
parent_id             INT           FK → categories.id (nullable)
created_at            TIMESTAMP
```

**Tabel: notification_preferences**
```
id                    INT           PK
user_id               INT           FK → users.id
order_updates         TINYINT(1)
payment_alerts        TINYINT(1)
stock_alerts          TINYINT(1)
coin_expiry           TINYINT(1)
updated_at            TIMESTAMP
```

---

## B.4 UML Lanjut

### B.4.1 Class Diagram

Class Diagram berikut menggambarkan struktur domain bisnis utama Platform LOKAL.

```
+------------------+          +---------------------+
|      User        |          |    UmkmProfile       |
+------------------+          +---------------------+
| - id: int        |1        1| - id: int            |
| - email: string  |----------| - userId: int        |
| - passwordHash   |          | - shopName: string   |
| - phoneNumber    |          | - location: Point    |
| - name: string   |          | - nibNumber: string  |
| - role: RoleEnum |          | - verificationStatus |
| - isActive: bool |          +---------------------+
| - failedAttempts |          | + getProducts()      |
| - lockedUntil    |          | + getDashboard()     |
+------------------+          +---------------------+
| + register()     |                   |1
| + login()        |                   |
| + verifyPhone()  |                   |* has many
| + resetPassword()|          +---------------------+
| + logout()       |          |      Product         |
+------------------+          +---------------------+
        |1                    | - id: int            |
        |                     | - umkmId: int        |
        |* has many           | - categoryId: int    |
+------------------+          | - name: string       |
|     Wallet       |          | - price: decimal     |
+------------------+          | - stock: int         |
| - id: int        |          | - status: StatusEnum |
| - userId: int    |          | - location: Point    |
| - balance: dec   |          +---------------------+
+------------------+          | + create()           |
| + getBalance()   |          | + update()           |
| + earnCoins()    |          | + delete()           |
| + spendCoins()   |          | + getPriceRec()      |
| + checkExpiry()  |          +---------------------+
+------------------+                   |
        |1                             |
        |* has many                    |* contained in
+-----------------------+    +---------------------+
|   CoinTransaction     |    |      OrderItem       |
+-----------------------+    +---------------------+
| - id: int             |    | - id: int            |
| - walletId: int       |    | - orderId: int       |
| - type: TypeEnum      |    | - productId: int     |
| - amount: decimal     |    | - quantity: int      |
| - expiredAt: datetime |    | - unitPrice: decimal |
+-----------------------+    +---------------------+
                                       |*
                             +---------------------+
                             |        Order         |
+------------------+         +---------------------+
|     Review       |         | - id: int            |
+------------------+    *    | - consumerId: int    |
| - id: int        |-------->| - umkmId: int        |
| - orderId: int   |         | - orderCode: string  |
| - consumerId: int|         | - totalAmount: dec   |
| - productId: int |         | - paymentStatus: Enum|
| - rating: int    |         | - orderStatus: Enum  |
| - comment: string|         +---------------------+
+------------------+         | + create()           |
| + submit()       |         | + updateStatus()     |
| + creditCoins()  |         | + processPayment()   |
+------------------+         | + cancel()           |
                             +---------------------+

+---------------------+      +------------------------+
|  PriceRecommendation|      |    Notification        |
+---------------------+      +------------------------+
| - id: int           |      | - id: int              |
| - productId: int    |      | - userId: int          |
| - suggestedPrice    |      | - orderId: int         |
| - minPrice: decimal |      | - type: TypeEnum       |
| - maxPrice: decimal |      | - isRead: bool         |
| - radiusKm: float   |      +------------------------+
+---------------------+      | + send()               |
| + generate()        |      | + markRead()           |
+---------------------+      +------------------------+

Enumerations:
  RoleEnum: consumer | umkm | producer
  StatusEnum: active | inactive | draft
  PaymentStatus: pending | paid | failed | refunded
  OrderStatus: pending | confirmed | processing | shipped | completed | cancelled
  CoinTypeEnum: earn | spend | expire | bonus
```

---

### B.4.2 Sequence Diagram — Alur Autentikasi (Register & Login)

**Sequence Diagram 1: Register**

```
Pengguna        MobileApp       API Laravel      MySQL       Redis       Twilio Verify
    |               |               |              |            |               |
    |--isiForm()-->|                |              |            |               |
    |               |--POST /auth/register-------->|            |               |
    |               |               |--validateEmail()          |               |
    |               |               |--checkEmailUnique()------>|               |
    |               |               |<----emailAvailable--------|               |
    |               |               |--hashPassword(bcrypt)     |               |
    |               |               |--saveUser()-------------->|               |
    |               |               |<---userId-----------------|               |
    |               |               |--sendOTP()-------------------------------->|
    |               |               |<---otpSent--------------------------------|
    |               |               |--saveOTP(Redis TTL 10min)----->|          |
    |               |<--201 Created + "verifikasi HP"               |           |
    |<--tampilFormOTP()             |                               |           |
    |--inputOTP()--->|              |                               |           |
    |               |--POST /auth/verify-phone----->|               |           |
    |               |               |--getOTP()----->|              |           |
    |               |               |<---otpData-----|              |           |
    |               |               |--validateOTP()               |            |
    |               |               |--activateUser()-------------->|            |
    |               |               |--creditWelcomeCoins(50)------>|            |
    |               |               |--deleteOTP()--------->|                   |
    |               |<--200 OK + JWT (access+refresh)       |                   |
    |<--HomeScreen()|               |                       |                   |
```

**Sequence Diagram 2: Login**

```
Pengguna        MobileApp       API Laravel      MySQL       Redis
    |               |               |              |            |
    |--inputCreds()->|               |              |            |
    |               |--POST /auth/login------------>|            |
    |               |               |--findByEmail()----------->|
    |               |               |<---userData---------------|
    |               |               |--checkLocked()            |
    |               |               |  [locked] return 423------->|
    |               |               |--verifyPassword(bcrypt)   |
    |               |               |  [salah] incFailedAttempts()->|
    |               |               |  [>= 5x] lockAccount(15min)->|
    |               |               |  [benar] resetFailedAttempts()
    |               |               |--generateJWT(RS256)       |
    |               |               |--storeRefreshToken()----------->|
    |               |<--200 OK + {access_token, refresh_token}  |
    |<--HomeScreen()|               |                           |
```

---

### B.4.3 Sequence Diagram — Alur Transaksi

```
Konsumen     MobileApp    API Laravel   Midtrans    MySQL    n8n    UMKM
    |            |             |            |          |       |       |
    |--checkout()->|            |            |          |       |       |
    |            |--POST /orders----------->|           |       |       |
    |            |             |--validateStock()------>|       |       |
    |            |             |--calculateTotal()      |       |       |
    |            |             |--createOrder()-------->|       |       |
    |            |             |--createMidtransCharge()-->|    |       |
    |            |             |<---paymentToken--------|      |       |
    |            |<--paymentURL/QR          |           |       |       |
    |--bayar()-->|             |            |           |       |       |
    |            |             |<---webhook(SHA512)----|        |       |
    |            |             |--verifySignature()    |        |       |
    |            |             |--updateOrderStatus()--->|      |       |
    |            |             |--creditLokalCoin()---->|       |       |
    |            |             |--triggerN8n()------------------------->|
    |            |             |            |           |   sendNotif()->|
    |            |             |            |           |       |    (UMKM & Konsumen)
    |<--notifikasi pembayaran berhasil
```

---

## B.5 Arsitektur Sistem

### B.5.1 Component Diagram

```
+================================================================+
|                    PLATFORM LOKAL SYSTEM                       |
+================================================================+
|                                                                |
|  +---------------------------+                                 |
|  |    <<Mobile App>>         |                                 |
|  |    Flutter 3.19           |                                 |
|  |  +---------------------+  |                                 |
|  |  | Auth Module         |  |                                 |
|  |  | (Login/Register)    |  |                                 |
|  |  +---------------------+  |                                 |
|  |  | Market Map Module   |  |                                 |
|  |  +---------------------+  |                                 |
|  |  | Checkout Module     |  |                                 |
|  |  +---------------------+  |                                 |
|  |  | Wallet Module       |  |                                 |
|  |  +---------------------+  |                                 |
|  |  | UMKM Dashboard Mod  |  |                                 |
|  |  +---------------------+  |                                 |
|  +------------||--------------+                                |
|               || HTTPS/TLS 1.3                                 |
|  +------------||--------------+                                |
|  |    <<API Gateway>>         |                                |
|  |    Nginx 1.25              |                                |
|  |  (SSL Termination,         |                                |
|  |   Rate Limiting,           |                                |
|  |   Load Balancing)          |                                |
|  +------------||--------------+                                |
|               ||                                              |
|   +-----------||----------+  +--------------------+           |
|   | <<Backend Service>>   |  | <<Workflow Engine>>|           |
|   | Laravel 11 API        |  | n8n                |           |
|   |  + Auth Controller    |  |  + Order Notif     |           |
|   |  + Product Controller |  |  + Coin Expiry     |           |
|   |  + Order Controller   |  |  + SMS Dispatch    |           |
|   |  + Wallet Controller  |<-|  (HTTP Webhook)    |           |
|   |  + UMKM Controller    |  +--------------------+           |
|   +-----------||----------+                                   |
|               ||                                              |
|   +-----------||----------+  +--------------------+           |
|   | <<ML Service>>        |  | <<Data Layer>>     |           |
|   | Python FastAPI        |  |  MySQL 8.0         |           |
|   |  + Price Recommender  |  |  Redis 7.2         |           |
|   |  + scikit-learn Model |  |  MinIO Storage     |           |
|   +-----------------------+  +--------------------+           |
|                                                                |
+================================================================+

External Services:
  [Midtrans] -- payment gateway
  [Twilio Verify] -- OTP SMS verification
  [Google Maps API] -- geolocation & map
```

---

### B.5.2 Deployment Diagram

```
+================================================================+
|              VPS INDONESIA (Ubuntu 22.04)                      |
|              8 vCPU | 16 GB RAM | SSD 200 GB                  |
|                                                                |
|  +---------------------------+   +-------------------------+   |
|  | <<Docker Container>>      |   | <<Docker Container>>    |   |
|  | nginx:1.25-alpine         |   | php:8.3-fpm + Laravel11 |   |
|  | Port: 80, 443             |   | Port: 9000 (internal)   |   |
|  | (Reverse Proxy + SSL)     |<->| APP_KEY, JWT_PRIVATE_KEY|   |
|  +---------------------------+   +-------------------------+   |
|                                           |                    |
|  +---------------------------+   +-------------------------+   |
|  | <<Docker Container>>      |   | <<Docker Container>>    |   |
|  | mysql:8.0                 |   | redis:7.2-alpine        |   |
|  | Port: 3306 (internal)     |   | Port: 6379 (internal)   |   |
|  | Volume: /data/mysql       |   | (Session, Cache, OTP)   |   |
|  +---------------------------+   +-------------------------+   |
|                                                                |
|  +---------------------------+   +-------------------------+   |
|  | <<Docker Container>>      |   | <<Docker Container>>    |   |
|  | n8n:latest                |   | fastapi:python3.11      |   |
|  | Port: 5678 (internal)     |   | Port: 8000 (internal)   |   |
|  | Volume: /data/n8n         |   | (ML Price Recommender)  |   |
|  +---------------------------+   +-------------------------+   |
|                                                                |
|  +---------------------------+                                 |
|  | <<Docker Container>>      |                                 |
|  | minio:latest              |                                 |
|  | Port: 9000, 9001          |                                 |
|  | Volume: /data/minio       |                                 |
|  | (S3-compatible Storage)   |                                 |
|  +---------------------------+                                 |
|                                                                |
|  <<Docker Network: lokal-net (bridge)>>                       |
|  <<Watchtower: auto zero-downtime update>>                    |
+================================================================+
         |                        |
         v                        v
+-------------------+   +------------------+
| <<External SaaS>> |   | <<Client>>       |
| Midtrans API      |   | Flutter Mobile   |
| Twilio Verify API |   | Android API 24+  |
| Google Maps API   |   | iOS 14+          |
+-------------------+   +------------------+

Backup: Cronjob 02:00 WIB → mysqldump → MinIO (retensi 30 hari)
CI/CD: GitHub Actions → Docker Hub → Watchtower pull & restart
```

---

## B.6 Use Case Diagram

*(Lihat dokumen terlampir — use case diagram versi visual)*

Aktor dan use case utama:
- **Konsumen:** Register, Login, Browse Peta Pasar, Lihat Produk, Tambah ke Keranjang, Checkout, Bayar, Beri Ulasan, Kelola Dompet Lokal Coin.
- **UMKM:** Register (+ Upload NIB/SIUP), Login, Kelola Produk, Lihat Dashboard Analitik, Update Status Order.
- **Sistem (Platform LOKAL):** Kirim OTP Verifikasi HP, Proses Pembayaran Midtrans, Distribusi Lokal Coin, Kirim Notifikasi n8n, Rekomendasi Harga ML.
- **Admin:** Verifikasi Akun UMKM (panel terpisah).

---

## B.7 Rancangan Arsitektur Teknologi

*(Lihat diagram arsitektur terlampir)*

Stack teknologi:
- **Mobile Layer:** Flutter 3.19, Riverpod (state management), Dio (HTTP client), Google Maps SDK.
- **API Gateway Layer:** Nginx 1.25 (SSL termination, rate limiting, load balancing).
- **Backend Layer:** Laravel 11 / PHP 8.3, JWT RS256, Midtrans SNAP SDK.
- **Automation Layer:** n8n self-hosted workflow engine.
- **ML Layer:** Python 3.11, FastAPI, scikit-learn.
- **Data Layer:** MySQL 8.0 (SPATIAL index), Redis 7.2, MinIO.
- **External Services:** Midtrans, Twilio Verify, Google Maps Platform.
- **DevOps:** Docker Compose, GitHub Actions (CI/CD), Watchtower (auto-update).

---

## B.8 UI Screens

*(Lihat lampiran mockup UI yang telah dibuat sebelumnya)*

Layar tambahan v1.2.0:
- **Layar Register:** Form nama, email, password, konfirmasi password, peran, nomor telepon.
- **Layar Login:** Form email, password; link "Lupa Password".
- **Layar Verifikasi HP:** Input 6-digit OTP; tombol "Kirim Ulang".
- **Layar Lupa Password:** Input email; informasi pengiriman link reset.

---

# Appendix C: To Be Determined List

| No. | Item TBD | Target Resolusi |
|---|---|---|
| TBD-01 | Integrasi API logistik pihak ketiga (JNE, SiCepat, AnterAja) | Sprint 3 - Juli 2026 |
| TBD-02 | Video tutorial onboarding UMKM | v1.3.0 - Q3 2026 |
| TBD-03 | Dukungan multi-bahasa (Inggris, Sunda) | v2.0.0 - 2027 |
| TBD-04 | Threshold stok menipis: global atau per-produk? | Sprint 2 - Juni 2026 |
| TBD-05 | Algoritma ML spesifik (Linear Regression, Random Forest, dll.) | Sprint 4 - Juli 2026 |
| TBD-06 | Spesifikasi teknis panel admin verifikasi UMKM | Dokumen terpisah - Q2 2026 |
| TBD-07 | Mekanisme penyelesaian sengketa konsumen–UMKM | v1.5.0 - Q4 2026 |
| TBD-08 | Target concurrent users fase produksi penuh | Setelah evaluasi pilot |
| TBD-09 | Mekanisme Social Login (Google/Apple Sign-In) | v1.3.0 - Q3 2026 |
| TBD-10 | Two-Factor Authentication (2FA) opsional untuk akun UMKM | v1.3.0 - Q3 2026 |

---
