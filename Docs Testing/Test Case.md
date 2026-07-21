# Laporan Test Case

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

# BAGIAN 2 — TEST CASES (MATRIKS TEST CASE)

## Modul Autentikasi

| ID | Modul | Skenario Pengujian | Langkah | Ekspektasi | Prioritas |
|----|-------|--------------------|---------|------------|-----------|
| TC-AUTH-01 | Autentikasi | Login dengan akun Konsumen valid | 1. Buka halaman login<br>2. Masukkan email & password Konsumen valid<br>3. Tekan tombol Masuk | Pengguna berhasil login dan diarahkan ke halaman utama (Home) | Tinggi |
| TC-AUTH-02 | Autentikasi | Login dengan akun UMKM valid | 1. Buka halaman login<br>2. Masukkan email & password UMKM valid<br>3. Tekan tombol Masuk | Pengguna berhasil login dan dapat mengakses menu khusus UMKM | Tinggi |
| TC-AUTH-03 | Autentikasi | Login dengan format email tidak valid | 1. Buka halaman login<br>2. Masukkan email tanpa simbol "@"<br>3. Tekan tombol Masuk | Sistem menampilkan validasi dan tidak mengirim permintaan ke backend | Sedang |
| TC-AUTH-04 | Autentikasi | Login dengan kata sandi salah | 1. Buka halaman login<br>2. Masukkan email valid, password salah<br>3. Tekan tombol Masuk | Sistem menampilkan pesan "Email atau password salah" (HTTP 401) | Tinggi |
| TC-AUTH-05 | Autentikasi | Registrasi akun Konsumen baru | 1. Buka halaman Register Account<br>2. Isi nama, email baru, password, telepon, pilih peran Konsumen<br>3. Kirim formulir | Akun baru berhasil dibuat (HTTP 201), token JWT diterbitkan, dompet Lokal Coin dibuat dengan saldo 0 | Tinggi |
| TC-AUTH-06 | Autentikasi | Registrasi akun UMKM baru | 1. Buka halaman Register Account<br>2. Isi data diri, pilih peran UMKM, isi nama & kategori toko<br>3. Kirim formulir | Akun & toko UMKM berhasil dibuat dengan status `is_verified = false` | Tinggi |
| TC-AUTH-07 | Autentikasi | Registrasi dengan email yang sudah terdaftar | 1. Isi formulir registrasi dengan email yang sudah ada di database<br>2. Kirim formulir | Sistem menolak dan menampilkan pesan validasi "email sudah digunakan" | Sedang |
| TC-AUTH-08 | Autentikasi | Lupa password — kirim tautan reset | 1. Buka halaman "Lupa Password"<br>2. Masukkan email terdaftar<br>3. Kirim permintaan | Sistem mengirimkan email berisi tautan reset password | Sedang |
| TC-AUTH-09 | Autentikasi | Logout pengguna | 1. Login dengan akun valid<br>2. Tekan tombol Logout | Token JWT diinvalidasi dan pengguna diarahkan kembali ke halaman login | Sedang |

## Modul Navigasi

| ID | Modul | Skenario Pengujian | Langkah | Ekspektasi | Prioritas |
|----|-------|--------------------|---------|------------|-----------|
| TC-NAV-01 | Navigasi | Akses halaman utama setelah login | 1. Login dengan akun Konsumen<br>2. Amati halaman Home | Katalog produk dan banner ditampilkan tanpa error | Tinggi |
| TC-NAV-02 | Navigasi | Berpindah ke halaman Peta Pasar | 1. Dari Home, tekan menu "Peta Pasar" | Peta interaktif menampilkan lokasi UMKM terdekat | Sedang |
| TC-NAV-03 | Navigasi | Berpindah ke halaman Keranjang | 1. Dari Home, tekan ikon Keranjang | Halaman keranjang belanja ditampilkan | Sedang |
| TC-NAV-04 | Navigasi | Berpindah ke halaman Wallet | 1. Dari menu profil, tekan "Lokal Coin / Wallet" | Saldo dan riwayat Lokal Coin ditampilkan | Sedang |

## Modul Produk

| ID | Modul | Skenario Pengujian | Langkah | Ekspektasi | Prioritas |
|----|-------|--------------------|---------|------------|-----------|
| TC-PROD-01 | Produk | Menampilkan daftar produk | 1. Buka halaman Home<br>2. Amati daftar produk | Produk aktif ditampilkan lengkap dengan harga dan gambar | Tinggi |
| TC-PROD-02 | Produk | Pencarian produk berdasarkan kata kunci | 1. Buka fitur pencarian<br>2. Ketik nama produk yang ada, mis. "Bakso"<br>3. Tekan cari | Produk relevan ditampilkan sesuai kata kunci | Sedang |
| TC-PROD-03 | Produk | UMKM menambahkan produk baru | 1. Login sebagai UMKM<br>2. Buka "Manajemen Produk" → "Tambah Produk"<br>3. Isi data & unggah gambar<br>4. Simpan | Produk baru tersimpan dan tampil pada katalog toko | Tinggi |
| TC-PROD-04 | Produk | Konsumen tidak dapat menambahkan produk | 1. Login sebagai Konsumen<br>2. Kirim permintaan POST ke endpoint tambah produk | Sistem menolak dengan status 403 Forbidden | Tinggi |
| TC-PROD-05 | Produk | UMKM menghapus produk miliknya | 1. Login sebagai UMKM<br>2. Pilih produk milik sendiri<br>3. Tekan Hapus | Produk terhapus dari katalog toko | Sedang |

## Modul Keranjang

| ID | Modul | Skenario Pengujian | Langkah | Ekspektasi | Prioritas |
|----|-------|--------------------|---------|------------|-----------|
| TC-CART-01 | Keranjang | Menambahkan produk ke keranjang | 1. Login sebagai Konsumen<br>2. Buka detail produk<br>3. Tekan "Tambah ke Keranjang" | Produk tampil di halaman Keranjang dengan kuantitas 1 | Tinggi |
| TC-CART-02 | Keranjang | Mengubah kuantitas item di keranjang | 1. Buka halaman Keranjang<br>2. Ubah kuantitas item menjadi 3 | Subtotal keranjang diperbarui sesuai kuantitas baru | Sedang |
| TC-CART-03 | Keranjang | Menghapus item dari keranjang | 1. Buka halaman Keranjang<br>2. Tekan hapus pada salah satu item | Item terhapus dan subtotal diperbarui | Sedang |

## Modul Checkout

| ID | Modul | Skenario Pengujian | Langkah | Ekspektasi | Prioritas |
|----|-------|--------------------|---------|------------|-----------|
| TC-CHK-01 | Checkout | Checkout dengan pembayaran Midtrans (sandbox) | 1. Isi keranjang<br>2. Tekan Checkout<br>3. Pilih alamat & metode pembayaran (GoPay/QRIS)<br>4. Selesaikan pembayaran sandbox | Pesanan tercipta berstatus "menunggu pembayaran", lalu berubah menjadi "diproses" setelah webhook diterima | Tinggi |
| TC-CHK-02 | Checkout | Checkout menggunakan potongan Lokal Coin | 1. Pastikan saldo koin mencukupi<br>2. Saat checkout, aktifkan opsi "Gunakan Lokal Coin"<br>3. Selesaikan pesanan | Potongan harga diterapkan maksimum 20% dari subtotal dan saldo koin berkurang sesuai nilai potongan | Tinggi |
| TC-CHK-03 | Checkout | Checkout dengan keranjang kosong | 1. Kosongkan keranjang<br>2. Coba tekan tombol Checkout | Sistem mencegah proses checkout dan menampilkan pesan bahwa keranjang kosong | Sedang |

## Modul Pesanan

| ID | Modul | Skenario Pengujian | Langkah | Ekspektasi | Prioritas |
|----|-------|--------------------|---------|------------|-----------|
| TC-ORD-01 | Pesanan | Melihat riwayat pesanan | 1. Login sebagai Konsumen<br>2. Buka menu "Pesanan Saya" | Daftar pesanan yang pernah dibuat ditampilkan | Sedang |
| TC-ORD-02 | Pesanan | Melacak status pesanan (order tracking) | 1. Buka detail pesanan<br>2. Amati linimasa status | Status dan riwayat tracking ditampilkan berurutan sesuai waktu kejadian | Tinggi |
| TC-ORD-03 | Pesanan | Membatalkan pesanan sebelum diproses | 1. Buka pesanan berstatus "menunggu pembayaran"<br>2. Tekan "Batalkan Pesanan" | Status pesanan berubah menjadi "dibatalkan" | Sedang |
| TC-ORD-04 | Pesanan | UMKM memperbarui status pesanan | 1. Login sebagai UMKM<br>2. Buka "Pesanan Toko"<br>3. Ubah status menjadi "Dikirim" | Status pesanan berubah dan notifikasi terkirim ke Konsumen | Tinggi |
| TC-ORD-05 | Pesanan | Konsumen konfirmasi pesanan diterima | 1. Buka pesanan berstatus "dikirim"<br>2. Tekan "Konfirmasi Diterima" | Status berubah menjadi "selesai" dan `delivered_at` tercatat | Sedang |

## Modul Lokal Coin

| ID | Modul | Skenario Pengujian | Langkah | Ekspektasi | Prioritas |
|----|-------|--------------------|---------|------------|-----------|
| TC-COIN-01 | Lokal Coin | Melihat saldo dan riwayat Lokal Coin | 1. Login sebagai Konsumen<br>2. Buka menu Wallet | Saldo dan daftar riwayat transaksi koin ditampilkan | Sedang |
| TC-COIN-02 | Lokal Coin | Perhitungan potongan maksimum koin | 1. Simulasikan subtotal Rp100.000 dengan saldo koin 15.000<br>2. Hitung potongan maksimum | Potongan = min(20% × 100.000, 15.000 × 10) = Rp20.000 | Tinggi |

## Modul Ulasan

| ID | Modul | Skenario Pengujian | Langkah | Ekspektasi | Prioritas |
|----|-------|--------------------|---------|------------|-----------|
| TC-REV-01 | Ulasan | Konsumen memberikan ulasan produk | 1. Buka pesanan berstatus "selesai"<br>2. Tekan "Beri Ulasan"<br>3. Isi rating & komentar<br>4. Kirim | Ulasan tersimpan dan tampil pada halaman detail produk | Sedang |
| TC-REV-02 | Ulasan | Konsumen menghapus ulasan miliknya | 1. Buka "Ulasan Saya"<br>2. Pilih ulasan<br>3. Tekan Hapus | Ulasan terhapus dari daftar | Rendah |

## Modul Dashboard UMKM

| ID | Modul | Skenario Pengujian | Langkah | Ekspektasi | Prioritas |
|----|-------|--------------------|---------|------------|-----------|
| TC-DASH-01 | Dashboard UMKM | Melihat ringkasan performa penjualan | 1. Login sebagai UMKM<br>2. Buka "Dashboard Analitik" | Total pendapatan, jumlah pesanan, dan produk terlaris ditampilkan | Sedang |

## Modul Notifikasi

| ID | Modul | Skenario Pengujian | Langkah | Ekspektasi | Prioritas |
|----|-------|--------------------|---------|------------|-----------|
| TC-NOTIF-01 | Notifikasi | Menampilkan daftar notifikasi | 1. Login<br>2. Buka menu Notifikasi | Notifikasi terkait pesanan/pembayaran ditampilkan | Rendah |
| TC-NOTIF-02 | Notifikasi | Menandai notifikasi sebagai dibaca | 1. Buka daftar notifikasi<br>2. Tekan salah satu notifikasi | Status notifikasi berubah menjadi "dibaca" | Rendah |

## Modul Admin

| ID | Modul | Skenario Pengujian | Langkah | Ekspektasi | Prioritas |
|----|-------|--------------------|---------|------------|-----------|
| TC-ADM-01 | Admin | Login ke panel Administrator | 1. Buka `/admin/login`<br>2. Masukkan kredensial admin<br>3. Tekan Masuk | Admin berhasil login dan diarahkan ke dashboard admin | Tinggi |
| TC-ADM-02 | Admin | Verifikasi pendaftaran UMKM baru | 1. Login sebagai admin<br>2. Buka daftar UMKM belum terverifikasi<br>3. Tekan "Verifikasi" | Status `is_verified` UMKM berubah menjadi true | Tinggi |
| TC-ADM-03 | Admin | Menonaktifkan akun pengguna | 1. Login sebagai admin<br>2. Pilih pengguna<br>3. Tekan "Nonaktifkan" | `is_active` pengguna menjadi false; pengguna tidak dapat login kembali | Sedang |

## Modul Keamanan / RBAC

| ID | Modul | Skenario Pengujian | Langkah | Ekspektasi | Prioritas |
|----|-------|--------------------|---------|------------|-----------|
| TC-SEC-01 | Keamanan/RBAC | Akses endpoint privat tanpa token | 1. Kirim permintaan GET ke `/api/cart` tanpa header Authorization | Sistem menolak dengan status 401 Unauthorized | Tinggi |
| TC-SEC-02 | Keamanan/RBAC | Akses endpoint admin oleh peran non-admin | 1. Login sebagai Konsumen<br>2. Kirim permintaan ke endpoint `/api/admin/*` | Sistem menolak dengan status 403 Forbidden | Tinggi |

---

# BAGIAN 3 — PLAYWRIGHT AUTOMATED TEST SCRIPTS

| Berkas | Cakupan |
|--------|---------|
| `tests/pages/LoginPage.ts` | Page Object Model untuk halaman Login |
| `tests/fixtures/test-data.ts` | Data uji (akun demo & data registrasi) |
| `tests/01-login.spec.ts` | TC-AUTH-01 s/d TC-AUTH-04 — Login flow (UI) |
| `tests/02-navigation.spec.ts` | TC-NAV-01 s/d TC-NAV-04 — Navigasi antar halaman utama |
| `tests/03-api-integration.spec.ts` | TC-API-01 s/d TC-API-11 — Pengujian integrasi REST API (login, registrasi, produk, cart, wallet, RBAC) |
| `tests/04-register-form.spec.ts` | TC-REG-01 s/d TC-REG-02 — Form input registrasi |
| `playwright.config.ts` | Konfigurasi eksekusi pengujian (browser, base URL, reporter) |

Skrip pengujian otomatis (TypeScript) tersedia pada folder `qa-testing/tests/` yang menyertai laporan ini.

### Contoh Cuplikan Skrip — Login Flow (`tests/01-login.spec.ts`)

```typescript
import { test, expect } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';
import { loginTestData } from './fixtures/test-data';

test('TC-AUTH-01: Konsumen berhasil login dengan kredensial valid', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.open();
  await loginPage.fillCredentials(loginTestData.consumer.email, loginTestData.consumer.password);
  await loginPage.submit();
  await expect(page).toHaveURL(/\/main|\/home|\/admin/);
});
```

### Contoh Cuplikan Skrip — Checkout/API Submit (`tests/03-api-integration.spec.ts`)

```typescript
test('TC-API-08: Konsumen dapat menambahkan produk ke keranjang', async ({ request }) => {
  const loginRes = await request.post(`${apiBaseUrl}/auth/login`, {
    data: {
      email: loginTestData.consumer.email,
      password: loginTestData.consumer.password
    }
  });
  const { data } = await loginRes.json();

  const cartRes = await request.post(`${apiBaseUrl}/cart`, {
    headers: { Authorization: `Bearer ${data.token}` },
    data: { product_id: 1, quantity: 1 }
  });

  expect(cartRes.ok()).toBeTruthy();
});
```

### Cara Menjalankan

```bash
npm install
npx playwright install --with-deps
npx playwright test               # jalankan seluruh skrip
npx playwright test 01-login      # jalankan skrip login saja
npx playwright show-report        # lihat laporan HTML