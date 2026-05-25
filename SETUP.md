# 🚀 LOKAL Project - Quick Start Guide

## Backend Setup (Node.js/Express)

### 1. Install Dependencies
```bash
cd "c:\project uas\backend"
npm install
```

### 2. Run Server
```bash
npm start
```

Server akan berjalan di: **http://localhost:8000**

### 3. Test API
Buka di browser: **http://localhost:8000/api-test.html**

Atau test di terminal:
```bash
# Health check
curl http://localhost:8000/api/health

# Get products
curl http://localhost:8000/api/products

# Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"08123456789","password":"test"}'
```

## Flutter Frontend Setup

### 1. Configuration sudah updated
✅ API URL: `http://localhost:8000/api`  
✅ File: `lib/config/constants.dart`

### 2. Run Flutter App
```bash
cd "c:\project uas\frontend"
flutter run
```

### 3. Backend Requirements
- Pastikan backend server running di port 8000
- Pastikan CORS enabled (sudah di-setup)
- Pastikan Android emulator/device bisa akses localhost:8000

## 📊 API Structure

```
Backend Server (http://localhost:8000)
├── /api
│   ├── /auth (login, register, verify-otp)
│   ├── /users (profile)
│   ├── /products (CRUD, search, filter)
│   ├── /umkms (list, detail, analytics)
│   ├── /orders (CRUD)
│   ├── /wallet (balance, transactions)
│   └── /notifications (list, mark-read)
├── /api-test.html (Interactive Testing Dashboard)
└── /health (Server status)
```

## 🧪 Testing Checklist

Backend:
- [ ] `npm install` berhasil
- [ ] `npm start` berjalan tanpa error
- [ ] Bisa akses http://localhost:8000/api-test.html
- [ ] Health check endpoint working
- [ ] Quick test buttons working

Flutter:
- [ ] Semua compilation errors sudah fixed (92 errors → 0 errors)
- [ ] `flutter run` berhasil
- [ ] Bisa connect ke backend
- [ ] API calls working (test di home_screen)

## 📦 Sample Credentials

**Login Test:**
- Phone: `08123456789`
- Password: `any_password` (backend menerima any password)

**Sample IDs:**
- Product: `prod_1`, `prod_2`
- UMKM: `umkm_1`
- User: `1`

## 🔄 Workflow Development

1. **Backend Development**
   - Edit `server.js` untuk add/modify endpoints
   - Test dengan curl atau api-test.html
   - Restart server (`npm start`)

2. **Frontend Development**
   - Edit Flutter files
   - Run `flutter run` untuk test
   - Backend harus running for API calls

3. **Testing**
   - Gunakan api-test.html untuk test API
   - Gunakan Flutter app untuk end-to-end testing

## ⚠️ Common Issues

### "Cannot GET /api-test.html"
- Pastikan file ada di: `backend/public/api-test.html`
- Pastikan server running dengan `npm start`

### Flutter cannot connect to backend
- Pastikan backend running di port 8000
- Pastikan tidak ada firewall blocking
- Android emulator: gunakan `10.0.2.2:8000` (bukan `localhost:8000`)

### CORS Error
- Backend sudah setup CORS
- Jika masih error, clear browser cache

## 📞 Next Steps

1. ✅ Backend created and running
2. ✅ Flutter errors fixed
3. ⏳ Integrate more endpoints
4. ⏳ Add database (MongoDB/PostgreSQL)
5. ⏳ Authentication with JWT
6. ⏳ Deploy to production

---

**Happy Development! 🎉**
