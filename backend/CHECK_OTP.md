# 🔍 Cara Melihat Kode OTP

## 1️⃣ Dari Response API (Paling Mudah - Development Mode)

Saat request OTP dari Flutter, response akan menampilkan kode OTP:

```json
{
  "success": true,
  "message": "OTP berhasil dikirim. Berlaku 5 menit.",
  "phone_number": "628xxxxxxxxx",
  "debug_otp": "123456"  ← KODE OTP ADA DI SINI!
}
```

**Cara**: Buka Postman → POST `/api/v1/auth/request-otp` → lihat response section

---

## 2️⃣ Dari Database MySQL

### Via Adminer/PhpMyAdmin:
```sql
SELECT phone_number, code, expires_at, attempts, is_verified
FROM otp_codes
ORDER BY created_at DESC
LIMIT 5;
```

### Via Terminal Laravel (Tinker):
```bash
php artisan tinker

# Lihat OTP terakhir
OtpCode::latest()->first();

# Lihat OTP untuk nomor tertentu
OtpCode::where('phone_number', '6281234567890')->latest()->first();
```

---

## 3️⃣ Dari Log File

```bash
# Linux/Mac
tail -f storage/logs/laravel.log

# Windows PowerShell
Get-Content storage/logs/laravel.log -Tail 20 -Wait
```

---

## 4️⃣ Dari Browser Console (Flutter/API Testing)

```dart
// Di Flutter, setelah request OTP:
print('Response: $response');
print('OTP Code (Debug): ${response['debug_otp']}');
```

---

## ✅ Checklist Debugging

- [ ] Backend running: `php artisan serve` → running di `http://127.0.0.1:8000`
- [ ] Database connected: Check `.env` MYSQL credentials
- [ ] OTP migrations sudah jalan: `php artisan migrate`
- [ ] Cek response dari API dengan Postman
- [ ] Lihat di database jika OTP tersimpan

---

## 🔧 Jika Masih Error

### Error: "Nomor telepon harus diisi"
```bash
# 1. Check request validation di RequestOtpRequest
php artisan route:list | grep request-otp

# 2. Test dengan curl
curl -X POST http://127.0.0.1:8000/api/v1/auth/request-otp \
  -H "Content-Type: application/json" \
  -d '{"phone":"08123456789"}'
```

### Error: "OTP tidak terkirim"
```bash
# Check Twilio credentials di .env
echo "Account SID: $(grep TWILIO_ACCOUNT_SID .env)"
echo "Auth Token: $(grep TWILIO_AUTH_TOKEN .env)"

# Test Twilio connection
php artisan tinker
> \App\Services\AuthService::class
```

---

## 📱 Test OTP Flow

1. **Request OTP** (Postman):
   ```
   POST http://127.0.0.1:8000/api/v1/auth/request-otp
   Content-Type: application/json
   
   {
     "phone": "08123456789"
   }
   ```

2. **Copy kode OTP** dari response (`debug_otp`)

3. **Verify OTP** (Postman):
   ```
   POST http://127.0.0.1:8000/api/v1/auth/verify-otp
   Content-Type: application/json
   
   {
     "phone": "08123456789",
     "code": "123456",
     "name": "John Doe",
     "role": "consumer"
   }
   ```

4. **Dapatkan JWT Token** ✅

---
