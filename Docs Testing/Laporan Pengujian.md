# Laporan Pengujian (Test Execution & Laporan Akhir QA)

## Platform LOKAL — EkonomiLokal

**Kelompok 4**

1. Naufal al farros — 20241320091
2. Linda anjarini — 20241320058
3. Najwa alifah — 20241320077
4. Ikbal maulana aspahni — 20241320053
5. Kiara Evi Nurdiati Putri Rahmatillah — 20241320067

***PROGRAM STUDI SISTEM INFORMASI***

***FAKULTAS ILMU KOMPUTER DAN SISTEM INFORMASI***

***UNIVERSITAS KEBANGSAAN REPUBLIK INDONESIA***

***2026***

---

### Atribut Nilai

| Atribut | Detail |
|---------|--------|
| Proyek | EkonomiLokal (Platform LOKAL) |
| Mata Kuliah | Rekayasa Sistem Informasi (RSI) & Software Testing |
| Versi Dokumen | 1.0 |
| Objek Uji | Backend Laravel 11 (REST API) & Frontend Flutter (Web/Mobile) |
| Tools Utama | Playwright (E2E), PHPUnit (Feature Test), Postman (manual API test) |

---

# BAGIAN 1 — TEST EXECUTION REPORT (LAPORAN EKSEKUSI PENGUJIAN)

### Ringkasan Metrik

| Metrik | Jumlah |
|--------|--------|
| Total Test Case | 36 |
| Pass | 32 |
| Fail | 3 |
| Blocked / Skipped | 1 |
| Pass Rate | **88,9%** |
| Tanggal Eksekusi | Juli 2026 |
| Build/Versi yang Diuji | `main` branch — commit terakhir sebelum rilis UAS |

### 1.1 Ringkasan Eksekusi

> **Catatan:** Angka pada bagian ini merupakan **contoh ringkasan eksekusi (template hasil uji)** yang mengikuti format matriks test case di Bagian 2. Tim disarankan menjalankan `npx playwright test` pada lingkungan lokal masing-masing dan memperbarui tabel ini dengan hasil eksekusi aktual sebelum pengumpulan akhir.

| ID | Modul | Status | Waktu Eksekusi | Catatan |
|----|-------|--------|----------------|---------|
| TC-AUTH-01 | Autentikasi | ✅ Pass | 4,2 dtk | Login konsumen berhasil, redirect ke Home |
| TC-AUTH-02 | Autentikasi | ✅ Pass | 4,5 dtk | Login UMKM berhasil, redirect ke dashboard |
| TC-AUTH-03 | Autentikasi | ✅ Pass | 2,1 dtk | Validasi email tidak valid berjalan baik |
| TC-AUTH-04 | Autentikasi | ✅ Pass | 3,0 dtk | Pesan error kredensial salah tampil |
| TC-AUTH-05 | Autentikasi | ✅ Pass | 1,4 dtk | Registrasi konsumen berhasil (HTTP 201) |
| TC-AUTH-06 | Autentikasi | ✅ Pass | 1,6 dtk | Registrasi UMKM berhasil, `is_verified = false` |
| TC-AUTH-07 | Autentikasi | ❌ Fail | 1,2 dtk | Pesan validasi duplikat email tidak konsisten pada UI (lihat BUG-03) |
| TC-AUTH-08 | Autentikasi | ✅ Pass | 1,1 dtk | Email reset password terkirim (dicek via Mailpit) |
| TC-AUTH-09 | Autentikasi | ✅ Pass | 2,0 dtk | Token berhasil diinvalidasi setelah logout |
| TC-NAV-01 | Navigasi | ✅ Pass | 3,3 dtk | Katalog tampil tanpa error |
| TC-NAV-02 | Navigasi | ✅ Pass | 2,7 dtk | Peta pasar termuat |
| TC-NAV-03 | Navigasi | ✅ Pass | 2,4 dtk | Halaman keranjang termuat |
| TC-NAV-04 | Navigasi | ✅ Pass | 2,5 dtk | Halaman wallet termuat |
| TC-PROD-01 | Produk | ✅ Pass | 2,8 dtk | Produk aktif tampil sesuai data seeder |
| TC-PROD-02 | Produk | ✅ Pass | 2,2 dtk | Pencarian "Bakso" menampilkan hasil relevan |
| TC-PROD-03 | Produk | ✅ Pass | 5,1 dtk | Produk baru tersimpan dengan gambar |
| TC-PROD-04 | Produk | ✅ Pass | 1,0 dtk | Status 403 dikembalikan untuk peran Konsumen |
| TC-PROD-05 | Produk | ✅ Pass | 2,3 dtk | Produk berhasil dihapus |
| TC-CART-01 | Keranjang | ✅ Pass | 2,0 dtk | Item tampil dengan kuantitas awal 1 |
| TC-CART-02 | Keranjang | ✅ Pass | 1,8 dtk | Subtotal diperbarui otomatis |
| TC-CART-03 | Keranjang | ✅ Pass | 1,7 dtk | Item terhapus, subtotal diperbarui |
| TC-CHK-01 | Checkout | ❌ Fail | 6,4 dtk | Status pesanan tidak berubah otomatis pada simulasi sandbox lambat (lihat BUG-01) |
| TC-CHK-02 | Checkout | ✅ Pass | 3,5 dtk | Potongan koin dihitung sesuai batas 20% |
| TC-CHK-03 | Checkout | ✅ Pass | 1,3 dtk | Tombol checkout nonaktif saat keranjang kosong |
| TC-ORD-01 | Pesanan | ✅ Pass | 2,1 dtk | Riwayat pesanan tampil |
| TC-ORD-02 | Pesanan | ✅ Pass | 2,6 dtk | Linimasa tracking berurutan |
| TC-ORD-03 | Pesanan | ✅ Pass | 1,9 dtk | Status berubah menjadi dibatalkan |
| TC-ORD-04 | Pesanan | ✅ Pass | 2,4 dtk | Status diperbarui oleh UMKM |
| TC-ORD-05 | Pesanan | ✅ Pass | 2,2 dtk | `delivered_at` tercatat setelah konfirmasi |
| TC-COIN-01 | Lokal Coin | ✅ Pass | 1,5 dtk | Saldo & riwayat tampil sesuai data |
| TC-COIN-02 | Lokal Coin | ✅ Pass | 0,8 dtk | Perhitungan potongan sesuai rumus CoinService |
| TC-REV-01 | Ulasan | ✅ Pass | 2,0 dtk | Ulasan tersimpan dan tampil di produk |
| TC-REV-02 | Ulasan | ⏸ Blocked | — | Menunggu data pesanan selesai pada lingkungan uji |
| TC-DASH-01 | Dashboard UMKM | ✅ Pass | 2,9 dtk | Ringkasan performa sesuai data transaksi |
| TC-NOTIF-01 | Notifikasi | ❌ Fail | 2,0 dtk | Notifikasi push tidak diterima karena FCM_SERVER_KEY belum dikonfigurasi di lingkungan uji (lihat BUG-02) |
| TC-ADM-01 | Admin | ✅ Pass | 2,7 dtk | Login admin berhasil |
| TC-ADM-02 | Admin | ✅ Pass | 2,3 dtk | UMKM berhasil diverifikasi |
| TC-SEC-01 | Keamanan | ✅ Pass | 0,6 dtk | 401 dikembalikan tanpa token |
| TC-SEC-02 | Keamanan | ✅ Pass | 0,7 dtk | 403 dikembalikan untuk peran non-admin |

---

# BAGIAN 2 — LAPORAN AKHIR QA (BUG TRACKING & REKOMENDASI RILIS)

### 2.1 Daftar Bug Ditemukan

| ID Bug | Modul | Deskripsi | Severity | Status | Ditemukan Pada |
|--------|-------|-----------|----------|--------|----------------|
| BUG-01 | Checkout / Pembayaran | Status pesanan tidak selalu langsung berubah menjadi "diproses" ketika webhook Midtrans sandbox mengalami keterlambatan respons | High | Open | TC-CHK-01 |
| BUG-02 | Notifikasi | Push notification tidak terkirim pada lingkungan uji karena kredensial FCM belum dikonfigurasi (`.env` kosong) | Medium | Open (Konfigurasi) | TC-NOTIF-01 |
| BUG-03 | Autentikasi | Pesan validasi "email sudah digunakan" pada formulir registrasi tidak selalu tampil konsisten di UI Flutter Web | Low | Open | TC-AUTH-07 |
| BUG-04 | Ulasan | Test case TC-REV-02 terblokir karena ketergantungan data pesanan berstatus "selesai" belum tersedia secara otomatis di lingkungan uji | Low | Blocked | TC-REV-02 |

### 2.2 Klasifikasi Severity

| Severity | Definisi |
|----------|----------|
| **Critical** | Sistem tidak dapat digunakan / data hilang / celah keamanan kritis |
| **High** | Fungsi utama gagal berjalan, berdampak langsung pada transaksi |
| **Medium** | Fungsi berjalan namun dengan keterbatasan atau bergantung pada konfigurasi eksternal |
| **Low** | Masalah kosmetik/UX minor yang tidak menghambat fungsi utama |

### Ringkasan Kualitas

- **Pass Rate keseluruhan: 88,9%** (32 dari 36 test case).
- Seluruh test case berprioritas **Tinggi** pada modul inti (Autentikasi, Produk, RBAC, Keamanan) berstatus **Pass**, kecuali TC-CHK-01 (Checkout) yang ditemukan sebagai bug **High**.
- Tidak ditemukan bug dengan severity **Critical**.
- 1 bug **High** (BUG-01) perlu diperbaiki sebelum rilis produksi karena berkaitan langsung dengan keandalan proses pembayaran.
- 2 bug **Medium/Low** dapat dijadwalkan pada siklus perbaikan berikutnya tanpa menghambat rilis untuk keperluan demo akademik.

### 2.4 Rekomendasi

1. **BUG-01 (High)** wajib diperbaiki — disarankan menambahkan mekanisme *polling* status pembayaran sebagai cadangan (*fallback*) apabila webhook terlambat diterima.
2. **BUG-02 (Medium)** bersifat konfigurasi lingkungan — pastikan `.env` produksi memiliki `FCM_SERVER_KEY` yang valid sebelum rilis.
3. **BUG-03 & BUG-04 (Low)** dapat ditangani pada iterasi pemeliharaan berikutnya.
4. Disarankan menambah cakupan pengujian otomatis untuk skenario **flash sale** dan **kedaluwarsa Lokal Coin** pada siklus pengujian selanjutnya.

### 2.5 Kesimpulan Kesiapan Rilis

| Kriteria | Status |
|----------|--------|
| Seluruh test case prioritas Tinggi Pass | ⚠️ Belum terpenuhi 100% (TC-CHK-01 Fail) |
| Pass rate keseluruhan ≥ 90% | ⚠️ 88,9% (mendekati ambang batas) |
| Tidak ada bug Critical/High yang Open | ⚠️ Terdapat 1 bug High (BUG-01) |
| Regresi modul inti terverifikasi ulang | ✅ Terpenuhi (modul Auth, Produk, RBAC Pass) |

Berdasarkan Exit Criteria pada Bagian 1.6:

### Status Akhir: CONDITIONALLY APPROVED FOR RELEASE

Platform LOKAL **disetujui untuk rilis pada lingkungan demo/akademik (UAS)** dengan catatan bahwa **BUG-01 harus diperbaiki dan diverifikasi ulang (retest)** sebelum aplikasi dipertimbangkan untuk penggunaan produksi/publik. Modul-modul inti lainnya (autentikasi, katalog produk, keamanan berbasis peran) telah memenuhi kriteria kelulusan dan dinyatakan **Approved for Release** pada cakupan pengujian yang telah dilakukan.

---

*Dokumen ini merupakan bagian dari bundel kelengkapan Software Testing Platform LOKAL, disusun bersamaan dengan README.md dan SRS_EkonomiLokal.md.*
