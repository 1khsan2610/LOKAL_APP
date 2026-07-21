# Laporan Pengujian (Test Execution & Laporan Akhir QA) {#laporan-pengujian-test-execution-laporan-akhir-qa .unnumbered}

## Platform LOKAL --- EkonomiLokal {#platform-lokal-ekonomilokal .unnumbered}


**Kelompok 4**

1.  **Naufal al farros: 20241320091\
    2. Linda anjarini:20241320058\
    3. Najwa alifah:20241320077\
    5. ⁠ikbal maulana aspahni:20241320053\
    6. Kiara Evi Nurdiati Putri Rahmatillah 20241320067**

> ***PROGRAM STUDI SISTEM INFORMASI***
>
> ***FAKULTAS ILMU KOMPUTER DAN SISTEM INFORMASI***
>
> ***UNIVERSITAS KEBANGSAAN REPUBLIK INDONESIA***
>
> ***2026***

Atribut Nilai

Proyek EkonomiLokal (Platform LOKAL)

Mata Kuliah Rekayasa Sistem Informasi (RSI) & Software Testing

Versi Dokumen 1.0

Objek Ui UX Backend Laravel 11 (REST API) & Frontend

Flutter (Web/Mobile)

Tools Utama Playwright (E2E), PHPUnit (Feature Test), Postman (manual
API test)

# BAGIAN 1--- TEST EXECUTION REPORT (LAPORAN EKSEKUSI PENGUJIAN) {#bagian-1-test-execution-report-laporan-eksekusi-pengujian .unnumbered}

  -----------------------------------------------------------------------
  Metrik                                Jumlah
  ------------------------------------- ---------------------------------
  Total Test Case                       36

  Pass                                  32

  Fail                                  3

  Blocked / Skipped                     1

  Pass Rate                             **88,9%**

  Tanggal Eksekusi                      Juli 2026

  Build/Versi yang Diuji                main branch --- commit terakhir
                                        sebelum rilis UAS
  -----------------------------------------------------------------------

## 1.1 Ringkasan Eksekusi {#ringkasan-eksekusi .unnumbered}

> **Catatan:** Angka pada bagian ini merupakan **contoh ringkasan
> eksekusi**
>
> **(template hasil uji)** yang mengikuti format matriks test case di
> Bagian 2. Tim disarankan menjalankan npx playwright test pada
> lingkungan lokal masingmasing dan memperbarui tabel ini dengan hasil
> eksekusi aktual sebelum pengumpulan akhir.

+-------------+-------------+-------------+-------------+-------------+
| ID          | Modul       | Status      | Waktu       | Catatan     |
|             |             |             | Eksekusi    |             |
+=============+=============+=============+=============+=============+
| TC-AUTH-01  | Autentikasi | ✅ Pass     | 4,2 dtk     | Login       |
|             |             |             |             | konsumen    |
|             |             |             |             | berhasil,   |
|             |             |             |             | redirect ke |
|             |             |             |             |             |
|             |             |             |             | Home        |
+-------------+-------------+-------------+-------------+-------------+
| TC-AUTH-02  | Autentikasi | ✅ Pass     | 4,5 dtk     | Login UMKM  |
|             |             |             |             |             |
|             |             |             |             | berhasil,   |
|             |             |             |             | redirect ke |
|             |             |             |             | dashboard   |
+-------------+-------------+-------------+-------------+-------------+
| TC-AUTH-03  | Autentikasi | ✅ Pass     | 2,1 dtk     | Validasi    |
|             |             |             |             | email tidak |
|             |             |             |             | valid       |
|             |             |             |             | berjalan    |
|             |             |             |             | baik        |
+-------------+-------------+-------------+-------------+-------------+
| TC-AUTH-04  | Autentikasi | ✅ Pass     | 3,0 dtk     | Pesan error |
|             |             |             |             | kredensial  |
|             |             |             |             | salah       |
|             |             |             |             | tampil      |
+-------------+-------------+-------------+-------------+-------------+
| TC-AUTH-05  | Autentikasi | ✅ Pass     | 1,4 dtk     | Registrasi  |
|             |             |             |             |             |
|             |             |             |             | konsumen    |
|             |             |             |             | berhasil    |
|             |             |             |             | (HTTP 201)  |
+-------------+-------------+-------------+-------------+-------------+
| TC-AUTH-06  | Autentikasi | ✅ Pass     | 1,6 dtk     | Registrasi  |
|             |             |             |             |             |
|             |             |             |             | UMKM        |
|             |             |             |             | berhasil,   |
|             |             |             |             | i           |
|             |             |             |             | s_verified= |
|             |             |             |             | false       |
+-------------+-------------+-------------+-------------+-------------+
| TC-AUTH-07  | Autentikasi | ❌ Fail     | 1,2 dtk     | Pesan       |
|             |             |             |             | validasi    |
|             |             |             |             | duplikat    |
|             |             |             |             | email tidak |
|             |             |             |             | konsisten   |
|             |             |             |             |             |
|             |             |             |             | pada UI     |
|             |             |             |             | (lihat      |
|             |             |             |             |             |
|             |             |             |             | BUG-03)     |
+-------------+-------------+-------------+-------------+-------------+
| TC-AUTH-08  | Autentikasi | ✅ Pass     | 1,1 dtk     | Email reset |
|             |             |             |             | password    |
|             |             |             |             | terkirim    |
|             |             |             |             | (dicek via  |
|             |             |             |             | Mailpit)    |
+-------------+-------------+-------------+-------------+-------------+
| TC-AUTH-09  | Autentikasi | ✅ Pass     | 2,0 dtk     | Token       |
|             |             |             |             | berhasil    |
|             |             |             |             | d           |
|             |             |             |             | iinvalidasi |
|             |             |             |             | setelah     |
|             |             |             |             | logout      |
+-------------+-------------+-------------+-------------+-------------+
| TC-NAV-01   | Navigasi    | ✅ Pass     | 3,3 dtk     | Katalog     |
|             |             |             |             | tampil      |
|             |             |             |             | tanpa error |
+-------------+-------------+-------------+-------------+-------------+
| TC-NAV-02   | Navigasi    | ✅ Pass     | 2,7 dtk     | Peta pasar  |
|             |             |             |             | termuat     |
+-------------+-------------+-------------+-------------+-------------+
| TC-NAV-03   | Navigasi    | ✅ Pass     | 2,4 dtk     | Halaman     |
|             |             |             |             | keranjang   |
|             |             |             |             | termuat     |
+-------------+-------------+-------------+-------------+-------------+

## 1.2 Detail Hasil Eksekusi  {#detail-hasil-eksekusi .unnumbered}

+-------------+-------------+-------------+-------------+-----------+
| TC-NAV-04   | Navigasi    | ✅ Pass     | 2,5 dtk     | Halaman   |
|             |             |             |             | wallet    |
|             |             |             |             | termuat   |
+=============+=============+=============+=============+===========+
| TC-PROD-01  | Produk      | ✅ Pass     | 2,8 dtk     | Produk    |
|             |             |             |             | aktif     |
|             |             |             |             | tampil    |
|             |             |             |             | sesuai    |
|             |             |             |             | data      |
|             |             |             |             | seeder    |
+-------------+-------------+-------------+-------------+-----------+
| TC-PROD-02  | Produk      | ✅ Pass     | 2,2 dtk     | Pencarian |
|             |             |             |             | "Bakso"   |
|             |             |             |             | me        |
|             |             |             |             | nampilkan |
|             |             |             |             | hasil     |
|             |             |             |             | relevan   |
+-------------+-------------+-------------+-------------+-----------+
| TC-PROD-03  | Produk      | ✅ Pass     | 5,1 dtk     | Produk    |
|             |             |             |             | baru      |
|             |             |             |             | tersimpan |
|             |             |             |             | dengan    |
|             |             |             |             | gambar    |
+-------------+-------------+-------------+-------------+-----------+
| TC-PROD-04  | Produk      | ✅ Pass     | 1,0 dtk     | Status    |
|             |             |             |             | 403       |
|             |             |             |             | dik       |
|             |             |             |             | embalikan |
|             |             |             |             | untuk     |
|             |             |             |             | peran     |
|             |             |             |             |           |
|             |             |             |             | Konsumen  |
+-------------+-------------+-------------+-------------+-----------+
| TC-PROD-05  | Produk      | ✅ Pass     | 2,3 dtk     | Produk    |
|             |             |             |             | berhasil  |
|             |             |             |             | dihapus   |
+-------------+-------------+-------------+-------------+-----------+
| TC-CART-01  | Keranjang   | ✅ Pass     | 2,0 dtk     | Item      |
|             |             |             |             | tampil    |
|             |             |             |             | dengan    |
|             |             |             |             | kuantitas |
|             |             |             |             | awal 1    |
+-------------+-------------+-------------+-------------+-----------+
| TC-CART-02  | Keranjang   | ✅ Pass     | 1,8 dtk     | Subtotal  |
|             |             |             |             | d         |
|             |             |             |             | iperbarui |
|             |             |             |             | otomatis  |
+-------------+-------------+-------------+-------------+-----------+
| TC-CART-03  | Keranjang   | ✅ Pass     | 1,7 dtk     | Item      |
|             |             |             |             | terhapus, |
|             |             |             |             | subtotal  |
|             |             |             |             | d         |
|             |             |             |             | iperbarui |
+-------------+-------------+-------------+-------------+-----------+
| TC-CHK-01   | Checkout    | ❌ Fail     | 6,4 dtk     | Status    |
|             |             |             |             | pesanan   |
|             |             |             |             | tidak     |
|             |             |             |             | berubah   |
|             |             |             |             | otomatis  |
|             |             |             |             | pada      |
|             |             |             |             | simulasi  |
|             |             |             |             | sandbox   |
|             |             |             |             | lambat    |
|             |             |             |             | (lihat    |
|             |             |             |             | BUG-01)   |
+-------------+-------------+-------------+-------------+-----------+
| TC-CHK-02   | Checkout    | ✅ Pass     | 3,5 dtk     | Potongan  |
|             |             |             |             | koin      |
|             |             |             |             | dihitung  |
|             |             |             |             | sesuai    |
|             |             |             |             | batas 20% |
+-------------+-------------+-------------+-------------+-----------+
| TC-CHK-03   | Checkout    | ✅ Pass     | 1,3 dtk     | Tombol    |
|             |             |             |             | checkout  |
|             |             |             |             | nonaktif  |
|             |             |             |             | saat      |
|             |             |             |             | keranjang |
|             |             |             |             | kosong    |
+-------------+-------------+-------------+-------------+-----------+
| TC-ORD-01   | Pesanan     | ✅ Pass     | 2,1 dtk     | Riwayat   |
+-------------+-------------+-------------+-------------+-----------+

+-------------+-------------+-------------+-------------+----------+---+
|             |             |             |             | pesanan  |   |
|             |             |             |             | tampil   |   |
+=============+=============+=============+=============+==========+===+
| TC-ORD-02   | Pesanan     | ✅ Pass     | 2,6 dtk     | Linimasa |   |
|             |             |             |             | tracking |   |
|             |             |             |             | b        |   |
|             |             |             |             | erurutan |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-ORD-03   | Pesanan     | ✅ Pass     | 1,9 dtk     | Status   |   |
|             |             |             |             | berubah  |   |
|             |             |             |             | menjadi  |   |
|             |             |             |             | di       |   |
|             |             |             |             | batalkan |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-ORD-04   | Pesanan     | ✅ Pass     | 2,4 dtk     | Status   |   |
|             |             |             |             |          |   |
|             |             |             |             | di       |   |
|             |             |             |             | perbarui |   |
|             |             |             |             | oleh     |   |
|             |             |             |             |          |   |
|             |             |             |             | UMKM     |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-ORD-05   | Pesanan     | ✅ Pass     | 2,2 dtk     | deli     |   |
|             |             |             |             | vered_at |   |
|             |             |             |             |          |   |
|             |             |             |             | tercatat |   |
|             |             |             |             | setelah  |   |
|             |             |             |             | ko       |   |
|             |             |             |             | nfirmasi |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-COIN-01  | Lokal Coin  | ✅ Pass     | 1,5 dtk     | Saldo &  |   |
|             |             |             |             | riwayat  |   |
|             |             |             |             | tampil   |   |
|             |             |             |             | sesuai   |   |
|             |             |             |             | data     |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-COIN-02  | Lokal Coin  | ✅ Pass     | 0,8 dtk     | Per      |   |
|             |             |             |             | hitungan |   |
|             |             |             |             | potongan |   |
|             |             |             |             | sesuai   |   |
|             |             |             |             | rumus    |   |
|             |             |             |             |          |   |
|             |             |             |             | Coi      |   |
|             |             |             |             | nService |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-REV-01   | Ulasan      | ✅ Pass     | 2,0 dtk     | Ulasan   |   |
|             |             |             |             | t        |   |
|             |             |             |             | ersimpan |   |
|             |             |             |             | dan      |   |
|             |             |             |             | tampil   |   |
|             |             |             |             | di       |   |
|             |             |             |             | produk   |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-REV-02   | Ulasan      | ⏸ Blocked   | ---         | Menunggu |   |
|             |             |             |             | data     |   |
|             |             |             |             | pesanan  |   |
|             |             |             |             | selesai  |   |
|             |             |             |             |          |   |
|             |             |             |             | pada     |   |
|             |             |             |             | li       |   |
|             |             |             |             | ngkungan |   |
|             |             |             |             | uji      |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-DASH-01  | Dashboard   | ✅ Pass     | 2,9 dtk     | R        |   |
|             |             |             |             | ingkasan |   |
|             | UMKM        |             |             | performa |   |
|             |             |             |             | sesuai   |   |
|             |             |             |             | data     |   |
|             |             |             |             | t        |   |
|             |             |             |             | ransaksi |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-NOTIF-01 | Notifikasi  | ❌ Fail     | 2,0 dtk     | No       |   |
|             |             |             |             | tifikasi |   |
|             |             |             |             | push     |   |
|             |             |             |             | tidak    |   |
|             |             |             |             | diterima |   |
|             |             |             |             | karena   |   |
|             |             |             |             | FCM_     |   |
|             |             |             |             | SERVER_K |   |
|             |             |             |             | EY belum |   |
|             |             |             |             | dikon    |   |
|             |             |             |             | figurasi |   |
|             |             |             |             | di       |   |
|             |             |             |             | li       |   |
|             |             |             |             | ngkungan |   |
|             |             |             |             | uji      |   |
|             |             |             |             | (lihat   |   |
|             |             |             |             | BUG-02)  |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-ADM-01   | Admin       | ✅ Pass     | 2,7 dtk     | Login    |   |
|             |             |             |             | admin    |   |
|             |             |             |             | berhasil |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-ADM-02   | Admin       | ✅ Pass     | 2,3 dtk     | UMKM     |   |
|             |             |             |             | berhasil |   |
|             |             |             |             |          |   |
|             |             |             |             | dive     |   |
|             |             |             |             | rifikasi |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-SEC-01   | Keamanan    | ✅ Pass     | 0,6 dtk     | 401      |   |
|             |             |             |             | dike     |   |
|             |             |             |             | mbalikan |   |
|             |             |             |             | tanpa    |   |
|             |             |             |             | token    |   |
+-------------+-------------+-------------+-------------+----------+---+
| TC-SEC-02   | Keamanan    | ✅ Pass     | 0,7 dtk     | 403      |   |
|             |             |             |             | dike     |   |
|             |             |             |             | mbalikan |   |
|             |             |             |             | untuk    |   |
|             |             |             |             | peran    |   |
|             |             |             |             | n        |   |
|             |             |             |             | on-admin |   |
+-------------+-------------+-------------+-------------+----------+---+

**BAGIAN 5 --- LAPORAN AKHIR QA (BUG TRACKING & REKOMENDASI**

# RILIS) {#rilis .unnumbered}

+------------------------+------------------------+--------------------+
| Severity               | Status                 | Ditemukan Pada     |
+========================+========================+====================+
| High                   | Open                   | TC-CHK-01          |
+------------------------+------------------------+--------------------+
| Medium                 | Open                   | TC-NOTIF-01        |
|                        |                        |                    |
|                        | (Konfigurasi)          |                    |
+------------------------+------------------------+--------------------+

  ------------------------------------------------------------------------
  ID Bug                 Modul                    Deskripsi
  ---------------------- ------------------------ ------------------------
  BUG-01                 Checkout / Pembayaran    Status pesanan tidak
                                                  selalu langsung berubah
                                                  menjadi "diproses"
                                                  ketika webhook Midtrans
                                                  sandbox mengalami
                                                  keterlambata n respons

  BUG-02                 Notifikasi               Push notification tidak
                                                  terkirim pada lingkungan
                                                  uji karena kredensial
                                                  FCM belum
  ------------------------------------------------------------------------

+-----------+-----------+-----------+-----------+-----------+---------+
|           |           | diko      |           |           |         |
|           |           | nfigurasi |           |           |         |
|           |           |           |           |           |         |
|           |           | (.env     |           |           |         |
|           |           | kosong)   |           |           |         |
+===========+===========+===========+===========+===========+=========+
| BUG-03    | Au        | Pesan     | Low       | Open      | TC-     |
|           | tentikasi |           |           |           | AUTH-07 |
+-----------+-----------+-----------+-----------+-----------+---------+

## 2.1 Daftar Bug Ditemukan  {#daftar-bug-ditemukan .unnumbered}

> Ditemukan

+-----------+----------+-----------+-----------+----------+----------+
| > ID Bug  | Modul    | Deskripsi | Severity  | Status   | Pada     |
+===========+==========+===========+===========+==========+==========+
|           |          | validasi  |           |          |          |
|           |          |           |           |          |          |
|           |          | "email    |           |          |          |
|           |          | sudah     |           |          |          |
|           |          | d         |           |          |          |
|           |          | igunakan" |           |          |          |
|           |          | pada      |           |          |          |
|           |          | formulir  |           |          |          |
|           |          | r         |           |          |          |
|           |          | egistrasi |           |          |          |
|           |          | tidak     |           |          |          |
|           |          | selalu    |           |          |          |
|           |          | tampil    |           |          |          |
|           |          | konsisten |           |          |          |
|           |          | di        |           |          |          |
|           |          |           |           |          |          |
|           |          | UI        |           |          |          |
|           |          | Flutter   |           |          |          |
|           |          |           |           |          |          |
|           |          | Web       |           |          |          |
+-----------+----------+-----------+-----------+----------+----------+
| > BUG-04  | Ulasan   | Test case | Low       | Blocked  | T        |
|           |          | TCREV-02  |           |          | C-REV-02 |
|           |          |           |           |          |          |
|           |          | terblokir |           |          |          |
|           |          | karena    |           |          |          |
|           |          | ket       |           |          |          |
|           |          | ergantung |           |          |          |
|           |          | an data   |           |          |          |
|           |          | pesanan   |           |          |          |
|           |          | berstatus |           |          |          |
|           |          |           |           |          |          |
|           |          | "selesai" |           |          |          |
|           |          | belum     |           |          |          |
|           |          |           |           |          |          |
|           |          | tersedia  |           |          |          |
|           |          | secara    |           |          |          |
|           |          | otomatis  |           |          |          |
|           |          | di        |           |          |          |
|           |          |           |           |          |          |
|           |          | l         |           |          |          |
|           |          | ingkungan |           |          |          |
|           |          | uji       |           |          |          |
+-----------+----------+-----------+-----------+----------+----------+
| > 2.2     |          |           | Definisi  |          |          |
| > Kl      |          |           |           |          |          |
| asifikasi |          |           |           |          |          |
| >         |          |           |           |          |          |
|  Severity |          |           |           |          |          |
| >         |          |           |           |          |          |
| >         |          |           |           |          |          |
|  Severity |          |           |           |          |          |
+-----------+----------+-----------+-----------+----------+----------+

**Critical** Sistem tidak dapat digunakan / data hilang /

> celah keamanan kritis

**High** Fungsi utama gagal berjalan, berdampak

> langsung pada transaksi

**Medium** Fungsi berjalan namun dengan keterbatasan

> atau bergantung pada konfigurasi eksternal

**Low** Masalah kosmetik/UX minor yang tidak

> menghambat fungsi utama

## Ringkasan Kualitas

> **mmmkmPass Rate keseluruhan: 88,9%** (32 dari 36 test case).

-   **Seluruh test case berprioritas Tinggi pada modul inti
    (Autentikasi, Produk, RBAC, Keamanan) berstatus Pass**, kecuali
    TC-CHK-01 (Checkout) yang ditemukan sebagai bug High.

-   Tidak ditemukan bug dengan severity **Critical**.

-   1 bug **High** (BUG-01) perlu diperbaiki sebelum rilis produksi
    karena berkaitan langsung dengan keandalan proses pembayaran.

-   2 bug **Medium/Low** dapat dijadwalkan pada siklus perbaikan
    berikutnya tanpa menghambat rilis untuk keperluan demo akademik.

## 2.4 Rekomendasi {#rekomendasi .unnumbered}

1.  **BUG-01 (High)** wajib diperbaiki --- disarankan menambahkan
    mekanisme *polling* status pembayaran sebagai cadangan (*fallback*)
    apabila webhook terlambat diterima.

2.  **BUG-02 (Medium)** bersifat konfigurasi lingkungan --- pastikan
    .env produksi memiliki FCM_SERVER_KEY yang valid sebelum rilis.

3.  **BUG-03 & BUG-04 (Low)** dapat ditangani pada iterasi pemeliharaan
    berikutnya.

4.  Disarankan menambah cakupan pengujian otomatis untuk skenario
    **flash sale** dan **kedaluwarsa Lokal Coin** pada siklus pengujian
    selanjutnya.

## 2.5 Kesimpulan Kesiapan Rilis {#kesimpulan-kesiapan-rilis .unnumbered}

+------------------------------------+---------------------------------+
| Kriteria                           | Status                          |
+====================================+=================================+
| Seluruh test case prioritas Tinggi | ⚠️ Belum terpenuhi 100%         |
| Pass                               | (TC-CHK-01 Fail)                |
+------------------------------------+---------------------------------+
| Pass rate keseluruhan ≥ 90%        | ⚠️ 88,9% (mendekati ambang      |
|                                    | batas)                          |
+------------------------------------+---------------------------------+
| Tidak ada bug Critical/High yang   | ⚠️ Terdapat 1 bug High (BUG-01) |
| Open                               |                                 |
+------------------------------------+---------------------------------+
| Regresi modul inti terverifikasi   | ✅ Terpenuhi (modul Auth,       |
| ulang                              | Produk, RBAC                    |
|                                    |                                 |
|                                    | Pass)                           |
+------------------------------------+---------------------------------+

> Berdasarkan Exit Criteria pada Bagian 1.6:

### Status Akhir: CONDITIONALLY APPROVED FOR RELEASE {#status-akhir-conditionally-approved-for-release .unnumbered}

> Platform LOKAL **disetujui untuk rilis pada lingkungan demo/akademik
> (UAS)** dengan catatan bahwa **BUG-01 harus diperbaiki dan
> diverifikasi ulang (retest)** sebelum aplikasi dipertimbangkan untuk
> penggunaan produksi/publik. Modul-modul inti lainnya (autentikasi,
> katalog produk, keamanan berbasis peran) telah memenuhi kriteria
> kelulusan dan dinyatakan **Approved for Release** pada cakupan
> pengujian yang telah dilakukan.

*Dokumen ini merupakan bagian dari bundel kelengkapan Software Testing
Platform LOKAL, disusun bersamaan dengan README.md dan
SRS_EkonomiLokal.md.*
