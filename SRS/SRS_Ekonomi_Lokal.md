# Software Requirements Specification (SRS)

# Platform LOKAL v1.5.0

*Platform Digital Berbasis Mobile untuk Optimalisasi Sirkulasi Ekonomi Lokal*

| **Nama** | **NPM** |
| --- | --- |
| Linda Anjarini | 20241320058 |
| Kiara Evi Nurdiati Putri Rahmatillah | 20241320067 |
| Najwa Alifah | 20241320077 |
| Ikhsan | 20241320083 |
| Naufal Al Farros | 20241320091 |
| Ikbal Maulana Aspahni | 20241320053 |

**PROGRAM STUDI SISTEM INFORMASI**

FAKULTAS ILMU KOMPUTER DAN SISTEM INFORMASI

UNIVERSITAS KEBANGSAAN REPUBLIK INDONESIA

TAHUN 2026

| **Atribut** | **Nilai** |
| --- | --- |
| Versi Dokumen | 1.5.0 - Juli 2026 |
| Status | Draft Revisi |
| Dibuat oleh | Tim Pengembang Platform LOKAL |
| Perubahan Utama | Penambahan 5 fitur baru: Order Tracking, Otomatisasi Pembayaran Midtrans, LOKAL AI Assistant, Verifikasi Bank UMKM & Withdrawal, Aturan Refund & Pembatalan Otomatis |
| Database | MySQL 8.0 |

---

## Revision History

| **Name** | **Date** | **Reason For Changes** | **Version** |
| --- | --- | --- | --- |
| Tim Pengembang LOKAL | April 2026 | Dokumen Teknis v1.1 dirilis | 1.1.0 |
| Tim Pengembang LOKAL | Juni 2026 | Autentikasi diganti ke Email + Password (OTP dihapus) | 1.2.0 |
| Tim Pengembang LOKAL | Juni 2026 | Metode register diubah ke Register Account (backend-driven via tombol di app); Role Produsen dihapus dari sistem | 1.3.0 |
| Tim Pengembang LOKAL | Juli 2026 | Penambahan fitur: (1) Order Tracking System dengan nomor resi & timeline pelacakan; (2) Otomatisasi pembayaran via Webhook Midtrans; (3) LOKAL AI Assistant berbasis Gemini API; (4) Verifikasi Bank UMKM & Manajemen Withdrawal; (5) Aturan Refund & Pembatalan Otomatis | 1.5.0 |

---

## 1. Introduction

### 1.1 Purpose

Dokumen SRS ini mendefinisikan kebutuhan perangkat lunak Platform LOKAL v1.5.0 - aplikasi mobile ekosistem ekonomi digital tertutup (closed-loop) untuk mengoptimalkan sirkulasi ekonomi lokal di Kota Bandung dan sekitarnya. Versi ini menghadirkan lima fitur utama baru: (1) Sistem Pelacakan Pesanan (Order Tracking) dengan nomor resi dan timeline real-time; (2) Otomatisasi konfirmasi pembayaran menggunakan Webhook Midtrans; (3) LOKAL AI Assistant berbasis Google Gemini API; (4) Verifikasi rekening bank UMKM sebelum pencairan dana (withdrawal); (5) Aturan refund koin dan pembatalan otomatis.

### 1.2 Document Conventions

Dokumen mengikuti standar IEEE 830-1998. Prioritas: Tinggi / Sedang / Rendah. Kode fungsional: F-XX; non-fungsional: NF-XX. Istilah teknis didefinisikan di Appendix A.

### 1.3 Intended Audience and Reading Suggestions

- **Developer Backend/Frontend/Mobile:** Bab 3, 4, dan 5
- **Tim QA/Tester:** Bab 4 (test case) dan Bab 5 (pengujian performa)
- **Manajer Proyek:** Bab 1, 2, dan Bab 4 (scope dan prioritas)
- **Pemangku Kepentingan Bisnis:** Bab 1 dan 2
- **Arsitek Sistem:** Bab 3, 4, dan Appendix B

### 1.4 Product Scope

Platform LOKAL adalah aplikasi mobile (Android & iOS) yang menghubungkan konsumen dengan UMKM lokal menggunakan peta interaktif, sistem insentif token Lokal Coin, analitik pasar berbasis ML, serta asisten AI cerdas. Tujuan utama: mengurangi kebocoran ekonomi lokal, memberi akses digital bagi UMKM, dan membangun ekosistem ekonomi komunitas berkelanjutan. Fase pilot: Kota Bandung, Kab. Bandung, Kab. Bandung Barat, dan Kota Cimahi.

### 1.5 References

- Dokumen Teknis Sistem LOKAL v1.5.0 - Juli 2026
- IEEE Std 830-1998: Recommended Practice for Software Requirements Specifications
- UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi (UU PDP)
- Regulasi OJK dan Bank Indonesia terkait sistem pembayaran digital
- Midtrans API Docs - https://docs.midtrans.com
- Google Gemini API Docs - https://ai.google.dev/docs
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
- LOKAL AI Assistant (Google Gemini API)
- n8n Workflow Engine
- MySQL 8.0
- Layanan eksternal: Midtrans, Google Maps API, Google Gemini API, SMTP Server

### 2.2 Product Functions

- **Autentikasi & Manajemen Pengguna:** Register Account (backend-driven), login Email+Password, JWT RS256, verifikasi UMKM.
- **Peta Pasar & Katalog Produk:** Peta interaktif UMKM radius 0.5-10 km, CRUD produk, filter multi-kriteria.
- **Transaksi & Pembayaran:** Keranjang multi-UMKM, checkout via Midtrans (GoPay, OVO, DANA, VA, QRIS), **otomatisasi konfirmasi pembayaran via webhook**.
- **Sistem Pelacakan Pesanan (Order Tracking):** UMKM wajib input nomor resi saat ubah status ke 'shipped'; konsumen lihat timeline pelacakan real-time dari tabel `order_histories`.
- **Lokal Coin & Insentif:** Reward 2% per transaksi sebagai cashback otomatis, diskon maks. 20%, kadaluwarsa 6 bulan.
- **LOKAL AI Assistant:** Chatbot berbasis Google Gemini API (gemini-1.5-flash) untuk membantu UMKM dan konsumen dalam Bahasa Indonesia kasual.
- **Rekomendasi Harga ML:** Analisis harga pasar lokal asinkron via Python/FastAPI.
- **Dashboard Analitik UMKM:** Grafik penjualan, produk terlaris, pendapatan bersih, real-time.
- **Manajemen Verifikasi Bank & Withdrawal:** UMKM daftar rekening bank, diverifikasi Admin, lalu bisa cairkan saldo tunai.
- **Notifikasi & Otomasi:** Push notification otomatis via n8n untuk event transaksi.

### 2.3 User Classes and Characteristics

| **Role** | **Deskripsi** | **Karakteristik** |
| --- | --- | --- |
| Konsumen | Pembeli produk UMKM lokal | Pengguna smartphone awam, frekuensi harian-mingguan |
| UMKM / Penjual | Pelaku usaha lokal | Kapasitas teknis terbatas; wajib terverifikasi NIB/SIUP sebelum berjualan; **wajib verifikasi rekening bank sebelum pencairan dana** |
| Administrator | Tim internal LOKAL | Akses panel admin untuk verifikasi UMKM, verifikasi bank, manajemen pengguna & sistem |

> *Catatan: Role Produsen telah dihapus dari sistem sejak versi 1.3.0.*

### 2.4 Operating Environment

- **Mobile:** Android min. API 24 (7.0) & iOS min. 14.0; Flutter 3.19 + Riverpod + Dio.
- **Backend:** VPS Indonesia, Ubuntu 22.04, 8 vCPU, 16 GB RAM; PHP 8.3/Laravel 11 via Docker.
- **Database & Cache:** MySQL 8.0 + Redis 7.2-alpine; Object Storage: MinIO (S3-compatible).
- **AI Service:** Google Gemini API (gemini-1.5-flash); API Key disimpan di file `.env` backend.
- **Koneksi:** Internet aktif min. 3G/HSPA; data pengguna di server wilayah Indonesia (UU PDP).

### 2.5 Design and Implementation Constraints

- Regulasi UU PDP: Data pribadi wajib disimpan di server dalam wilayah Indonesia.
- Regulasi OJK/BI: Transaksi keuangan hanya melalui payment gateway berizin (Midtrans).
- Lokal Coin tidak dapat dikonversi ke fiat; maks. 20% dari nilai transaksi; hangus setelah 6 bulan.
- Teknologi wajib: Flutter, Laravel 11/PHP 8.3, MySQL 8.0, Docker.
- API response time maks. 500ms untuk endpoint kritikal; kapasitas pilot: 10.000 concurrent users.
- Password wajib di-hash menggunakan bcrypt (cost factor min. 12) sebelum disimpan di database.
- Proses Register Account diinisiasi oleh pengguna melalui tombol di aplikasi; backend menangani pembuatan akun dan pengiriman kredensial via email.
- **Webhook Midtrans: Endpoint wajib publik tanpa autentikasi; validasi signature SHA-512; harus idempoten untuk mencegah double processing.**
- **LOKAL AI Assistant: API Key Gemini disimpan hanya di `.env` server, tidak boleh diekspos ke client Flutter.**
- **Verifikasi Bank: Tombol withdrawal di Flutter wajib disabled jika status verifikasi bank UMKM belum 'approved'.**

### 2.6 User Documentation

- Panduan Pengguna Konsumen (in-app): Onboarding interaktif, tutorial Peta Pasar & Lokal Coin.
- Panduan Pengguna UMKM (in-app + PDF): Tutorial manajemen produk, register account, dashboard, daftar rekening bank & pencairan dana.
- Panduan LOKAL AI Assistant (in-app): Cara menggunakan asisten AI untuk konsumen & UMKM.
- FAQ In-App & Pusat Bantuan Online.
- TBD: Video tutorial onboarding UMKM (v1.4.0).

### 2.7 Assumptions and Dependencies

- **Asumsi:** Pengguna memiliki smartphone kompatibel, internet aktif, dan alamat email aktif; UMKM bersedia mengunggah NIB/SIUP dan data rekening bank valid.
- **Dependensi eksternal:** Midtrans (pembayaran + webhook), Google Maps Platform (peta), Google Gemini API (AI Assistant), Docker Hub, GitHub Actions (CI/CD), SMTP Server untuk pengiriman kredensial & verifikasi email.

---

## 3. External Interface Requirements

### 3.1 User Interfaces

- **Navigasi:** Bottom navigation bar 5 tab (Beranda, Peta Pasar, Keranjang, Dompet, Profil).
- **Peta Interaktif:** Google Maps SDK; marker UMKM dengan info window; filter radius 0.5-10 km.
- **Layar Register Account:** Tombol 'Register Account' yang memicu proses backend. Form pengisian: Nama Lengkap, Email, Nomor HP, Password, Pilihan Peran (Konsumen / UMKM), Persetujuan S&K. Untuk UMKM, terdapat langkah kedua: data usaha & upload dokumen legalitas.
- **Layar Login:** Form email + password dengan tombol 'Lupa Password' (reset via email).
- **Layar Tracking Pesanan:** Timeline vertikal menampilkan riwayat status dari `order_histories` (Pending → Processing → Shipped/In Delivery → Completed/Cancelled), dilengkapi nomor resi jika sudah dikirim.
- **Layar AI Chat:** Antarmuka chat bubble dengan LOKAL AI Assistant; input teks pesan, tampilkan respons ramah Bahasa Indonesia.
- **Layar Pendaftaran Bank UMKM:** Form input nama bank, nomor rekening, nama pemilik rekening; status verifikasi ditampilkan (pending/approved/rejected).
- **Layar Dompet (Wallet):** Menampilkan saldo tunai, saldo koin, riwayat transaksi; tombol "Tarik Dana" disabled jika bank belum verifikasi.
- **Checkout Flow:** 3 langkah - Keranjang > Konfirmasi & Pembayaran > Status Pesanan.
- **Dashboard UMKM:** Line chart & bar chart penjualan, kartu ringkasan metrik.
- **Responsivitas & Aksesibilitas:** Mendukung 360-480dp (portrait) & tablet 600dp+; WCAG 2.1 level AA.

### 3.2 Hardware Interfaces

- **GPS/Lokasi:** Akurasi min. 50 meter; izin lokasi saat aplikasi digunakan.
- **Kamera & Penyimpanan:** Untuk unggah foto produk UMKM (izin kamera & galeri).
- **Push Notification:** FCM (Android) & APNs (iOS).
- **Koneksi Internet:** Min. 3G/HSPA; mode offline terbatas (riwayat transaksi dari cache lokal).

### 3.3 Software Interfaces

- **Midtrans:** SNAP API + webhook SHA-512; format JSON/HTTPS; endpoint webhook `POST /api/payment/notification`.
- **Google Gemini API:** REST API `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`; API Key dari `.env`; timeout 30 detik.
- **SMTP Server:** Pengiriman email kredensial akun baru, verifikasi, dan reset password (Laravel Mail + queue).
- **Google Maps Platform:** Maps SDK + Geocoding API + Distance Matrix API.
- **ML Service (internal):** FastAPI Python 3.11 + scikit-learn; endpoint `http://ml-service:8000/api/price-recommendation` (asinkron).
- **n8n:** Self-hosted workflow automation; trigger HTTP webhook dari Laravel.
- **MinIO:** Object storage S3-compatible untuk foto produk & dokumen legalitas UMKM.

### 3.4 Communications Interfaces

- **Protokol:** HTTPS/TLS 1.2 min. (TLS 1.3 direkomendasikan); REST API format JSON.
- **Base URL API:** `https://api.lokal.id/v1`; autentikasi Bearer Token JWT RS256.
- **Rate Limiting:** Register Account 5 req/menit per IP; login 10 req/menit per IP; reset password 3 req/menit per IP; endpoint umum 100 req/menit per token; `/api/ai/chat` 20 req/menit per token.
- **Push Notification:** FCM/APNs; tidak menggunakan WebSocket pada versi MVP.

---

## 4. System Features

Platform LOKAL memiliki 12 fitur sistem utama:

| **Kode** | **Fitur** | **Deskripsi Singkat** | **Prioritas** |
| --- | --- | --- | --- |
| F-01 | Autentikasi & Pengguna | Register Account (backend-driven), login Email+Password, JWT, verifikasi UMKM | Tinggi |
| F-02 | Peta Pasar & Produk | Peta interaktif UMKM radius 0.5-10 km, CRUD katalog produk | Tinggi |
| F-03 | Transaksi & Pembayaran | Keranjang multi-UMKM, checkout Midtrans (GoPay/OVO/DANA/VA/QRIS) | Tinggi |
| F-04 | Lokal Coin & Insentif | Reward 2%/transaksi, diskon maks. 20%, kadaluwarsa 6 bulan | Sedang |
| F-05 | Rekomendasi Harga ML | Analisis harga produk serupa radius 5 km secara asinkron | Sedang |
| F-06 | Dashboard Analitik UMKM | Grafik penjualan, produk terlaris, pendapatan bersih, real-time | Tinggi |
| F-07 | Notifikasi & Otomasi | Push notification via n8n untuk event transaksi | Tinggi |
| **F-08** | **Sistem Pelacakan Pesanan (Order Tracking)** | **UMKM input nomor resi saat 'shipped'; konsumen lihat timeline real-time** | **Tinggi** |
| **F-09** | **Otomatisasi Pembayaran & Webhook Midtrans** | **Konfirmasi pembayaran otomatis via webhook, distribusi dana & komisi** | **Tinggi** |
| **F-10** | **LOKAL AI Assistant** | **Chatbot berbasis Google Gemini API untuk bantuan UMKM & Konsumen** | **Sedang** |
| **F-11** | **Manajemen Verifikasi Bank & Withdrawal** | **UMKM daftar rekening, diverifikasi Admin, pencairan saldo tunai** | **Tinggi** |
| **F-12** | **Aturan Refund & Pembatalan Otomatis** | **Pengembalian koin konsumen & pembatalan komisi saat order dibatalkan** | **Sedang** |

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

Mengelola seluruh alur transaksi dari pemilihan produk hingga konfirmasi pembayaran.

**Prioritas: TINGGI.**

#### 4.3.2 Functional Requirements

- **REQ-F03-01:** Keranjang belanja multi-UMKM; validasi stok saat checkout.
- **REQ-F03-02:** Pembayaran via GoPay, OVO, DANA, VA Bank, QRIS melalui Midtrans.
- **REQ-F03-03:** Link/QR pembayaran kadaluwarsa 30 menit; webhook Midtrans divalidasi SHA-512.
- **REQ-F03-04:** Riwayat transaksi lengkap dengan filter tanggal & status; mendukung alur refund.
- **REQ-F03-05:** **Konfirmasi pembayaran dilakukan secara OTOMATIS melalui Webhook Midtrans (`POST /api/payment/notification`), bukan manual oleh Admin.**

### 4.4 F-04: Lokal Coin & Insentif

- **REQ-F04-01:** Kredit otomatis 2% nilai transaksi sebagai cashback saat pembayaran sukses; 5 koin per ulasan valid.
- **REQ-F04-02:** Maks. 20% nilai transaksi dapat dibayar dengan Lokal Coin; tidak bisa dikonversi ke fiat.
- **REQ-F04-03:** Koin hangus otomatis setelah 6 bulan; notifikasi 30 hari sebelum kadaluwarsa.
- **REQ-F04-04:** Setiap transaksi koin tercatat di riwayat dompet.
- **REQ-F04-05:** **Refund koin otomatis saat pesanan dibatalkan — koin konsumen yang terpotong dikembalikan penuh ke saldo mereka.**

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

### 4.8 F-08: Sistem Pelacakan Pesanan (Order Tracking)

#### 4.8.1 Description and Priority

Fitur ini memungkinkan Konsumen melacak status pesanan secara real-time melalui timeline yang ditarik dari tabel `order_histories`. UMKM (Penjual) wajib menginput `tracking_number` (nomor resi) saat mengubah status pesanan menjadi 'shipped'. Timeline menampilkan urutan status: Pending → Processing → Shipped/In Delivery → Completed/Cancelled.

**Prioritas: TINGGI.**

#### 4.8.2 Use Case

| **Use Case** | **Aktor** | **Deskripsi** |
| --- | --- | --- |
| UC-F08-01 | UMKM | UMKM mengubah status pesanan menjadi 'shipped' dan **wajib mengisi nomor resi pengiriman** (`tracking_number`). Jika nomor resi tidak diisi, sistem menolak perubahan status. |
| UC-F08-02 | Konsumen | Konsumen melihat halaman tracking yang menampilkan timeline status pesanan dari awal hingga akhir. |
| UC-F08-03 | Sistem | Sistem mencatat setiap perubahan status ke tabel `order_histories` dengan timestamp otomatis. |
| UC-F08-04 | Konsumen | Konsumen melihat `tracking_number` (nomor resi) yang diinput UMKM di halaman tracking. |

#### 4.8.3 Alur Data (Data Flow Singkat)

```
UMKM → PATCH /api/umkm/orders/{id}/status (status=shipped, tracking_number=ABC123)
  ↓
Backend validasi: jika status 'shipped', tracking_number WAJIB diisi
  ↓
Simpan tracking_number ke tabel orders, insert record ke order_histories
  ↓
Kirim notifikasi push ke konsumen: "Pesanan telah dikirim dengan nomor resi: ABC123"
  ↓

Konsumen → GET /api/orders/{id}/tracking
  ↓
Backend ambil semua order_histories untuk order_id terkait (urut DESC)
Response: order_id, order_number, status_saat_ini, tracking_number, histoires[]
  ↓
Flutter render timeline vertikal (ListView dengan time-bubbles)
```

#### 4.8.4 Business Rules

| **Kode** | **Aturan Bisnis** |
| --- | --- |
| BR-F08-01 | UMKM **WAJIB** mengisi `tracking_number` saat mengubah status pesanan menjadi 'shipped'. Jika tidak diisi, sistem mengembalikan error validasi. |
| BR-F08-02 | Setiap perubahan status pesanan oleh sistem atau pengguna wajib dicatat sebagai baris baru di tabel `order_histories`. |
| BR-F08-03 | Timeline tracking konsumen diurutkan secara descending (terbaru di atas) dari tabel `order_histories`. |
| BR-F08-04 | Konsumen hanya dapat melihat tracking untuk pesanan miliknya sendiri (authorization by user_id). |
| BR-F08-05 | Nomor resi (`tracking_number`) dapat diedit oleh UMKM hanya saat status masih 'shipped'. |

#### 4.8.5 Functional Requirements

| **Kode** | **Kebutuhan** | **Keterangan** |
| --- | --- | --- |
| REQ-F08-01 | Endpoint `PATCH /api/umkm/orders/{id}/status` mewajibkan `tracking_number` jika `status = shipped` | Validasi `required_if:status,shipped` di Laravel Request |
| REQ-F08-02 | Endpoint `GET /api/orders/{id}/tracking` mengembalikan data pesanan dan riwayat status | Response: order_id, order_number, status_saat_ini, tracking_number, histories[] |
| REQ-F08-03 | Setiap perubahan status dicatat di tabel `order_histories` dengan kolom: id, order_id, status, notes, created_at | Insert oleh sistem secara otomatis |
| REQ-F08-04 | Konsumen mendapat notifikasi push saat status berubah menjadi 'shipped' beserta nomor resi | Notifikasi via Firebase Cloud Messaging |
| REQ-F08-05 | Flutter menampilkan timeline vertikal dengan ikon status, label, timestamp, dan nomor resi | UI menggunakan ListView dengan custom timeline widget |

---

### 4.9 F-09: Otomatisasi Pembayaran & Webhook Midtrans

#### 4.9.1 Description and Priority

Mengganti alur konfirmasi pembayaran dari manual (oleh Admin) menjadi **OTOMATIS** menggunakan Webhook / Notification URL dari Midtrans. Laravel menyediakan endpoint publik `POST /api/payment/notification` yang dipanggil Midtrans saat ada perubahan status transaksi. Saat status 'settlement' diterima, sistem akan: (1) mengubah status pembayaran menjadi 'paid'; (2) memotong komisi platform 5% ke akun Admin; (3) mengalokasikan 95% ke saldo tunai UMKM; (4) memberikan cashback Lokal Coin 2% ke Konsumen secara otomatis.

**Prioritas: TINGGI.**

#### 4.9.2 Use Case

| **Use Case** | **Aktor** | **Deskripsi** |
| --- | --- | --- |
| UC-F09-01 | Midtrans (Eksternal) | Midtrans mengirim notifikasi HTTP POST ke endpoint webhook dengan data transaksi (`order_id`, `transaction_status`, `signature_key`, dll.) |
| UC-F09-02 | Sistem | Backend memvalidasi signature SHA-512 dari notifikasi Midtrans |
| UC-F09-03 | Sistem | Jika `transaction_status = settlement`, sistem: (a) update payment.status = 'paid'; (b) update order.status = 'processing'; (c) distribusikan dana |
| UC-F09-04 | Sistem | Sistem memotong komisi platform sebesar 5% dari subtotal ke saldo komisi Admin |
| UC-F09-05 | Sistem | Sistem mengalokasikan 95% dari subtotal + ongkos kirim ke saldo tunai (`cash_balance`) UMKM |
| UC-F09-06 | Sistem | Sistem memberikan cashback Lokal Coin sebesar 2% dari total pembayaran ke dompet Konsumen |
| UC-F09-07 | Sistem | Jika status transaksi adalah 'cancel', 'deny', atau 'expire', sistem membatalkan pesanan (status = 'cancelled') |

#### 4.9.3 Alur Data (Data Flow Singkat)

```
Midtrans → POST /api/payment/notification (order_id, transaction_status, gross_amount, signature_key)
  ↓
Backend validasi signature: hash('sha512', order_id + status_code + gross_amount + serverKey)
  ↓
Cari order berdasarkan order_number (dikirim sebagai order_id dari Midtrans)
  ↓
Jika status = 'settlement':
  ├── 1. Update payment: status = 'paid', transaction_id, paid_at, raw_response
  ├── 2. Hitung komisi 5% dari subtotal → tambah ke admin_wallet.commission_balance
  ├── 3. Hitung hak UMKM: (subtotal - komisi) + ongkir → tambah ke umkm_wallet.cash_balance
  ├── 4. Beri cashback 2% ke konsumen dalam Lokal Coin
  ├── 5. Catat riwayat di wallet_histories (credit/debit)
  ├── 6. Update order.status = 'processing'
  ├── 7. Insert ke order_histories: status='processing', notes='Pembayaran berhasil'
  ├── 8. Kirim notifikasi push ke konsumen & UMKM
  └── 9. Return 200 OK ke Midtrans
Jika status = 'cancel'/'deny'/'expire':
  ├── Update payment.status = transaction_status
  ├── Update order.status = 'cancelled'
  └── Kirim notifikasi gagal ke konsumen
Jika status = 'capture' + fraud = 'challenge':
  ├── Update payment.status = 'challenge'
  └── Kirim notifikasi menunggu verifikasi
```

#### 4.9.4 Business Rules

| **Kode** | **Aturan Bisnis** |
| --- | --- |
| BR-F09-01 | Webhook Midtrans wajib memvalidasi signature SHA-512 untuk autentisitas; jika tidak valid, kembalikan HTTP 403. |
| BR-F09-02 | Webhook harus **idempoten**: jika order sudah berstatus 'processing'/'delivered'/'cancelled', webhook di-skip (return 200 tanpa proses ulang). |
| BR-F09-03 | Komisi platform 5% dihitung dari subtotal order (tidak termasuk ongkos kirim). |
| BR-F09-04 | Saldo tunai UMKM = (subtotal - komisi 5%) + ongkos kirim + penyesuaian diskon koin (jika ada). |
| BR-F09-05 | Cashback Lokal Coin 2% dihitung dari total pembayaran (`cash_paid`), diberikan dalam bentuk koin (1 koin = Rp 10). |
| BR-F09-06 | Semua distribusi dana dilakukan dalam 1 database transaction untuk menjamin atomicity. |
| BR-F09-07 | Jika saldo komisi Admin tidak mencukupi untuk menutup cashback atau diskon koin, transaksi di-rollback dengan error. |
| BR-F09-08 | Setiap mutasi wallet (debit/kredit) wajib dicatat di tabel `wallet_histories` dengan tipe transaksi yang jelas. |

#### 4.9.5 Functional Requirements

| **Kode** | **Kebutuhan** | **Keterangan** |
| --- | --- | --- |
| REQ-F09-01 | Endpoint publik `POST /api/payment/notification` menerima notifikasi dari Midtrans | Tidak memerlukan autentikasi Bearer; rate limiting longgar |
| REQ-F09-02 | Validasi signature SHA-512 dari parameter notifikasi | `hash('sha512', order_id + status_code + gross_amount + serverKey)` |
| REQ-F09-03 | Update payment record dengan status 'paid', transaction_id, paid_at, raw_response | Field raw_response menyimpan full JSON dari Midtrans |
| REQ-F09-04 | Update order status menjadi 'processing' setelah pembayaran settlement | Order siap diproses UMKM |
| REQ-F09-05 | Distribusi dana: potong komisi 5% untuk Admin, alokasikan 95% + ongkir ke UMKM | Implementasi di `OrderController::distributePaymentFunds()` |
| REQ-F09-06 | Cashback Lokal Coin 2% otomatis ke konsumen | Menggunakan `CoinService::add()` |
| REQ-F09-07 | Catat semua mutasi wallet di `wallet_histories` | Tipe: 'credit'/'debit', kategori: 'commission'/'cash'/'coin' |
| REQ-F09-08 | Kirim notifikasi push ke konsumen & UMKM terkait status pembayaran | Notifikasi via `NotificationService` |
| REQ-F09-09 | Tangani status transaksi 'cancel', 'deny', 'expire' — batalkan pesanan | Update order.status = 'cancelled' |
| REQ-F09-10 | Tangani status 'challenge' — set payment.status = 'challenge' | Notifikasi menunggu verifikasi |
| REQ-F09-11 | Idempotency: jika order sudah diproses, webhook di-skip | Cek status order sebelum proses |
| REQ-F09-12 | Endpoint simulasi `POST /api/orders/process-payment-webhook` untuk testing | Menerima `order_id`, memproses distribusi dana |

---

### 4.10 F-10: LOKAL AI Assistant

#### 4.10.1 Description and Priority

Fitur baru berupa "LOKAL AI Assistant" yang ditenagai oleh Google Gemini API (model `gemini-1.5-flash`). Konsumen dan UMKM dapat mengirimkan pertanyaan teks melalui Flutter ke endpoint `POST /api/ai/chat`. Backend akan meneruskan pesan ke Gemini API menggunakan API Key dari file `.env`, lalu mengembalikan respons teks ramah berbahasa Indonesia kasual untuk membimbing UMKM atau membantu Konsumen.

**Prioritas: SEDANG.**

#### 4.10.2 Use Case

| **Use Case** | **Aktor** | **Deskripsi** |
| --- | --- | --- |
| UC-F10-01 | Konsumen | Konsumen bertanya tentang rekomendasi produk lokal, cara menggunakan koin, atau informasi umum platform |
| UC-F10-02 | UMKM | UMKM bertanya tentang cara mengelola toko, strategi pemasaran, atau laporan penjualan |
| UC-F10-03 | Sistem | Sistem meneruskan prompt ke Gemini API dengan system instruction untuk menjaga konteks LOKAL |
| UC-F10-04 | Sistem | Sistem mengembalikan respons AI dalam Bahasa Indonesia kasual yang santun |

#### 4.10.3 Alur Data (Data Flow Singkat)

```
Flutter → POST /api/ai/chat (Authorization: Bearer JWT, body: { message: "..." })
  ↓
Backend validasi input (required|string|max:1000)
  ↓
Backend build payload Gemini API:
  ├── system_instruction: "Kamu adalah LOKAL AI Assistant..."
  ├── contents: [{ parts: [{ text: message }] }]
  ├── generationConfig: { temperature: 0.7, maxOutputTokens: 512 }
  ↓
Backend kirim ke: POST https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={GEMINI_API_KEY}
  ↓
Gemini API → Backend: { candidates: [{ content: { parts: [{ text: "..." }] } }] }
  ↓
Backend parse response, kirim ke Flutter: { success: true, response: "..." }
  ↓
Flutter tampilkan di chat bubble
```

#### 4.10.4 Business Rules

| **Kode** | **Aturan Bisnis** |
| --- | --- |
| BR-F10-01 | API Key Gemini hanya disimpan di file `.env` backend, **tidak boleh** diekspos ke Flutter atau client-side |
| BR-F10-02 | Input pesan maksimal 1000 karakter per request |
| BR-F10-03 | Timeout request ke Gemini API adalah 30 detik; jika timeout, kembalikan error graceful |
| BR-F10-04 | System instruction memastikan AI merespons dalam Bahasa Indonesia kasual dan tetap relevan dengan konteks UMKM & produk lokal |
| BR-F10-05 | Rate limiting endpoint `/api/ai/chat` adalah 20 request per menit per token pengguna |
| BR-F10-06 | Riwayat chat tidak disimpan di server (stateless); setiap request independen |

#### 4.10.5 Functional Requirements

| **Kode** | **Kebutuhan** | **Keterangan** |
| --- | --- | --- |
| REQ-F10-01 | Endpoint `POST /api/ai/chat` menerima input `message` dari Flutter | Auth: Bearer JWT; validasi max 1000 chars |
| REQ-F10-02 | Backend mengirim prompt ke Gemini API dengan system instruction konteks LOKAL | Menggunakan Http::timeout(30) Laravel |
| REQ-F10-03 | Gemini API Key dibaca dari `env('GEMINI_API_KEY')` | Tidak di-hardcode atau diekspos |
| REQ-F10-04 | Respons AI dikembalikan ke Flutter dalam format `{ success: true, response: "..." }` | Parsed dari `candidates[0].content.parts[0].text` |
| REQ-F10-05 | Error handling: jika Gemini gagal, kembalikan `"Asisten AI sedang sibuk, coba lagi nanti."` | HTTP 500, success: false |
| REQ-F10-06 | System instruction: ramah, Bahasa Indonesia kasual, fokus UMKM & produk lokal | Diset di payload `system_instruction` |

---

### 4.11 F-11: Manajemen Verifikasi Bank & Pencairan Saldo (Withdrawal)

#### 4.11.1 Description and Priority

UMKM harus mendaftarkan rekening bank dan diverifikasi terlebih dahulu oleh Admin di Dashboard sebelum bisa melakukan penarikan dana (withdrawal). Tombol penarikan di aplikasi Flutter akan dinonaktifkan (disabled) jika status verifikasi belum 'approved'. Fitur ini mencakup: pendaftaran bank oleh UMKM, verifikasi oleh Admin (approve/reject), dan pencairan saldo tunai (`cash_balance`) dari dompet UMKM ke rekening terdaftar.

**Prioritas: TINGGI.**

#### 4.11.2 Use Case

| **Use Case** | **Aktor** | **Deskripsi** |
| --- | --- | --- |
| UC-F11-01 | UMKM | UMKM mengisi data rekening bank (nama bank, nomor rekening, nama pemilik) melalui aplikasi |
| UC-F11-02 | Admin | Admin melihat daftar pengajuan bank UMKM di Dashboard; Admin dapat menyetujui (approve) atau menolak (reject) |
| UC-F11-03 | UMKM | UMKM melihat status verifikasi bank di halaman Dompet / Pengaturan Toko |
| UC-F11-04 | UMKM | UMKM mengajukan penarikan dana (withdrawal) dari saldo tunai ke rekening terverifikasi |
| UC-F11-05 | Sistem | Sistem menonaktifkan tombol 'Tarik Dana' jika status verifikasi bank belum 'approved' |

#### 4.11.3 Alur Data (Data Flow Singkat)

```
Pendaftaran Bank:
UMKM → POST /api/umkm/bank-account { bank_name, account_number, account_holder }
  ↓
Backend simpan ke tabel umkm_bank_accounts (status: 'pending')
  ↓

Verifikasi oleh Admin:
Admin → Buka Dashboard Bank Verification
  ↓
Lihat daftar bank UMKM dengan status 'pending'
  ↓
Admin klik 'Approve' atau 'Reject' + catatan (notes)
  ↓
Backend update status verifikasi di umkm_bank_accounts

Pencairan Dana (Withdrawal):
UMKM → Buka halaman Dompet → Lihat saldo tunai
  ↓
Cek status bank_account terakhir: jika 'approved' → tombol 'Tarik Dana' aktif
                               jika 'pending'/'rejected'/null → tombol disabled
  ↓
UMKM klik 'Tarik Dana' → input jumlah nominal
  ↓
Backend:
  ├── Validasi: bank_account.status = 'approved'
  ├── Validasi: cash_balance >= nominal
  ├── Kurangi cash_balance
  ├── Catat wallet_history (debit, 'withdrawal')
  ├── Insert ke tabel withdrawals (status: 'pending')
  └── Kirim notifikasi ke Admin untuk diproses manual
```

#### 4.11.4 Business Rules

| **Kode** | **Aturan Bisnis** |
| --- | --- |
| BR-F11-01 | Setiap UMKM hanya dapat memiliki **satu** rekening bank aktif dalam satu waktu |
| BR-F11-02 | Status verifikasi bank: `pending` (default saat daftar) → `approved` / `rejected` (oleh Admin) |
| BR-F11-03 | Tombol 'Tarik Dana' di Flutter wajib **disabled** jika `bank_account.status !== 'approved'` |
| BR-F11-04 | Admin dapat memberikan catatan (notes) saat menolak pengajuan bank |
| BR-F11-05 | Penarikan dana minimum: Rp 50.000; saldo tunai harus mencukupi |
| BR-F11-06 | Riwayat penarikan dana dicatat di `wallet_histories` dengan tipe 'debit' kategori 'withdrawal' |
| BR-F11-07 | Admin perlu memproses transfer manual ke rekening UMKM setelah notifikasi withdrawal masuk |

#### 4.11.5 Functional Requirements

| **Kode** | **Kebutuhan** | **Keterangan** |
| --- | --- | --- |
| REQ-F11-01 | Endpoint `GET /api/umkm/bank-account` — ambil data bank UMKM | Bearer+UMKM |
| REQ-F11-02 | Endpoint `POST /api/umkm/bank-account` — daftar rekening bank baru | Validasi: bank_name, account_number, account_holder |
| REQ-F11-03 | Endpoint `PUT /api/umkm/bank-account` — update rekening bank | Hanya jika status masih 'pending' atau 'rejected' |
| REQ-F11-04 | Admin Dashboard: halaman verifikasi bank dengan daftar UMKM | Fitur approve/reject dengan notes |
| REQ-F11-05 | Endpoint withdrawal: `POST /api/wallet/withdraw` — ajukan penarikan dana | Validasi status bank & saldo |
| REQ-F11-06 | Flutter: tombol 'Tarik Dana' disabled jika bank belum diverifikasi | Berdasarkan status dari API `/api/umkm/bank-account` |
| REQ-F11-07 | Tabel `umkm_bank_accounts`: id, umkm_id, bank_name, account_number, account_holder, status, verified_at, notes | Migration Laravel |
| REQ-F11-08 | Notifikasi push ke UMKM saat status verifikasi bank berubah | 'approved' atau 'rejected' |

---

### 4.12 F-12: Aturan Refund & Pembatalan Otomatis

#### 4.12.1 Description and Priority

Jika pesanan dibatalkan (cancelled), sistem harus mengembalikan koin konsumen yang terpotong ke saldo mereka, dan membatalkan alokasi komisi 5% milik platform dari transaksi tersebut. Aturan ini berlaku untuk pembatalan oleh konsumen (sebelum dibayar) maupun oleh UMKM.

**Prioritas: SEDANG.**

#### 4.12.2 Use Case

| **Use Case** | **Aktor** | **Deskripsi** |
| --- | --- | --- |
| UC-F12-01 | Konsumen | Konsumen membatalkan pesanan yang masih berstatus 'pending' atau 'awaiting_payment' |
| UC-F12-02 | UMKM | UMKM membatalkan pesanan yang sudah diproses |
| UC-F12-03 | Sistem | Sistem mengembalikan Lokal Coin konsumen yang terpotong ke saldo mereka |
| UC-F12-04 | Sistem | Sistem membatalkan alokasi komisi 5% platform (jika sudah dialokasikan) |
| UC-F12-05 | Sistem | Sistem mengembalikan stok produk yang sudah dikurangi |

#### 4.12.3 Alur Data (Data Flow Singkat)

```
Pembatalan oleh Konsumen (sebelum dibayar):
Konsumen → PATCH /api/orders/{id}/cancel
  ↓
Backend cek status: hanya 'pending' atau 'awaiting_payment' yang bisa dibatalkan oleh konsumen
  ↓
DB Transaction:
  ├── 1. Restore stok produk (increment stock per item)
  ├── 2. Jika coin_discount > 0:
  │     ├── Hitung koin yang direfund: (int)(coin_discount / COIN_TO_RUPIAH)
  │     └── Tambah koin kembali ke wallet konsumen via CoinService::add()
  ├── 3. Update order.status = 'cancelled'
  ├── 4. Insert ke order_histories: status='cancelled', notes='Pesanan dibatalkan oleh konsumen'
  └── 5. Kirim notifikasi ke konsumen

Pembatalan oleh UMKM (setelah diproses/dikirim):
UMKM → PATCH /api/umkm/orders/{id}/status (status=cancelled)
  ↓
Backend:
  ├── 1. Jika sudah ada distribusi dana (status = 'processing'):
  │     ├── Kurangi cash_balance UMKM (kembalikan dana yang sudah dialokasikan)
  │     ├── Jika coin/cashback sudah diberikan, catat reversal
  │     └── Kembalikan komisi yang sudah dipotong ke admin_wallet
  ├── 2. Restore stok produk
  ├── 3. Update order.status = 'cancelled'
  ├── 4. Insert order_history
  └── 5. Notifikasi konsumen
```

> **Catatan:** Untuk pembatalan setelah pembayaran sukses, alur refund penuh memerlukan mekanisme terpisah yang melibatkan pembatalan transaksi Midtrans dan pengembalian dana ke konsumen (out of scope v1.5.0, direncanakan untuk v1.6.0).

#### 4.12.4 Business Rules

| **Kode** | **Aturan Bisnis** |
| --- | --- |
| BR-F12-01 | Konsumen hanya dapat membatalkan pesanan dengan status 'pending' atau 'awaiting_payment' |
| BR-F12-02 | Saat pembatalan, **stok produk wajib dikembalikan** (increment stok sesuai kuantitas item) |
| BR-F12-03 | Jika konsumen menggunakan Lokal Coin untuk diskon, koin yang terpotong **wajib dikembalikan penuh** ke saldo konsumen |
| BR-F12-04 | Jika pesanan sudah dibayar (status 'processing'), pembatalan oleh UMKM harus mengembalikan dana yang sudah dialokasikan dari wallet UMKM dan Admin |
| BR-F12-05 | Setiap pembatalan wajib dicatat di tabel `order_histories` dengan notes yang jelas |
| BR-F12-06 | Cashback Lokal Coin yang sudah diberikan saat pembayaran tidak perlu ditarik kembali untuk pesanan yang dibatalkan sebelum diproses (belum sempat diberikan) |

#### 4.12.5 Functional Requirements

| **Kode** | **Kebutuhan** | **Keterangan** |
| --- | --- | --- |
| REQ-F12-01 | Endpoint `PATCH /api/orders/{id}/cancel` — pembatalan oleh konsumen | Hanya status 'pending'/'awaiting_payment' |
| REQ-F12-02 | Refund koin otomatis jika `coin_discount > 0` saat pembatalan | `CoinService::add()` untuk mengembalikan koin |
| REQ-F12-03 | Restore stok produk untuk setiap item order yang dibatalkan | `$product->increment('stock', $quantity)` |
| REQ-F12-04 | Catat pembatalan di `order_histories` dengan timestamp | Notes: 'Pesanan dibatalkan oleh konsumen' atau 'Pesanan dibatalkan oleh penjual' |
| REQ-F12-05 | Notifikasi push ke pengguna terkait saat pesanan dibatalkan | Notifikasi via `NotificationService` |
| REQ-F12-06 | Endpoint `PATCH /api/umkm/orders/{id}/status` dengan status 'cancelled' oleh UMKM | Validasi: UMKM pemilik produk dapat membatalkan |

---

## 5. Other Nonfunctional Requirements

| **Kategori** | **Persyaratan** | **Target** |
| --- | --- | --- |
| Performa | Waktu respons API endpoint kritikal | < 500ms |
| Performa | Waktu respons ML Service | < 3 detik |
| Performa | Waktu respons LOKAL AI Assistant (Gemini API) | < 10 detik (inklusi latency eksternal) |
| Skalabilitas | Pengguna konkuren fase pilot | 10.000 concurrent |
| Ketersediaan | Uptime sistem produksi | >= 99.5%/bulan |
| Keamanan | Enkripsi client-server | HTTPS/TLS 1.2+ |
| Keamanan | Hash password | bcrypt cost 12 |
| Keamanan | Enkripsi data sensitif di DB | AES-256 |
| Keamanan | API Key Gemini tersimpan aman di .env | Tidak diekspos ke client |
| Privasi | Lokasi penyimpanan data | Server Indonesia (UU PDP) |
| Portabilitas | Platform mobile | Android API 24+ & iOS 14+ |
| Pemeliharaan | Deployment & rollback | Zero-downtime (Docker+Watchtower) |
| Kegunaan | Waktu onboarding pengguna baru | <= 5 menit |

### 5.1 Performance Requirements

- **NF-PERF-01:** API kritikal (autentikasi, peta, checkout) maks. 500ms pada 1.000 concurrent request.
- **NF-PERF-02:** ML Service maks. 3 detik; graceful degradation jika melebihi batas.
- **NF-PERF-03:** Render peta 100+ marker UMKM < 2 detik di perangkat kelas menengah.
- **NF-PERF-04:** Query geospasial produk < 200ms menggunakan indeks SPATIAL MySQL.
- **NF-PERF-05:** **Endpoint tracking pesanan maks. 300ms; endpoint AI chat maks. 10 detik (termasuk latency Gemini API).**

### 5.2 Safety Requirements

- **NF-SAFE-01:** Rollback otomatis jika pembayaran gagal; stok tidak dikurangi saat order pending.
- **NF-SAFE-02:** Audit log immutable untuk seluruh transaksi keuangan dan perubahan status order.
- **NF-SAFE-03:** Idempotency untuk webhook Midtrans guna mencegah double processing.
- **NF-SAFE-04:** **Database transaction untuk semua distribusi dana; atomicity terjamin.**

### 5.3 Security Requirements

- **NF-SEC-01:** HTTPS/TLS 1.2+ untuk semua komunikasi client-server.
- **NF-SEC-02:** JWT RS256; disimpan di Android Keystore / iOS Keychain.
- **NF-SEC-03:** Rate limiting: Register Account 5/menit per IP, login 10/menit per IP, reset password 3/menit per IP, AI chat 20/menit per token.
- **NF-SEC-04:** Password di-hash dengan bcrypt cost factor 12; tidak pernah disimpan plaintext.
- **NF-SEC-05:** Tautan reset password di-hash SHA-256 dan berlaku satu kali (invalidasi setelah digunakan).
- **NF-SEC-06:** Data sensitif (email, nomor HP, alamat) dienkripsi AES-256 di database.
- **NF-SEC-07:** Mematuhi UU PDP; data pengguna tersimpan di server Indonesia; proteksi OWASP Top 10.
- **NF-SEC-08:** **Webhook Midtrans divalidasi dengan signature SHA-512; endpoint publik hanya menerima POST.**

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
- **BR-06:** **UMKM WAJIB mengisi nomor resi (tracking_number) saat mengubah status pesanan menjadi 'shipped'.**
- **BR-07:** **Konfirmasi pembayaran dilakukan OTOMATIS via Webhook Midtrans, bukan manual oleh Admin.**
- **BR-08:** **Komisi platform 5% dipotong dari subtotal order; 95% + ongkir dialokasikan ke saldo tunai UMKM.**
- **BR-09:** **Cashback Lokal Coin 2% diberikan otomatis ke konsumen saat pembayaran settlement.**
- **BR-10:** **UMKM wajib verifikasi rekening bank (status 'approved') sebelum dapat melakukan penarikan dana.**
- **BR-11:** **Tombol withdrawal di Flutter disabled jika status verifikasi bank UMKM belum 'approved'.**
- **BR-12:** **Saat pesanan dibatalkan, koin konsumen yang terpotong wajib dikembalikan ke saldo mereka.**
- **BR-13:** **Stok produk wajib di-restore saat pesanan dibatalkan.**
- **BR-14:** **API Key Gemini hanya boleh disimpan di file .env backend; tidak boleh diekspos ke client.**

---

## 6. Other Requirements

- **Database:** MySQL 8.0; tipe POINT untuk koordinat UMKM; JSON untuk atribut produk variabel; backup otomatis pukul 02.00 WIB, retensi 30 hari.
- **Tabel baru:** `order_histories` (riwayat status order), `umkm_bank_accounts` (data rekening bank UMKM), `wallet_histories` (riwayat mutasi wallet), `withdrawals` (riwayat penarikan dana).
- **Internationalization:** MVP dalam Bahasa Indonesia; multi-bahasa (Inggris, Sunda) direncanakan v2.0; mata uang IDR.
- **Legal:** Mematuhi UU PDP No. 27/2022; regulasi OJK/BI; Syarat & Ketentuan + Kebijakan Privasi disetujui saat Register Account; data tidak digunakan untuk iklan pihak ketiga tanpa persetujuan.
- **Reuse:** Modul autentikasi JWT & koin sebagai reusable Laravel package; ML model dapat dilatih ulang per wilayah; n8n workflow templates dapat diimpor; LOKAL AI Assistant dapat dikembangkan menjadi multi-model.
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
| Webhook | HTTP callback yang dikirim Midtrans ke endpoint server LOKAL saat terjadi perubahan status transaksi pembayaran. |
| Settlement | Status transaksi Midtrans yang menandakan dana sudah berhasil masuk ke merchant (platform). |
| Komisi Platform | Potongan 5% dari subtotal order sebagai biaya layanan platform LOKAL. |
| Cashback Lokal Coin | Reward 2% dari total pembayaran yang diberikan dalam bentuk Lokal Coin ke konsumen. |
| Order Histories | Tabel database yang mencatat setiap perubahan status pesanan beserta timestamp untuk keperluan tracking. |
| Tracking Number | Nomor resi pengiriman yang diinput UMKM saat mengubah status pesanan menjadi 'shipped'. |
| LOKAL AI Assistant | Chatbot berbasis Google Gemini API (model gemini-1.5-flash) yang membantu pengguna dalam Bahasa Indonesia kasual. |
| Gemini API | REST API dari Google untuk mengakses model AI generatif (gemini-1.5-flash). |
| Bank Verification | Proses verifikasi rekening bank UMKM oleh Admin sebelum UMKM dapat melakukan pencairan dana. |
| Withdrawal | Penarikan saldo tunai dari dompet UMKM ke rekening bank terverifikasi. |
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
| PATCH | /orders/{id}/cancel | Batalkan pesanan oleh konsumen | Bearer |
| PATCH | /orders/{id}/confirm-received | Konfirmasi pesanan diterima | Bearer |
| **GET** | **/orders/{id}/tracking** | **Ambil timeline tracking pesanan (order_histories)** | **Bearer** |
| POST | /payment/create | Buat transaksi Midtrans Snap | Bearer |
| GET | /payment/status/{orderId} | Status pembayaran | Bearer |
| **POST** | **/payment/notification** | **Webhook Midtrans (public)** | **Publik** |
| **POST** | **/orders/process-payment-webhook** | **Simulasi webhook sukses (testing)** | **Publik** |
| POST | /orders/{id}/review | Berikan ulasan produk | Bearer |
| GET | /wallet/balance | Saldo & ringkasan Lokal Coin | Bearer |
| GET | /wallet/history | Riwayat transaksi Lokal Coin | Bearer |
| **POST** | **/wallet/withdraw** | **Ajukan penarikan dana tunai** | **Bearer+UMKM** |
| **POST** | **/ai/chat** | **Chat dengan LOKAL AI Assistant** | **Bearer** |
| GET | /umkm/analytics/summary | Ringkasan performa penjualan | Bearer+UMKM |
| GET/PATCH | /notifications | Daftar / tandai baca notifikasi | Bearer |

**Endpoint UMKM Role:**

| **Method** | **Endpoint** | **Deskripsi** | **Auth** |
| --- | --- | --- | --- |
| GET | /umkm/my-store | Ambil data toko UMKM | Bearer+UMKM |
| PUT | /umkm/my-store | Update data toko | Bearer+UMKM |
| GET | /umkm/products | Daftar produk milik UMKM | Bearer+UMKM |
| POST | /umkm/products | Tambah produk baru | Bearer+UMKM |
| PUT/DELETE | /umkm/products/{id} | Update / hapus produk | Bearer+UMKM |
| GET | /umkm/orders | Daftar pesanan masuk untuk UMKM | Bearer+UMKM |
| **PATCH** | **/umkm/orders/{id}/status** | **Update status pesanan (processing/shipped/cancelled) + tracking_number** | **Bearer+UMKM** |
| GET | /umkm/analytics/summary | Ringkasan performa penjualan | Bearer+UMKM |
| **GET** | **/umkm/bank-account** | **Ambil data rekening bank UMKM** | **Bearer+UMKM** |
| **POST** | **/umkm/bank-account** | **Daftar rekening bank baru** | **Bearer+UMKM** |
| **PUT** | **/umkm/bank-account** | **Update rekening bank** | **Bearer+UMKM** |

### B.2 Arsitektur Komponen

- **Client Layer:** Flutter 3.19 (Android API 24+ & iOS 14+) - modul Auth (Register Account), Market Map, Checkout, Wallet, Dashboard, Order Tracking, AI Chat, Bank Account.
- **API Gateway Layer:** Nginx 1.25 - reverse proxy, SSL termination, rate limiting.
- **Backend Layer:** Laravel 11 API + n8n Workflow Engine + ML Service (Python/FastAPI) + **LOKAL AI Assistant (Gemini API Integration)**.
- **Data Layer:** MySQL 8.0 + Redis 7.2 + MinIO Object Storage.
- **External Services:** Midtrans, Google Maps Platform, **Google Gemini API**, SMTP Server.

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

### B.5 Alur Pembayaran Otomatis via Webhook Midtrans

| **Langkah** | **Aktor** | **Aksi** | **Endpoint/Catatan** |
| --- | --- | --- | --- |
| 1 | Konsumen | Selesaikan pembayaran di Midtrans Snap (GoPay/OVO/DANA/VA/QRIS) | Midtrans Snap UI |
| 2 | Midtrans | Kirim notifikasi HTTP POST ke endpoint webhook LOKAL | POST /api/payment/notification |
| 3 | Backend | Validasi signature SHA-512 notifikasi | hash('sha512', order_id + status_code + gross_amount + serverKey) |
| 4 | Backend | Cari order berdasarkan order_number | Order::where('order_number', request.order_id) |
| 5 | Backend | Jika status = 'settlement': update payment, distribusikan dana, update order, kirim notifikasi | Database transaction |
| 6 | Backend | Jika status = 'cancel'/'deny'/'expire': update payment, batalkan order, notifikasi konsumen | - |
| 7 | Backend | Return HTTP 200 OK ke Midtrans (konfirmasi penerimaan) | - |

### B.6 Alur Chat LOKAL AI Assistant

| **Langkah** | **Aktor** | **Aksi** | **Endpoint/Catatan** |
| --- | --- | --- | --- |
| 1 | Pengguna | Buka layar AI Chat, ketik pesan, tekan kirim | Flutter UI |
| 2 | Flutter | Kirim POST request ke backend | POST /api/ai/chat (Bearer JWT) |
| 3 | Backend | Validasi input, ambil GEMINI_API_KEY dari .env | max 1000 karakter |
| 4 | Backend | Kirim prompt ke Gemini API dengan system instruction | https://generativelanguage.googleapis.com/... |
| 5 | Gemini | Proses prompt, kembalikan respons teks | - |
| 6 | Backend | Parse respons, kirim ke Flutter | { success: true, response: "..." } |
| 7 | Flutter | Tampilkan respons di chat bubble | UI ListView dengan bubble |

### B.7 Alur Verifikasi Bank & Withdrawal

| **Langkah** | **Aktor** | **Aksi** | **Endpoint/Catatan** |
| --- | --- | --- | --- |
| 1 | UMKM | Input data rekening bank (bank_name, account_number, account_holder) | POST /api/umkm/bank-account |
| 2 | Backend | Simpan data dengan status 'pending' | Tabel umkm_bank_accounts |
| 3 | Admin | Buka Dashboard Bank Verification | Admin Web Panel |
| 4 | Admin | Setujui (approve) atau tolak (reject) pengajuan bank | Backend update status |
| 5 | UMKM | Cek status verifikasi di halaman Dompet | GET /api/umkm/bank-account |
| 6 | Flutter | Jika status = 'approved', tombol 'Tarik Dana' aktif; jika tidak, disabled | UI conditional |
| 7 | UMKM | Klik 'Tarik Dana', input nominal, submit | POST /api/wallet/withdraw |
| 8 | Backend | Validasi saldo, kurangi cash_balance, catat riwayat, notifikasi Admin | - |

---

## Appendix C: To Be Determined List

| **No.** | **Item TBD** | **Target Resolusi** | **Status** |
| --- | --- | --- | --- |
| TBD-01 | Integrasi API logistik pihak ketiga (JNE, SiCepat, AnterAja) | Sprint 3 - Mei 2026 | **RESOLVED** — Digantikan oleh sistem nomor resi manual dari UMKM (F-08) |
| TBD-02 | Video tutorial onboarding UMKM | v1.4.0 - Q3 2026 | Belum |
| TBD-03 | Dukungan multi-bahasa (Inggris, Sunda) | v2.0.0 - 2026 | Belum |
| TBD-04 | Threshold stok menipis: global atau per-produk? | Sprint 2 - April 2026 | **RESOLVED** — Per-produk |
| TBD-05 | Algoritma ML spesifik (Linear Regression, Random Forest, dll.) | Sprint 4 - Mei 2026 | Belum |
| TBD-06 | Spesifikasi teknis panel admin verifikasi UMKM | Dokumen terpisah - Q2 2026 | **RESOLVED** — Implementasi di Admin Dashboard |
| TBD-07 | Mekanisme penyelesaian sengketa konsumen-UMKM | v1.5.0 - Q4 2026 | Belum |
| TBD-08 | Target concurrent users fase produksi penuh | Setelah evaluasi pilot | Belum |
| TBD-09 | Pemilihan SMTP provider (self-hosted Postfix, Mailgun, atau SendGrid) | Sprint 1 - Juli 2026 | Belum |
| TBD-10 | Desain UI detail layar Register Account (wireframe tahap 2 untuk UMKM) | Sprint 2 - Juli 2026 | **RESOLVED** — Implementasi selesai |
| TBD-11 | **Mekanisme refund penuh untuk pembatalan setelah pembayaran** | v1.6.0 - 2026 | Baru |
| TBD-12 | **Integrasi tracking real-time dengan kurir/logistik eksternal** | v2.0.0 - 2026 | Baru |

---

## Appendix D: Kesesuaian dengan Panduan Tugas Besar Kelas A2

| **Persyaratan Panduan** | **Status** | **Keterangan** |
| --- | --- | --- |
| Tema: Ketahanan Ekonomi / Digitalisasi Jasa Lokal | SESUAI | Platform LOKAL fokus pada sirkulasi ekonomi lokal & digitalisasi UMKM |
| Deskripsi Proyek & Latar Belakang Masalah | SESUAI | Tercakup di Bab 1.4 Product Scope |
| Business Process / Alur Kerja Sistem | SESUAI | Tercakup di Appendix B.3, B.4, B.5, B.6, B.7 (alur Register Account, Reset Password, Pembayaran Otomatis, AI Chat, Verifikasi Bank) |
| Kebutuhan Fungsional | SESUAI | Tercakup di Bab 4 (F-01 s/d F-12) |
| Class Diagram (UML Lanjut) | PERLU DITAMBAHKAN | Belum ada di SRS; wajib ditambahkan sebagai lampiran di GitHub |
| Sequence Diagram | PERLU DITAMBAHKAN | Activity Diagram ada (Appendix B.4, B.5, B.6, B.7) namun Sequence Diagram spesifik belum ada |
| Component Diagram | SEBAGIAN | Arsitektur komponen ada di B.2; perlu digambarkan dalam format diagram UML formal |
| Deployment Diagram (Docker topology) | SEBAGIAN | Disebutkan di B.2; perlu diagram visual topologi container Docker |
| Desain Kontrak API (REST endpoint list) | SESUAI | Tercakup lengkap di Appendix B.1 |
| Versi Dokumen & Catatan Perubahan | SESUAI | Revision History ada; versi 1.5.0 sudah diperbarui |
| Backend Laravel (RESTful API, bukan Blade) | SESUAI | Tercantum di Bab 2.1 & 2.4 |
| Frontend Flutter (mobile) | SESUAI | Flutter 3.19 digunakan sebagai client layer |
| Docker (Dockerfile & Docker Compose) | SESUAI | Tercantum di Bab 2.4 & 2.5 sebagai constraint wajib |
| Integrasi teknologi tambahan | SESUAI | Midtrans, Google Maps, Google Gemini API, n8n, ML Service (FastAPI), SMTP |
| Penelitian lapangan & notulensi | PERLU DILENGKAPI | Tidak termasuk dalam SRS; perlu dibuat sebagai dokumen terpisah di folder GitHub |
| Upload ke GitHub (clone/push/pull/merge) | DI LUAR CAKUPAN SRS | Harus dipastikan tim menggunakan Git commands (bukan upload langsung) |