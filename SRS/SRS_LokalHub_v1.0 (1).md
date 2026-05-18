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

## Table of Contents

[Revision History](#revision-history)

1. [Introduction](#1-introduction)
   - 1.1 [Purpose](#11-purpose)
   - 1.2 [Document Conventions](#12-document-conventions)
   - 1.3 [Intended Audience and Reading Suggestions](#13-intended-audience-and-reading-suggestions)
   - 1.4 [Product Scope](#14-product-scope)
   - 1.5 [References](#15-references)
2. [Overall Description](#2-overall-description)
   - 2.1 [Product Perspective](#21-product-perspective)
   - 2.2 [Product Functions](#22-product-functions)
   - 2.3 [User Classes and Characteristics](#23-user-classes-and-characteristics)
   - 2.4 [Operating Environment](#24-operating-environment)
   - 2.5 [Design and Implementation Constraints](#25-design-and-implementation-constraints)
   - 2.6 [User Documentation](#26-user-documentation)
   - 2.7 [Assumptions and Dependencies](#27-assumptions-and-dependencies)
3. [External Interface Requirements](#3-external-interface-requirements)
   - 3.1 [User Interfaces](#31-user-interfaces)
   - 3.2 [Hardware Interfaces](#32-hardware-interfaces)
   - 3.3 [Software Interfaces](#33-software-interfaces)
   - 3.4 [Communications Interfaces](#34-communications-interfaces)
4. [System Features](#4-system-features)
   - 4.1 [Authentication & Authorization](#41-authentication--authorization)
   - 4.2 [Provider Management](#42-provider-management)
   - 4.3 [Service Catalog & Search](#43-service-catalog--search)
   - 4.4 [Order Lifecycle](#44-order-lifecycle)
   - 4.5 [Payment (DP & Final) via QRIS](#45-payment-dp--final-via-qris)
   - 4.6 [Notifications](#46-notifications)
   - 4.7 [Rating & Review](#47-rating--review)
   - 4.8 [Treasurer Monitoring](#48-treasurer-monitoring)
5. [Other Nonfunctional Requirements](#5-other-nonfunctional-requirements)
   - 5.1 [Performance Requirements](#51-performance-requirements)
   - 5.2 [Safety Requirements](#52-safety-requirements)
   - 5.3 [Security Requirements](#53-security-requirements)
   - 5.4 [Software Quality Attributes](#54-software-quality-attributes)
   - 5.5 [Business Rules](#55-business-rules)
6. [Other Requirements](#6-other-requirements)

[Appendix A: Glossary](#appendix-a-glossary)

[Appendix B: Analysis Models](#appendix-b-analysis-models)


[Appendix C: To Be Determined List](#appendix-c-to-be-determined-list)

---

| Atribut | Nilai |
|---|---|
| Versi Dokumen | 1.1.0 - April 2026 |
| Status | Draft Akhir |
| Dibuat oleh | Tim Pengembang Platform LOKAL |
| Organisasi | Platform LOKAL - Bandung, Jawa Barat, Indonesia |
| Tanggal Dibuat | April 2026 |
| Klasifikasi | Internal - Dokumen Perancangan |
| Database | MySQL 8.0 |

---

## Revision History

| Name | Date | Reason For Changes | Version |
|---|---|---|---|
| Tim Pengembang LOKAL | April 2026 | Dokumen Teknis v1.1 dirilis | 1.1.0 |

---

# 1. Introduction

## 1.1 Purpose
Dokumen SRS ini mendefinisikan kebutuhan perangkat lunak Platform LOKAL v1.1.0 - aplikasi mobile ekosistem ekonomi digital tertutup (*closed-loop*) untuk mengoptimalkan sirkulasi ekonomi lokal di Kota Bandung dan sekitarnya. Dokumen ini mencakup kebutuhan fungsional, non-fungsional, antarmuka eksternal, dan arsitektur sistem sebagai acuan bagi tim developer, QA, manajer proyek, dan pemangku kepentingan.

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
- Dokumen Teknis Sistem LOKAL v1.1.0 - April 2026.  
- IEEE Std 830-1998: Recommended Practice for Software Requirements Specifications.  
- UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi (UU PDP).  
- Regulasi OJK dan Bank Indonesia terkait sistem pembayaran digital.  
- Midtrans API Docs — `https://docs.midtrans.com`  
- Laravel 11 — `https://laravel.com/docs/11.x`  
- Flutter 3.19 — `https://docs.flutter.dev`  

---

# 2. Overall Description

## 2.1 Product Perspective
Platform LOKAL adalah produk baru (bukan pengganti sistem lama) berupa marketplace berbasis lokasi yang menghubungkan penjual UMKM dan pembeli dalam ekosistem tertutup.  
Bukan lembaga keuangan — seluruh transaksi melalui **Midtrans**.  

Komponen utama:
- Mobile App (Flutter)
- API Backend (Laravel 11)
- ML Service (Python/FastAPI)
- n8n Workflow Engine
- MySQL 8.0
- layanan eksternal: Midtrans, Twilio, Google Maps API

## 2.2 Product Functions
- **Autentikasi & Manajemen Pengguna:** Registrasi multi-peran, login OTP SMS, JWT RS256.
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
- **Asumsi:** Pengguna memiliki smartphone kompatibel & internet aktif; UMKM bersedia mengunggah NIB/SIUP.
- **Dependensi eksternal:** Midtrans (pembayaran), Twilio SMS Gateway (OTP), Google Maps Platform (peta), Docker Hub (container registry), GitHub Actions (CI/CD).

---

# 3. External Interface Requirements

## 3.1 User Interfaces
- Navigasi: Bottom navigation bar 5 tab (Beranda, Peta Pasar, Keranjang, Dompet, Profil).
- Peta Interaktif: Google Maps SDK; marker UMKM dengan info window; filter radius 0.5–10 km.
- Checkout Flow: 3 langkah — Keranjang > Konfirmasi & Pembayaran > Status Pesanan.
- Dashboard UMKM: Line chart & bar chart penjualan, kartu ringkasan metrik.
- Responsivitas & Aksesibilitas: Mendukung 360–480dp (portrait) & tablet 600dp+; WCAG 2.1 level AA.

## 3.2 Hardware Interfaces
- GPS/Lokasi: Akurasi min. 50 meter; izin lokasi saat aplikasi digunakan.
- Kamera & Penyimpanan: Untuk unggah foto produk UMKM (izin kamera & galeri).
- Push Notification: FCM (Android) & APNs (iOS).
- Koneksi Internet: Min. 3G/HSPA; mode offline terbatas (riwayat transaksi dari cache lokal).

## 3.3 Software Interfaces
- **Midtrans:** SNAP API + webhook SHA-512; format JSON/HTTPS.
- **Twilio SMS:** OTP 6 digit; timeout 5 menit (disimpan di Redis).
- **Google Maps Platform:** Maps SDK + Geocoding API + Distance Matrix API.
- **ML Service (internal):** FastAPI Python 3.11 + scikit-learn; endpoint `http://ml-service:8000/api/price-recommendation` (asinkron).
- **n8n:** Self-hosted workflow automation; trigger HTTP webhook dari Laravel.
- **MinIO:** Object storage S3-compatible untuk foto produk & dokumen legalitas UMKM.

## 3.4 Communications Interfaces
- Protokol: HTTPS/TLS 1.2 min. (TLS 1.3 direkomendasikan); REST API format JSON.
- Base URL API: `https://api.lokal.id/v1`; autentikasi Bearer Token JWT RS256.
- Rate Limiting: OTP/login 5 req/menit per IP; endpoint umum 100 req/menit per token.
- Push Notification: FCM/APNs; tidak menggunakan WebSocket pada versi MVP.

---

# 4. System Features

Platform LOKAL memiliki 7 fitur sistem utama:

| Kode | Fitur | Deskripsi Singkat | Prioritas |
|---|---|---|---|
| F-01 | Autentikasi & Pengguna | Registrasi multi-peran, login OTP SMS, JWT, verifikasi UMKM | Tinggi |
| F-02 | Peta Pasar & Produk | Peta interaktif UMKM radius 0.5–10 km, CRUD katalog produk | Tinggi |
| F-03 | Transaksi & Pembayaran | Keranjang multi-UMKM, checkout Midtrans (GoPay/OVO/DANA/VA/QRIS) | Tinggi |
| F-04 | Lokal Coin & Insentif | Reward 2%/transaksi, diskon maks. 20%, kadaluwarsa 6 bulan | Sedang |
| F-05 | Rekomendasi Harga ML | Analisis harga produk serupa radius 5 km secara asinkron | Sedang |
| F-06 | Dashboard Analitik UMKM | Grafik penjualan, produk terlaris, pendapatan bersih, real-time | Tinggi |
| F-07 | Notifikasi & Otomasi | Push notification & SMS via n8n untuk event transaksi | Tinggi |

---

## 4.1 F-01: Autentikasi & Pengguna

### 4.1.1 Description and Priority
Mengelola identitas pengguna via OTP nomor telepon.  
**Prioritas:** TINGGI.

### 4.1.2 Functional Requirements
- **REQ-F01-01:** Registrasi tiga peran — Konsumen, UMKM, Produsen.
- **REQ-F01-02:** OTP 6 digit terkirim dalam maks. 30 detik; berlaku 5 menit (Redis TTL 300 detik).
- **REQ-F01-03:** Maks. 5 percobaan OTP salah sebelum nomor diblokir 15 menit.
- **REQ-F01-04:** JWT RS256; access token 24 jam, refresh token 30 hari.
- **REQ-F01-05:** Akun UMKM baru wajib verifikasi dokumen NIB/SIUP oleh admin sebelum berjualan.
- **REQ-F01-06:** Pengguna baru otomatis mendapat 50 Lokal Coin saat aktivasi akun.

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
- **NF-SEC-03:** Rate limiting ketat pada endpoint OTP (5/menit per IP).
- **NF-SEC-04:** Data sensitif (nomor HP, alamat) dienkripsi AES-256 di database.
- **NF-SEC-05:** Mematuhi UU PDP; data pengguna tersimpan di server Indonesia; proteksi OWASP Top 10.

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
| OTP | Kode verifikasi 6 digit, berlaku 5 menit, dikirim via SMS. |
| JWT | JSON Web Token berbasis RFC 7519; digunakan autentikasi setiap request API. |
| Midtrans | Payment gateway Indonesia berizin BI/OJK (GoPay, OVO, DANA, VA, QRIS). |
| QRIS | Quick Response Code Indonesian Standard — standar QR pembayaran nasional BI. |
| n8n | Platform workflow automation open-source untuk orkestrasi notifikasi & distribusi koin. |
| UU PDP | UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi. |
| OJK | Otoritas Jasa Keuangan — pengawas sektor jasa keuangan Indonesia. |
| MVP | Minimum Viable Product — versi produk dengan fitur minimum untuk diuji pengguna awal. |
| TBD | To Be Determined — informasi yang belum tersedia saat penulisan dokumen. |

---

# Appendix B: Analysis Models


## B.1 API Endpoint Summary
**Base URL:** `https://api.lokal.id/v1`

| Method | Endpoint | Deskripsi | Auth |
|---|---|---|---|
| POST | /auth/request-otp | Kirim OTP ke nomor HP | Publik |
| POST | /auth/verify-otp | Verifikasi OTP & dapatkan JWT | Publik |
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

## B.2 Arsitektur Komponen
- **Client Layer:** Flutter 3.19 (Android API 24+ & iOS 14+) — modul Auth, Market Map, Checkout, Wallet, Dashboard.
- **API Gateway Layer:** Nginx 1.25 — reverse proxy, SSL termination, rate limiting.
- **Backend Layer:** Laravel 11 API + n8n Workflow Engine + ML Service (Python/FastAPI).
- **Data Layer:** MySQL 8.0 + Redis 7.2 + MinIO Object Storage.
- **External Services:** Midtrans, Twilio SMS, Google Maps Platform.

---
## B.3 Use case
<img width="400" height="300" alt="UseCaseDiagram" src="https://github.com/user-attachments/assets/d81d2403-fa50-4b09-a267-cdf910a74923" />

## B.4 Activity Diagram
<img width="400" height="300" alt="image" src="https://github.com/user-attachments/assets/e08a280d-7226-4649-8752-2701ab9a341e" />


## B.5 Rancangan Database
<img width="400" height="300" alt="ERD Lokal" src="https://github.com/user-attachments/assets/37d6aed3-b443-4fe2-8ae9-2f817199b62e" />


## B.5 Rancangan Arsitektur Sistem dan Arsitektur Teknologi
<img width="400" height="300" alt="diagram teknologi and diagram arsitektur" src="https://github.com/user-attachments/assets/20635024-9ced-48fa-909e-e698a922089e" />






## B.8 Ui
<img width="300" height="300" alt="Screenshot 2026-04-29 110122" src="https://github.com/user-attachments/assets/97900269-ce23-4ff0-a5ec-158da4bf8e1c" />
<img width="300" height="300" alt="Screenshot 2026-04-29 110054" src="https://github.com/user-attachments/assets/bdfc0a17-cd0e-4a47-8048-21026406f316" />
<img width="300" height="300" alt="Screenshot 2026-04-29 110142" src="https://github.com/user-attachments/assets/592f7f1a-9390-4a23-9e25-a0edc3f739b9" />
<img width="600" height="300" alt="Screenshot 2026-04-29 110345" src="https://github.com/user-attachments/assets/fb2ea66a-def3-4bd3-9cfb-4f7340e548d2" />
<img width="600" height="300" alt="Screenshot 2026-04-29 110423" src="https://github.com/user-attachments/assets/56b478e3-7cf9-4269-a977-c9cf9577055e" />
<img width="600" height="300" alt="Screenshot 2026-04-29 110602" src="https://github.com/user-attachments/assets/f9c8abf2-49aa-4843-943b-25af0fbcebbf" />
<img width="600" height="300" alt="Screenshot 2026-04-29 110632" src="https://github.com/user-attachments/assets/1790723b-02c6-40fc-8368-420c082e7418" />
<img width="600" height="300" alt="Screenshot 2026-04-29 110716" src="https://github.com/user-attachments/assets/cbf13bb2-fbad-4676-8268-7ab70fa66efd" />
<img width="600" height="300" alt="Screenshot 2026-04-29 110732" src="https://github.com/user-attachments/assets/4f606b30-03fb-486b-a212-32d0e4bf3378" />
<img width="600" height="300" alt="Screenshot 2026-04-29 111410" src="https://github.com/user-attachments/assets/32d774db-3db8-4278-ac3a-c4a381ed6a99" />
<img width="600" height="300" alt="Screenshot 2026-04-29 111438" src="https://github.com/user-attachments/assets/d90c4e11-acbc-4c71-9ed3-dc763d5d7571" />
<img width="600" height="300" alt="Screenshot 2026-04-29 111500" src="https://github.com/user-attachments/assets/d97f5f2c-e095-4d9c-95fc-7f534642f5ce" />
<img width="600" height="300" alt="Screenshot 2026-04-29 111605" src="https://github.com/user-attachments/assets/1a716213-41be-4299-8ec3-2a4eeb3e63ab" />



# Appendix C: To Be Determined List

| No. | Item TBD | Target Resolusi |
|---|---|---|
| TBD-01 | Integrasi API logistik pihak ketiga (JNE, SiCepat, AnterAja) | Sprint 3 - Mei 2026 |
| TBD-02 | Video tutorial onboarding UMKM | v1.2.0 - Q3 2026 |
| TBD-03 | Dukungan multi-bahasa (Inggris, Sunda) | v2.0.0 - 2026 |
| TBD-04 | Threshold stok menipis: global atau per-produk? | Sprint 2 - April 2026 |
| TBD-05 | Algoritma ML spesifik (Linear Regression, Random Forest, dll.) | Sprint 4 - Mei 2026 |
| TBD-06 | Spesifikasi teknis panel admin verifikasi UMKM | Dokumen terpisah - Q2 2026 |
| TBD-07 | Mekanisme penyelesaian sengketa konsumen–UMKM | v1.5.0 - Q4 2026 |
| TBD-08 | Target concurrent users fase produksi penuh | Setelah evaluasi pilot |

---

