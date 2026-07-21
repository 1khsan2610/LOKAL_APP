**Laporan Test Plan (Rencana Pengujian)**

# Platform LOKAL --- EkonomiLokal

![UKRI - Universitas Kebangsaan Republik
Indonesia](media/image1.png){width="2.4520833333333334in"
height="2.308333333333333in"}

**Kelompok 4**

1.  **Naufal al farros: 20241320091\
    2. Linda anjarini:20241320058\
    3. Najwa alifah:20241320077\
    5. ⁠ikbal maulana aspahni:20241320053\
    6. Kiara Evi Nurdiati Putri Rahmatillah 20241320067**

***PROGRAM STUDI SISTEM INFORMASI***

***FAKULTAS ILMU KOMPUTER DAN SISTEM INFORMASI***

***UNIVERSITAS KEBANGSAAN REPUBLIK INDONESIA***

***2026***

Atribut Nilai

Proyek EkonomiLokal (Platform LOKAL)

Mata Kuliah Rekayasa Sistem Informasi (RSI) & Software

> Testing

Versi Dokumen 1.0

Objek Uji Backend Laravel 11 (REST API) & Frontend

> Flutter (Web/Mobile)

Tools Utama Playwright (E2E), PHPUnit (Feature Test),

> Postman (manual API test)

**BAGIAN 1 --- TEST PLAN (RENCANA PENGUJIAN)**

# 1.1 Tujuan Pengujian

> Memastikan seluruh fungsi utama Platform LOKAL --- autentikasi,
> katalog produk, transaksi, Lokal Coin, ulasan, dashboard UMKM,
> notifikasi, dan panel admin --- berjalan sesuai dengan kebutuhan
> fungsional yang didefinisikan pada dokumen SRS, serta memastikan tidak
> ada regresi fungsional pada setiap perubahan kode sebelum dirilis.

# 1.2 Ruang Lingkup Pengujian (Scope)

**In-Scope**

-   Modul Autentikasi: Register Account, Login, Logout, Lupa/Reset
    Password.

-   Modul Katalog Produk & Peta Pasar (pencarian, filter, detail produk,
    UMKM terdekat).

-   Modul Keranjang & Checkout (tambah/ubah/hapus item, pembuatan
    pesanan).

-   Modul Pembayaran (integrasi API Midtrans, webhook notifikasi
    status).

-   Modul Pelacakan Pesanan (order tracking) dan pembatalan/konfirmasi
    pesanan.

-   Modul Lokal Coin (saldo, riwayat transaksi, redeem sebagai potongan
    harga).

-   Modul Ulasan Produk (tambah/ubah/hapus ulasan).

-   Modul Dashboard Analitik UMKM (ringkasan penjualan, grafik).

-   Modul Notifikasi (daftar notifikasi, tandai dibaca, registrasi
    device token).

-   Modul Panel Administrator (verifikasi UMKM, moderasi produk,
    manajemen transaksi).

-   Validasi kontrol akses berbasis peran (Role-Based Access Control)
    pada seluruh endpoint privat.

**Out-of-Scope**

-   Pengujian pembayaran riil (menggunakan kredensial produksi Midtrans)
    --- pengujian dibatasi pada mode *sandbox*.

-   Pengujian beban skala penuh (*full-scale load/stress testing*) untuk
    10.000+ pengguna konkuren.

-   Pengujian aplikasi native pada seluruh varian perangkat Android/iOS
    fisik (pengujian E2E difokuskan pada Flutter Web).

-   Pengujian penetrasi keamanan (*penetration testing*) mendalam.

-   Integrasi logistik pihak ketiga (JNE/SiCepat/AnterAja) --- belum
    diimplementasikan

> pada kode saat ini (lihat SRS Lampiran C).

# 1.3 Strategi Pengujian

+------------------------------------+---------------------------------+
| Jenis Pengujian                    | Tools                           |
+====================================+=================================+
| **Black-box Testing**              | Manual + Playwright UI          |
+------------------------------------+---------------------------------+
| **API Integration Testing**        | Playwright (request context) &  |
|                                    | Postman                         |
+------------------------------------+---------------------------------+
| **End-to-End (E2E) Testing**       | Playwright                      |
|                                    |                                 |
|                                    | (Chromium/Firefox/WebKit        |
|                                    |                                 |
|                                    | )                               |
+------------------------------------+---------------------------------+
| **Feature/Unit Testing (Backend)** | PHPUnit                         |
+------------------------------------+---------------------------------+
| **User Acceptance Testing (UAT)**  | Manual, skenario terstruktur    |
+------------------------------------+---------------------------------+

> Deskripsi
>
> Pengujian fungsional dari sudut pandang pengguna akhir tanpa
> mengetahui detail implementasi internal.
>
> Pengujian kontrak REST API secara langsung: format respons, kode
> status HTTP, validasi input, dan otorisasi berbasis peran.
>
> Simulasi alur pengguna nyata dari login hingga transaksi selesai,
> dijalankan otomatis melalui GitHub Actions.
>
> Pengujian pada level kode backend (backend/tests/Feature
>
> /), mencakup validasi upload gambar, pembuatan produk, dan konfigurasi
> CORS.
>
> Dilakukan oleh anggota tim yang berperan sebagai Konsumen, UMKM, dan
> Admin untuk memvalidasi kesesuaian fungsi dengan kebutuhan bisnis.

+-----------------------------------+----------------------------------+
| > Komponen                        | Detail                           |
+===================================+==================================+
| > Backend                         | Laravel 11 dijalankan via Docker |
|                                   | Compose,                         |
|                                   | http://localhost:8000/api        |
+-----------------------------------+----------------------------------+
| > Frontend                        | Flutter Web, flutter run -d      |
|                                   | webserver \--web-port=59273      |
+-----------------------------------+----------------------------------+
| > Basis Data                      | MySQL 8.0 (hasil migrate         |
|                                   | \--seed)                         |
+-----------------------------------+----------------------------------+
| > Browser E2E                     | Chromium, Firefox, WebKit (via   |
|                                   | Playwright)                      |
+-----------------------------------+----------------------------------+
| > CI/CD                           | GitHub Actions                   |
|                                   |                                  |
| 1.5 Peran & Tanggung Jawab        | (.                               |
|                                   | github/workflows/playwright.yml) |
+-----------------------------------+----------------------------------+
| > Peran                           | Tanggung Jawab                   |
+-----------------------------------+----------------------------------+
| > QA Lead                         | Menyusun rencana pengujian,      |
|                                   | mengelola prioritas dan jadwal   |
|                                   | pengujian                        |
+-----------------------------------+----------------------------------+
| > Test Engineer                   | Menulis dan menjalankan skrip    |
|                                   | Playwright & test case manual    |
+-----------------------------------+----------------------------------+
| > Backend Developer               | Memperbaiki bug pada sisi API,   |
|                                   | menjaga cakupan PHPUnit          |
+-----------------------------------+----------------------------------+
| > Frontend Developer              | Memperbaiki bug pada sisi UI     |
|                                   | Flutter                          |
+-----------------------------------+----------------------------------+

# 1.4 Lingkungan Pengujian (Test Environment)

# 1.6 Exit Criteria (Kriteria Kelulusan Pengujian)

> Pengujian dinyatakan selesai dan sistem **layak dipertimbangkan untuk
> rilis** apabila: 1. **Seluruh test case berprioritas Tinggi (High)**
> berstatus **Pass** --- 100%. 2. Pass rate keseluruhan (seluruh
> prioritas) minimal **90%**. 3. Tidak terdapat bug dengan tingkat
> keparahan **Critical** atau **High** yang masih berstatus **Open**. 4.
> Seluruh regresi pada modul Autentikasi, Transaksi, dan Pembayaran
> telah diverifikasi ulang (*retest*) dan **Pass**. 5. Laporan eksekusi
> pengujian telah didokumentasikan dan disetujui oleh QA Lead.
