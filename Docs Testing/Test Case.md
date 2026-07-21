# Laporan Test Case

**Platform LOKAL --- EkonomiLokal**
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

Mata Kuliah Rekayasa Sistem Informasi (RSI) & Software Testing

Versi Dokumen 1.0

Objek Uji Backend Laravel 11 (REST API) & Frontend Flutter (Web/Mobile)

Tools Utama Playwright (E2E), PHPUnit (Feature Test),

Postman (manual API test)

# BAGIAN 2 --- TEST CASES (MATRIKS TEST CASE)

Langkah Ekspektasi

ID Modul Skenario Pengujian Hasil Prioritas

+------------------+------------------+------------------+------------+
| TC-AUTH-01       | Autentikasi      | Login dengan     | 1\. Buka   |
|                  |                  | akun Konsumen    | halaman    |
|                  |                  |                  | login 2.   |
|                  |                  | valid            |            |
|                  |                  |                  | Masukkan   |
|                  |                  |                  | email &    |
|                  |                  |                  | password   |
|                  |                  |                  | Konsumen   |
|                  |                  |                  | valid 3.   |
|                  |                  |                  |            |
|                  |                  |                  | Tekan      |
|                  |                  |                  | tombol     |
|                  |                  |                  |            |
|                  |                  |                  | Masuk      |
+==================+==================+==================+============+
+------------------+------------------+------------------+------------+

Pengguna Tinggi

berhasil login dan diarahkan ke halaman utama (Home)

+-----------------+-----------------+-----------------+--------------+
| TC-AUTH-02      | Autentikasi     | Login dengan    | 1\. Buka     |
|                 |                 | akun UMKM       | halaman      |
|                 |                 |                 | login 2.     |
|                 |                 | valid           |              |
|                 |                 |                 | Masukkan     |
|                 |                 |                 | email &      |
|                 |                 |                 | password     |
|                 |                 |                 | UMKM valid   |
|                 |                 |                 | 3. Tekan     |
|                 |                 |                 | tombol       |
+=================+=================+=================+==============+
+-----------------+-----------------+-----------------+--------------+

Pengguna Tinggi

berhasil login dan dapat mengakses menu khusus

UMKM

+------------+------------+------------+------------+------------+-----+
|            |            |            | Masuk      |            |     |
+============+============+============+============+============+=====+
| TC-AUTH-03 | A          | Login      | 1\. Buka   | Sistem     | Sed |
|            | utentikasi | dengan     | halaman    | menampilka | ang |
|            |            | format     | login 2.   |            |     |
|            |            | email      |            | n validasi |     |
|            |            | tidak      | Masukkan   | dan tidak  |     |
|            |            | valid      |            | mengirim   |     |
|            |            |            | email      | permintaan |     |
|            |            |            | tanpa      | ke backend |     |
|            |            |            | simbol "@" |            |     |
|            |            |            | 3. Tekan   |            |     |
|            |            |            | tombol     |            |     |
|            |            |            |            |            |     |
|            |            |            | Masuk      |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-AUTH-04 | A          | Login      | 1\. Buka   | Sistem     | Tin |
|            | utentikasi | dengan     | halaman    | menampilka | ggi |
|            |            | kata sandi | login 2.   | n pesan    |     |
|            |            | salah      |            | "Email     |     |
|            |            |            | Masukkan   | atau       |     |
|            |            |            |            | password   |     |
|            |            |            | email      | salah"     |     |
|            |            |            | valid,     | (HTTP      |     |
|            |            |            | password   |            |     |
|            |            |            | salah 3.   | 401\)      |     |
|            |            |            | Tekan      |            |     |
|            |            |            | tombol     |            |     |
|            |            |            |            |            |     |
|            |            |            | Masuk      |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-AUTH-05 | A          | Registrasi | 1\. Buka   | Akun baru  | Tin |
|            | utentikasi | akun       | halaman    | berhasil   | ggi |
|            |            | Konsumen   |            | dibuat     |     |
|            |            | baru       | Register   | (HTTP      |     |
|            |            |            |            | 201),      |     |
|            |            |            | Account 2. | token JWT  |     |
|            |            |            | Isi nama,  | di         |     |
|            |            |            | email      | terbitkan, |     |
|            |            |            | baru,      | dompet     |     |
|            |            |            | password,  | Lokal Coin |     |
|            |            |            | telepon,   | dibuat     |     |
|            |            |            | pilih      |            |     |
|            |            |            | peran      | dengan     |     |
|            |            |            | Konsumen   | saldo      |     |
|            |            |            | 3. Kirim   |            |     |
|            |            |            | formulir   | 0          |     |
+------------+------------+------------+------------+------------+-----+
| TC-AUTH-06 | A          | Registrasi | 1\. Buka   | Akun &     | Tin |
|            | utentikasi |            | halaman    | toko       | ggi |
|            |            | akun UMKM  |            |            |     |
|            |            | baru       | Register   | UMKM       |     |
|            |            |            | Account 2. |            |     |
|            |            |            | Isi data   | berhasil   |     |
|            |            |            | diri,      | dibuat     |     |
|            |            |            | pilih      | dengan     |     |
|            |            |            | peran      | status     |     |
|            |            |            | UMKM, isi  |            |     |
|            |            |            | nama &     | is_verifie |     |
|            |            |            |            | d = false  |     |
|            |            |            | kategori   |            |     |
|            |            |            | toko 3.    |            |     |
|            |            |            | Kirim      |            |     |
|            |            |            | formulir   |            |     |
+------------+------------+------------+------------+------------+-----+

+------------+------------+------------+------------+------------+-----+
| TC-AUTH-07 | A          | Registrasi | 1\. Isi    | Sistem     | Sed |
|            | utentikasi | dengan     | formulir   | menolak    | ang |
|            |            | email yang | registrasi | dan        |     |
|            |            | sudah      | dengan     | menampilka |     |
|            |            | terdaftar  | email yang | n pesan    |     |
|            |            |            | sudah ada  | validasi   |     |
|            |            |            | di         |            |     |
|            |            |            | database   | "email     |     |
|            |            |            | 2. Kirim   | sudah      |     |
|            |            |            | formulir   | digunakan" |     |
+============+============+============+============+============+=====+
| TC-AUTH-08 | A          | Lupa       | 1\. Buka   | Sistem     | Sed |
|            | utentikasi | password   | halaman    | m          | ang |
|            |            | --- kirim  |            | engirimkan |     |
|            |            | tautan     | "Lupa      | email      |     |
|            |            | reset      |            | berisi     |     |
|            |            |            | Password"  | tautan     |     |
|            |            |            | 2.         | reset      |     |
|            |            |            | Masukkan   | password   |     |
|            |            |            | email      |            |     |
|            |            |            | terdaftar  |            |     |
|            |            |            | 3. Kirim   |            |     |
|            |            |            | permintaan |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-AUTH-09 | A          | Logout     | 1\. Login  | Token JWT  | Sed |
|            | utentikasi | pengguna   |            |            | ang |
|            |            |            | dengan     | di         |     |
|            |            |            | akun valid | invalidasi |     |
|            |            |            | 2.         | dan        |     |
|            |            |            |            | pengguna   |     |
|            |            |            | Tekan      | diarahkan  |     |
|            |            |            | tombol     | kembali ke |     |
|            |            |            | Logout     | halaman    |     |
|            |            |            |            | login      |     |
+------------+------------+------------+------------+------------+-----+
| TC-NAV-01  | Navigasi   | Akses      | 1\. Login  | Katalog    | Tin |
|            |            | halaman    |            | produk dan | ggi |
|            |            | utama      | dengan     | banner     |     |
|            |            | setelah    | akun       | d          |     |
|            |            | login      | Konsumen   | itampilkan |     |
|            |            |            | 2. Amati   | tanpa      |     |
|            |            |            | halaman    | error      |     |
|            |            |            |            |            |     |
|            |            |            | Home       |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-NAV-02  | Navigasi   | Berpindah  | 1\. Dari   | Peta       | Sed |
|            |            | ke halaman | Home,      |            | ang |
|            |            | Peta       | tekan menu | interaktif |     |
|            |            |            | "Peta      |            |     |
|            |            | Pasar      | Pasar"     | menampilka |     |
|            |            |            |            | n lokasi   |     |
|            |            |            |            |            |     |
|            |            |            |            | UMKM       |     |
|            |            |            |            |            |     |
|            |            |            |            | terdekat   |     |
+------------+------------+------------+------------+------------+-----+
| TC-NAV-03  | Navigasi   | Berpindah  | 1\. Dari   | Halaman    | Sed |
|            |            | ke halaman | Home,      | keranjang  | ang |
|            |            | Keranjang  | tekan ikon | belanja    |     |
|            |            |            | Keranjang  | d          |     |
|            |            |            |            | itampilkan |     |
+------------+------------+------------+------------+------------+-----+
| TC-NAV-04  | Navigasi   | Berpindah  | 1\. Dari   | Saldo dan  | Sed |
|            |            | ke         | menu       |            | ang |
+------------+------------+------------+------------+------------+-----+

+------------+------------+------------+------------+------------+-----+
|            |            | halaman    | profil,    | riwayat    |     |
|            |            | Wallet     | tekan      | Lokal Coin |     |
|            |            |            | "Lokal     | d          |     |
|            |            |            | Coin /     | itampilkan |     |
|            |            |            |            |            |     |
|            |            |            | Wallet"    |            |     |
+============+============+============+============+============+=====+
| TC-PROD-01 | Produk     | Menampilka | 1\. Buka   | Produk     | Tin |
|            |            |            | halaman    | aktif      | ggi |
|            |            | n daftar   | Home 2.    | d          |     |
|            |            | produk     | Amati      | itampilkan |     |
|            |            |            | daftar     | lengkap    |     |
|            |            |            | produk     | dengan     |     |
|            |            |            |            | harga dan  |     |
|            |            |            |            | gambar     |     |
+------------+------------+------------+------------+------------+-----+
| TC-PROD-02 | Produk     | Pencarian  | 1\. Buka   | Produk     | Sed |
|            |            | produk     | fitur      | relevan    | ang |
|            |            | b          | pencarian  | d          |     |
|            |            | erdasarkan | 2. Ketik   | itampilkan |     |
|            |            | kata kunci | nama       |            |     |
|            |            |            | produk     | sesuai     |     |
|            |            |            | yang ada,  | kata kunci |     |
|            |            |            | mis.       |            |     |
|            |            |            | "Bakso" 3. |            |     |
|            |            |            |            |            |     |
|            |            |            | Tekan cari |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-PROD-03 | Produk     | UMKM       | 1\. Login  | Produk     | Tin |
|            |            | menambahk  | sebagai    | baru       | ggi |
|            |            |            | UMKM 2.    | tersimpan  |     |
|            |            | an produk  |            | dan tampil |     |
|            |            | baru       | Buka       | pada       |     |
|            |            |            |            | katalog    |     |
|            |            |            | "Manajemen | toko       |     |
|            |            |            |            |            |     |
|            |            |            | Produk" →  |            |     |
|            |            |            |            |            |     |
|            |            |            | "Tambah    |            |     |
|            |            |            |            |            |     |
|            |            |            | Produk" 3. |            |     |
|            |            |            | Isi data & |            |     |
|            |            |            | unggah     |            |     |
|            |            |            | gambar 4.  |            |     |
|            |            |            |            |            |     |
|            |            |            | Simpan     |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-PROD-04 | Produk     | Konsumen   | 1\. Login  | Sistem     | Tin |
|            |            |            | sebagai    | menolak    | ggi |
|            |            | tidak      | Konsumen   | dengan     |     |
|            |            | dapat      | 2. Kirim   | status 403 |     |
|            |            |            | permintaan |            |     |
|            |            | menambahk  | POST ke    | Forbidden  |     |
|            |            | an produk  | endpoint   |            |     |
|            |            |            | tambah     |            |     |
|            |            |            | produk     |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-PROD-05 | Produk     | UMKM       | 1\. Login  | Produk     | Sed |
|            |            |            | sebagai    | terhapus   | ang |
|            |            | menghapus  |            | dari       |     |
|            |            | produk     | UMKM 2.    | katalog    |     |
|            |            | miliknya   |            | toko       |     |
|            |            |            | Pilih      |            |     |
|            |            |            | produk     |            |     |
|            |            |            | milik      |            |     |
|            |            |            | sendiri    |            |     |
|            |            |            |            |            |     |
|            |            |            | 3\. Tekan  |            |     |
|            |            |            |            |            |     |
|            |            |            | Hapus      |            |     |
+------------+------------+------------+------------+------------+-----+

+------------+------------+------------+------------+------------+-----+
| TC-CART-01 | Keranjang  | Menambahk  | 1\. Login  | Produk     | Tin |
|            |            |            | sebagai    | tampil di  | ggi |
|            |            | an produk  |            | halaman    |     |
|            |            | ke         | Konsumen   | Keranjang  |     |
|            |            | keranjang  | 2. Buka    | dengan     |     |
|            |            |            | detail     | kuantitas  |     |
|            |            |            | produk 3.  | 1          |     |
|            |            |            | Tekan      |            |     |
|            |            |            |            |            |     |
|            |            |            | "Tambah ke |            |     |
|            |            |            |            |            |     |
|            |            |            | Keranjang" |            |     |
+============+============+============+============+============+=====+
| TC-CART-02 | Keranjang  | Mengubah   | 1\. Buka   | Subtotal   | Sed |
|            |            | kuantitas  | halaman    | keranjang  | ang |
|            |            | item di    |            | diperbarui |     |
|            |            | keranjang  | Keranjang  | sesuai     |     |
|            |            |            | 2. Ubah    | kuantitas  |     |
|            |            |            | kuantitas  | baru       |     |
|            |            |            | item       |            |     |
|            |            |            | menjadi    |            |     |
|            |            |            |            |            |     |
|            |            |            | 3          |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-CART-03 | Keranjang  | Menghapus  | 1\. Buka   | Item       | Sed |
|            |            |            | halaman    | terhapus   | ang |
|            |            | item dari  |            | dan        |     |
|            |            | keranjang  | Keranjang  | subtotal   |     |
|            |            |            | 2. Tekan   | diperbarui |     |
|            |            |            | hapus pada |            |     |
|            |            |            | salah satu |            |     |
|            |            |            | item       |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-CHK-01  | Checkout   | Checkout   | 1\. Isi    | Pesanan    | Tin |
|            |            | dengan     |            | tercipta   | ggi |
|            |            | pembayaran | keranjang  | berstatus  |     |
|            |            | Midtrans   | 2.         | "menunggu  |     |
|            |            |            |            |            |     |
|            |            | (sandbox)  | Tekan      | p          |     |
|            |            |            |            | embayaran" |     |
|            |            |            | Checkout   |            |     |
|            |            |            | 3.         | , lalu     |     |
|            |            |            |            |            |     |
|            |            |            | Pilih      | berubah    |     |
|            |            |            | alamat &   | menjadi    |     |
|            |            |            | metode     | "diproses" |     |
|            |            |            | pembayaran | setelah    |     |
|            |            |            |            |            |     |
|            |            |            | (          | webhook    |     |
|            |            |            | GoPay/QRIS | diterima   |     |
|            |            |            |            |            |     |
|            |            |            | ) 4.       |            |     |
|            |            |            |            |            |     |
|            |            |            | Selesaikan |            |     |
|            |            |            | pembayaran |            |     |
|            |            |            | sandbox    |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-CHK-02  | Checkout   | Checkout   | 1\.        | Potongan   | Tin |
|            |            | menggunaka | Pastikan   | harga      | ggi |
|            |            | n potongan | saldo koin |            |     |
|            |            | Lokal Coin | mencukupi  | diterapkan |     |
|            |            |            | 2. Saat    | maksimum   |     |
|            |            |            | checkout,  | 20% dari   |     |
|            |            |            | aktifkan   | subtotal   |     |
|            |            |            | opsi       | dan saldo  |     |
|            |            |            |            | koin       |     |
|            |            |            | "Gunakan   | berkurang  |     |
|            |            |            |            |            |     |
|            |            |            | Lokal      | sesuai     |     |
|            |            |            | Coin" 3.   | nilai      |     |
|            |            |            | Selesaikan | potongan   |     |
|            |            |            | pesanan    |            |     |
+------------+------------+------------+------------+------------+-----+

+----------+-----------+------------+------------+------------+------+
| T        | Checkout  | Checkout   | 1\.        | Sistem     | Se   |
| C-CHK-03 |           | dengan     | Kosongkan  | mencegah   | dang |
|          |           | keranjang  | keranjang  | proses     |      |
|          |           | kosong     | 2. Coba    | checkout   |      |
|          |           |            | tekan      | dan        |      |
|          |           |            | tombol     | menampilka |      |
|          |           |            | Checkout   | n pesan    |      |
|          |           |            |            | bahwa      |      |
|          |           |            |            | keranjang  |      |
|          |           |            |            | kosong     |      |
+==========+===========+============+============+============+======+
| T        | Pesanan   | Melihat    | 1\. Login  | Daftar     | Se   |
| C-ORD-01 |           | riwayat    | sebagai    | pesanan    | dang |
|          |           | pesanan    |            | yang       |      |
|          |           |            | Konsumen   | pernah     |      |
|          |           |            | 2.         | dibuat     |      |
|          |           |            |            | d          |      |
|          |           |            | Buka menu  | itampilkan |      |
|          |           |            |            |            |      |
|          |           |            | "Pesanan   |            |      |
|          |           |            |            |            |      |
|          |           |            | Saya"      |            |      |
+----------+-----------+------------+------------+------------+------+
| T        | Pesanan   | Melacak    | 1\. Buka   | Status dan | Ti   |
| C-ORD-02 |           | status     | detail     | riwayat    | nggi |
|          |           | pesanan    | pesanan 2. | tracking   |      |
|          |           | (order     | Amati      | d          |      |
|          |           | tracking)  | linimasa   | itampilkan |      |
|          |           |            | status     | berurutan  |      |
|          |           |            |            | sesuai     |      |
|          |           |            |            | waktu      |      |
|          |           |            |            | kejadian   |      |
+----------+-----------+------------+------------+------------+------+
| T        | Pesanan   | Membatalka | 1.  Buka   | Status     | Se   |
| C-ORD-03 |           | n pesanan  |            | pesanan    | dang |
|          |           | sebelum    |    pesanan | berubah    |      |
|          |           | diproses   |            | menjadi    |      |
|          |           |            |  berstatus | "d         |      |
|          |           |            |            | ibatalkan" |      |
|          |           |            |  "menunggu |            |      |
|          |           |            |     p      |            |      |
|          |           |            | embayaran" |            |      |
|          |           |            |            |            |      |
|          |           |            | 2.  Tekan  |            |      |
|          |           |            |            |            |      |
|          |           |            | "Batalkan  |            |      |
|          |           |            |            |            |      |
|          |           |            | Pesanan"   |            |      |
+----------+-----------+------------+------------+------------+------+
| T        | Pesanan   | UMKM       | 1\. Login  | Status     | Ti   |
| C-ORD-04 |           |            | sebagai    | pesanan    | nggi |
|          |           | memperbaru | UMKM 2.    | berubah    |      |
|          |           |            |            | dan        |      |
|          |           | i status   | Buka       | notifikasi |      |
|          |           |            | "Pesanan   | terkirim   |      |
|          |           | pesanan    | Toko" 3.   | ke         |      |
|          |           |            | Ubah       |            |      |
|          |           |            | status     | Konsumen   |      |
|          |           |            | menjadi    |            |      |
|          |           |            | "Dikirim"  |            |      |
+----------+-----------+------------+------------+------------+------+
| T        | Pesanan   | Konsumen   | 1\. Buka   | Status     | Se   |
| C-ORD-05 |           | konfirmasi | pesanan    | pesanan    | dang |
|          |           | pesanan    | berstatus  | berubah    |      |
|          |           | diterima   |            | menjadi    |      |
|          |           |            | "dikirim"  |            |      |
|          |           |            | 2.         |            |      |
+----------+-----------+------------+------------+------------+------+

+------------+------------+------------+------------+------------+-----+
|            |            |            | Tekan      | "selesai"  |     |
|            |            |            |            | dan        |     |
|            |            |            | "          | d          |     |
|            |            |            | Konfirmasi | elivered\_ |     |
|            |            |            |            |            |     |
|            |            |            | Diterima"  | at         |     |
|            |            |            |            | tercatat   |     |
+============+============+============+============+============+=====+
| TC-COIN-01 | Lokal Coin | Melihat    | 1\. Login  | Saldo dan  | Sed |
|            |            | saldo dan  | sebagai    | daftar     | ang |
|            |            | riwayat    |            | riwayat    |     |
|            |            | Lokal Coin | Konsumen   | transaksi  |     |
|            |            |            | 2.         | koin       |     |
|            |            |            |            | d          |     |
|            |            |            | Buka menu  | itampilkan |     |
|            |            |            |            |            |     |
|            |            |            | Wallet     |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-COIN-02 | Lokal Coin | P          | 1\.        | Potongan = | Tin |
|            |            | erhitungan |            | min(20% ×  | ggi |
|            |            | potongan   | S          |            |     |
|            |            | maksimum   | imulasikan | 100.000,   |     |
|            |            | koin       | subtotal   |            |     |
|            |            |            | Rp100.000  | 15.000 ×   |     |
|            |            |            | dengan     | 10)        |     |
|            |            |            | saldo koin |            |     |
|            |            |            | 15.000 2.  | = Rp20.000 |     |
|            |            |            | Hitung     |            |     |
|            |            |            | potongan   |            |     |
|            |            |            |            |            |     |
|            |            |            | maksimum   |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-REV-01  | Ulasan     | Konsumen   | 1\. Buka   | Ulasan     | Sed |
|            |            | memberikan | pesanan    | tersimpan  | ang |
|            |            |            | berstatus  | dan tampil |     |
|            |            | ulasan     |            | pada       |     |
|            |            | produk     | "selesai"  | halaman    |     |
|            |            |            | 2.         | detail     |     |
|            |            |            |            | produk     |     |
|            |            |            | Tekan      |            |     |
|            |            |            | "Beri      |            |     |
|            |            |            | Ulasan" 3. |            |     |
|            |            |            | Isi rating |            |     |
|            |            |            | & komentar |            |     |
|            |            |            | 4.         |            |     |
|            |            |            |            |            |     |
|            |            |            | Kirim      |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-REV-02  | Ulasan     | Konsumen   | 1\. Buka   | Ulasan     | Ren |
|            |            | menghapus  |            | terhapus   | dah |
|            |            | ulasan     | "Ulasan    | dari       |     |
|            |            | miliknya   |            | daftar     |     |
|            |            |            | Saya" 2.   |            |     |
|            |            |            | Pilih      |            |     |
|            |            |            | ulasan 3.  |            |     |
|            |            |            |            |            |     |
|            |            |            | Tekan      |            |     |
|            |            |            | Hapus      |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-DASH-01 | Dashboard  | Melihat    | 1\. Login  | Total      | Sed |
|            |            | ringkasan  | sebagai    | p          | ang |
|            | UMKM       | performa   | UMKM 2.    | endapatan, |     |
|            |            | penjualan  |            | jumlah     |     |
|            |            |            | Buka       | pesanan,   |     |
|            |            |            |            | dan        |     |
|            |            |            | "Dashboard |            |     |
|            |            |            |            | produk     |     |
|            |            |            | Analitik"  | terlaris   |     |
|            |            |            |            |            |     |
|            |            |            |            | d          |     |
|            |            |            |            | itampilkan |     |
+------------+------------+------------+------------+------------+-----+
| T          | Notifikasi | Menampilka | 1\. Login  | Notifikasi | Ren |
| C-NOTIF-01 |            | n daftar   | 2.         | terkait    | dah |
|            |            | notifikasi |            |            |     |
|            |            |            | Buka menu  | pesanan/pe |     |
|            |            |            |            |            |     |
|            |            |            | Notifikasi |            |     |
+------------+------------+------------+------------+------------+-----+

+------------+------------+------------+------------+------------+-----+
|            |            |            |            | mbayaran   |     |
|            |            |            |            | d          |     |
|            |            |            |            | itampilkan |     |
+============+============+============+============+============+=====+
| T          | Notifikasi | Menandai   | 1\. Buka   | Status     | Ren |
| C-NOTIF-02 |            |            | daftar     | notifikasi | dah |
|            |            | notifikasi | notifikasi | berubah    |     |
|            |            | sebagai    | 2. Tekan   | menjadi    |     |
|            |            | dibaca     | salah satu | "dibaca"   |     |
|            |            |            | notifikasi |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-ADM-01  | Admin      | Login ke   | 1\. Buka   | Admin      | Tin |
|            |            | panel      |            |            | ggi |
|            |            | Ad         | /admin/log | berhasil   |     |
|            |            | ministrato | in 2.      | login dan  |     |
|            |            | r          |            | diarahkan  |     |
|            |            |            | Masukkan   | ke         |     |
|            |            |            | kredensial | dashboard  |     |
|            |            |            | admin 3.   | admin      |     |
|            |            |            |            |            |     |
|            |            |            | Tekan      |            |     |
|            |            |            | Masuk      |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-ADM-02  | Admin      | Verifikasi | 1\. Login  | Status     | Tin |
|            |            | p          | sebagai    |            | ggi |
|            |            | endaftaran | admin 2.   | is_verifie |     |
|            |            |            | Buka       | d UMKM     |     |
|            |            | UMKM baru  | daftar     |            |     |
|            |            |            |            | berubah    |     |
|            |            |            | UMKM       | menjadi    |     |
|            |            |            |            | true       |     |
|            |            |            | belum      |            |     |
|            |            |            |            |            |     |
|            |            |            | ter        |            |     |
|            |            |            | verifikasi |            |     |
|            |            |            | 3. Tekan   |            |     |
|            |            |            |            |            |     |
|            |            |            | "V         |            |     |
|            |            |            | erifikasi" |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-ADM-03  | Admin      | M          | 1\. Login  | is_active  | Sed |
|            |            | enonaktifk | sebagai    | pengguna   | ang |
|            |            | an akun    | admin 2.   | menjadi    |     |
|            |            | pengguna   | Pilih      | false;     |     |
|            |            |            | pengguna   | pengguna   |     |
|            |            |            | 3. Tekan   | tidak      |     |
|            |            |            |            | dapat      |     |
|            |            |            | "N         | login      |     |
|            |            |            | onaktifkan | kembali    |     |
|            |            |            |            |            |     |
|            |            |            | "          |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-SEC-01  | Keamanan/  | Akses      | 1\. Kirim  | Sistem     | Tin |
|            | RBAC       | endpoint   | permintaan | menolak    | ggi |
|            |            | privat     | GET ke     | dengan     |     |
|            |            | tanpa      |            | status 401 |     |
|            |            | token      | /api/cart  | U          |     |
|            |            |            | tanpa      | nauthorize |     |
|            |            |            | header     | d          |     |
|            |            |            | Au         |            |     |
|            |            |            | thorizatio |            |     |
|            |            |            | n          |            |     |
+------------+------------+------------+------------+------------+-----+
| TC-SEC-02  | Keamanan/  | Akses      | 1\. Login  | Sistem     | Tin |
|            | RBAC       | endpoint   | sebagai    | menolak    | ggi |
|            |            | admin oleh | Konsumen   | dengan     |     |
|            |            | peran non- | 2.         | status 403 |     |
|            |            |            |            |            |     |
|            |            |            | Kirim      |            |     |
+------------+------------+------------+------------+------------+-----+

##  admin permintaan Forbidden

> ke endpoint /api/admin
>
> /\*

# BAGIAN 3 --- PLAYWRIGHT AUTOMATED TEST SCRIPTS

  -----------------------------------------------------------------------
  Berkas                               Cakupan
  ------------------------------------ ----------------------------------
  tests/pages/LoginPage.ts             Page Object Model untuk halaman
                                       Login

  tests/fixtures/test-data.ts          Data uji (akun demo & data
                                       registrasi)

  tests/01-login.spec.ts               TC-AUTH-01 s/d TC-AUTH-04 ---
                                       Login flow (UI)

  tests/02-navigation.spec.ts          TC-NAV-01 s/d TC-NAV-04 ---
                                       Navigasi antar halaman utama

  tests/03-api-integration.spec.ts     TC-API-01 s/d TC-API-11 ---
                                       Pengujian integrasi REST API
                                       (login, registrasi, produk, cart,
                                       wallet, RBAC)

  tests/04-register-form.spec.ts       TC-REG-01 s/d TC-REG-02 --- Form
                                       input registrasi

  playwright.config.ts                 Konfigurasi eksekusi pengujian
                                       (browser, base URL, reporter)
  -----------------------------------------------------------------------

> Skrip pengujian otomatis (TypeScript) tersedia pada folder
> qa-testing/tests/ yang menyertai laporan ini, terdiri atas:

**Contoh cuplikan skrip --- Login Flow (tests/01-login.spec.ts) import**
{ test, expect } **from** \'@playwright/test\'; **import** { LoginPage }
**from** \'./pages/LoginPage\'; **import** { loginTestData } **from**
\'./fixtures/test-data\';

test(\'TC-AUTH-01: Konsumen berhasil login dengan kredensial valid\',
**async** ({ page }) **=\>** {

**const** loginPage = **new** LoginPage(page); **await**
loginPage.open();

**await** loginPage.fillCredentials(loginTestData.consumer.email,
loginTestData.consumer.password); **await** loginPage.submit();

**await** expect(page).toHaveURL(/\\/main\|\\/home\|\\/admin/); });

**Contoh cuplikan skrip --- Checkout/API Submit
(tests/03-api-integration.spec.ts)** test(\'TC-API-08: Konsumen dapat
menambahkan produk ke keranjang\', **async** ({ request }) **=\>** {

**const** loginRes = **await**
request.post(\`\${apiBaseUrl}/auth/login\`, { data: { email:
loginTestData.consumer.email, password: loginTestData.consumer.password
},

}); **const** { data } = **await** loginRes.json();

**const** cartRes = **await** request.post(\`\${apiBaseUrl}/cart\`, {
headers: { Authorization: \`Bearer \${data.token}\` }, data: {
product_id: 1, quantity: 1 },

});

expect(cartRes.ok()).toBeTruthy(); });

**Cara Menjalankan** npm install

npx playwright install \--with-deps

npx playwright test *\# jalankan seluruh skrip* npx playwright test
01-login *\# jalankan skrip login saja* npx playwright show-report *\#
lihat laporan HTML*
