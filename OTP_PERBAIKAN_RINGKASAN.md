# 🔧 PERBAIKAN OTP - RINGKASAN LENGKAP

## 🎯 Masalah yang Ditemukan

**Error:** "Nomor telepon harus diisi"
**Penyebab:** Flutter mengirim field `phone` tapi Laravel expect `phone_number`

---

## ✅ Perbaikan yang Dilakukan

### 1️⃣ **Flutter API Service** (`api_service.dart`)
```dart
// SEBELUM:
data: {'phone': phone}
data: {'phone': phone, 'otp': otp}

// SESUDAH:
data: {'phone_number': phone}  ✅
data: {'phone_number': phone, 'code': otp}  ✅
```

### 2️⃣ **Flutter Auth Service** (`auth_service.dart`)
```dart
// SEBELUM:
'phone': phoneNumber,
'otp': otp,

// SESUDAH:
'phone_number': phoneNumber,  ✅
'code': otp,                   ✅
'name': 'User',                ✅
'role': 'consumer',            ✅
```

### 3️⃣ **Laravel AuthService** (`AuthService.php`)
```php
// DITAMBAHKAN: Debug mode untuk show OTP di response
if (config('app.debug')) {
    $response['debug_otp'] = $code; // Untuk development only
}
```

---

## 📱 Cara Lihat Kode OTP (5 Cara)

### ✨ **CARA PALING MUDAH: Postman**

1. Buka Postman
2. **POST** → `http://127.0.0.1:8000/api/v1/auth/request-otp`
3. Headers: `Content-Type: application/json`
4. Body (JSON):
```json
{
  "phone_number": "08123456789"
}
```
5. **Send** ➜ Response menampilkan:
```json
{
  "success": true,
  "message": "OTP berhasil dikirim. Berlaku 5 menit.",
  "phone_number": "628123456789",
  "debug_otp": "123456"  ← 🔑 KODE OTP DI SINI!
}
```

---

### **CARA 2: Terminal Laravel**
- Lihat terminal tempat `php artisan serve` running
- Saat request OTP, terlihat request & response

---

### **CARA 3: Database (Adminer)**
1. Buka: `http://localhost:8080`
2. Query:
```sql
SELECT phone_number, code, created_at 
FROM otp_codes 
ORDER BY created_at DESC LIMIT 5;
```

---

### **CARA 4: Laravel Tinker**
```bash
php artisan tinker
> OtpCode::latest()->first()
```

---

### **CARA 5: Flutter Console**
```dart
// Console akan print:
// 🚀 API Response: 200 /api/v1/auth/request-otp
// Response: {debug_otp: "123456", ...}
```

---

## 🧪 Test Flow Sekarang

### **Step 1: Request OTP**
```
Input nomor: 08123456789
↓
Response dengan kode OTP
```

### **Step 2: Copy OTP dari Response**
```
Dari response: "debug_otp": "123456"
```

### **Step 3: Verify OTP**
```
Input OTP: 123456
Input nomor: 08123456789
↓
Dapat JWT token ✅
↓
Login berhasil!
```

---

## ✅ Validasi Field

| Field | Laravel | Flutter | Format |
|-------|---------|---------|--------|
| Nomor Telepon | `phone_number` | `phone_number` | `08xxx...` atau `628xxx...` |
| Kode OTP | `code` | `code` | `6 digit` |
| Role | `role` | `role` | `consumer`, `umkm`, `producer` |
| Name | `name` | `name` | Untuk new user |

---

## 📋 Checklist

- [x] Flutter API Service fixed
- [x] Flutter Auth Service fixed
- [x] Laravel Debug Mode enabled
- [x] Field names matched (phone_number, code)
- [x] Database ready
- [ ] Test OTP Flow
- [ ] Run Flutter App
- [ ] Verify Login Success

---

## 🚀 Langkah Selanjutnya

### 1. Cek Terminal Laravel
```bash
php artisan serve
# Server running on [http://127.0.0.1:8000]
```

### 2. Test dengan Postman
- POST `/api/v1/auth/request-otp`
- Lihat OTP di response
- Verify OTP success

### 3. Run Flutter App
```bash
cd "c:\project uas\frontend"
flutter run
```

### 4. Test Login di Flutter
- Input nomor HP
- Lihat OTP di Postman/Adminer
- Copy OTP ke Flutter
- Verify ✅

---

## 📞 Support

Jika masih error:
1. Check terminal Laravel untuk error messages
2. Cek database OTP_codes
3. Lihat debug_otp di response API
4. Verify field names sesuai tabel di atas

**Sekarang sudah fixed! Mari test OTP flow!** 🎉

