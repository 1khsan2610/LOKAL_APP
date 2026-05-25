# 📱 Panduan Testing OTP Flow - Platform LOKAL

## ✅ Perbaikan yang Sudah Dilakukan

1. ✅ Flutter API Service: Ubah `phone` → `phone_number`
2. ✅ Flutter Auth Service: Ubah `otp` → `code`
3. ✅ Laravel AuthService: Tambah debug mode untuk show OTP di response
4. ✅ Validasi nomor telepon dengan regex

---

## 🔍 Cara Lihat Kode OTP

### **Cara 1: Dari Response API (PALING MUDAH)**

**Menggunakan Postman:**

1. Buka Postman → Create New Request
2. Method: `POST`
3. URL: `http://127.0.0.1:8000/api/v1/auth/request-otp`
4. Tab Headers: Tambahkan `Content-Type: application/json`
5. Tab Body → Raw → JSON:
```json
{
  "phone_number": "08123456789"
}
```
6. **Send** dan lihat Response:
```json
{
  "success": true,
  "message": "OTP berhasil dikirim. Berlaku 5 menit.",
  "phone_number": "628xxxxxxxxxx",
  "debug_otp": "123456"  ← KODE OTP DI SINI! 🔑
}
```

---

### **Cara 2: Dari Terminal Laravel**

Saat request OTP, cek terminal tempat `php artisan serve` running:

```bash
[18:30:45] POST /api/v1/auth/request-otp 200
Request body: {"phone_number":"08123456789"}
Response: {"success":true,"debug_otp":"123456"}
```

---

### **Cara 3: Dari Database (Adminer/PHPMyAdmin)**

1. Buka Adminer: `http://localhost:8080`
   - Server: MySQL
   - Username: root
   - Database: lokal_db

2. Query:
```sql
SELECT phone_number, code, created_at, expires_at, attempts 
FROM otp_codes 
ORDER BY created_at DESC 
LIMIT 5;
```

3. Lihat tabel `otp_codes` untuk semua OTP yang dibuat

---

### **Cara 4: Dari Laravel Tinker (Console)**

```bash
cd your_laravel_project

# Buka Tinker
php artisan tinker

# Lihat OTP terakhir
OtpCode::latest()->first();

# Output:
# OtpCode {#xxxx
#   id: 1,
#   phone_number: "628123456789",
#   code: "123456",
#   created_at: "2026-05-13 18:30:45",
#   expires_at: "2026-05-13 18:35:45",
#   ...
# }

# Lihat semua OTP
OtpCode::all();

# Exit Tinker
exit
```

---

### **Cara 5: Dari Log File**

```bash
# Linux/Mac
tail -f storage/logs/laravel.log

# Windows (PowerShell)
Get-Content storage/logs/laravel.log -Tail 50 -Wait
```

---

## 🧪 Test OTP Flow Lengkap

### **Step 1: Request OTP**
```bash
curl -X POST http://127.0.0.1:8000/api/v1/auth/request-otp \
  -H "Content-Type: application/json" \
  -d '{"phone_number":"08123456789"}'
```

**Response:**
```json
{
  "success": true,
  "message": "OTP berhasil dikirim. Berlaku 5 menit.",
  "phone_number": "628123456789",
  "debug_otp": "123456"
}
```

### **Step 2: Copy OTP Code**
```
Kode OTP: 123456
```

### **Step 3: Verify OTP**
```bash
curl -X POST http://127.0.0.1:8000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "08123456789",
    "code": "123456",
    "name": "John Doe",
    "role": "consumer"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Verifikasi berhasil",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "phone_number": "628123456789",
    "name": "John Doe",
    "role": "consumer"
  }
}
```

✅ **LOGIN BERHASIL!**

---

## 🐛 Troubleshooting

### Error: "Nomor telepon harus diisi"
**Solusi:**
- Pastikan mengirim field `phone_number` (bukan `phone`)
- Format: `08123456789` atau `628123456789` atau `+628123456789`

### Error: "OTP tidak terkirim"
**Solusi:**
- Check Twilio credentials di `.env`
- Jalankan: `php artisan config:cache`

### Error: "OTP sudah kadaluarsa"
**Solusi:**
- OTP berlaku 5 menit, pastikan langsung verify setelah request
- Request OTP baru dan coba lagi

### Error: "Terlalu banyak percobaan"
**Solusi:**
- Tunggu 15 menit sebelum mencoba lagi
- Atau clear database: `php artisan tinker` → `OtpCode::truncate()`

---

## 📱 Testing di Flutter App

Setelah perbaikan, coba:

1. **Buka Flutter app**
2. **Login screen:**
   - Input: `08123456789`
   - Tekan: "Lanjutkan"
   - Lihat console untuk debug info

3. **OTP Verification screen:**
   - Buka Postman atau Adminer untuk lihat kode OTP
   - Copy kode OTP: `123456`
   - Paste di Flutter app
   - Tekan: "Verifikasi"

4. **Sukses:**
   - Dapat JWT token ✅
   - Auto navigate ke Home screen

---

## 🔗 Reference

| Endpoint | Method | Body | Response |
|----------|--------|------|----------|
| `/auth/request-otp` | POST | `{phone_number}` | `{success, debug_otp}` |
| `/auth/verify-otp` | POST | `{phone_number, code, name, role}` | `{success, token, user}` |
| `/auth/logout` | POST | - | `{success}` |

---

## 🎯 Status Sekarang

- ✅ Flutter API Service fixed
- ✅ Laravel API ready
- ✅ OTP debug mode enabled
- ✅ Database migrations ready
- ✅ JWT authentication ready

**Silakan test dan lihat kode OTP!** 🚀

