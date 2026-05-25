# 🚀 LOKAL Project Setup - Complete Instructions

## ✅ Project Status

- **Flutter Frontend**: ✅ Fixed (92 errors → 0 errors)
- **Backend Structure**: ✅ Created
- **API Endpoints**: ✅ Implemented (15+ endpoints)
- **Testing Interface**: ✅ Created (Interactive API Dashboard)

---

## 🔧 Installation Requirements

### Node.js & npm Installation

Backend memerlukan Node.js v14+

#### Windows:

1. **Download Node.js**
   - Kunjungi: https://nodejs.org/
   - Download LTS version (recommended)
   - Install dengan default settings

2. **Verify Installation**
   ```bash
   node --version
   npm --version
   ```

3. **If npm not found**
   - Restart computer (PATH needs update)
   - Or add manually: `C:\Program Files\nodejs` to PATH

---

## 📦 Backend Setup

### Step 1: Install Dependencies

```bash
cd "c:\project uas\backend"
npm install
```

Ini akan install:
- ✅ express (web framework)
- ✅ cors (cross-origin support)
- ✅ body-parser (JSON parsing)
- ✅ uuid (ID generation)
- ✅ nodemon (auto-reload in dev)

### Step 2: Start Server

**Option A: Development Mode (dengan auto-reload)**
```bash
npm run dev
```

**Option B: Production Mode**
```bash
npm start
```

Expected output:
```
✅ Server running on http://localhost:8000
✅ API base URL: http://localhost:8000/api
✅ Test dashboard: http://localhost:8000/api-test.html
```

---

## 🧪 Testing Backend

### Method 1: API Testing Dashboard (Recommended)

1. Server sudah running
2. Buka browser: **http://localhost:8000/api-test.html**
3. Lihat "Server Status" badge
4. Klik "Quick Test" buttons untuk test endpoints

### Method 2: Terminal Commands

```bash
# Health check
curl http://localhost:8000/api/health

# Get all products
curl http://localhost:8000/api/products

# Get product detail
curl http://localhost:8000/api/products/prod_1

# Get UMKMs
curl http://localhost:8000/api/umkms

# Login
curl -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"phone\":\"08123456789\",\"password\":\"test\"}"
```

---

## 📱 Flutter Integration

### Configuration Update
✅ Already done! API URL updated:
- `http://localhost:8000/api` ← Flutter points here
- Backend running on `http://localhost:8000` ← Server listens here

### Running Flutter App

```bash
cd "c:\project uas\frontend"
flutter run
```

### Important for Android Emulator
If using Android emulator, replace `localhost:8000` with `10.0.2.2:8000`:

Edit `lib/config/constants.dart`:
```dart
// For Android Emulator:
static const String apiBaseUrl = 'http://10.0.2.2:8000/api';

// For Physical device or iOS:
static const String apiBaseUrl = 'http://localhost:8000/api';
```

---

## 📊 API Endpoints Reference

### Authentication
```
POST /api/auth/login
  { phone: "08123456789", password: "test" }

POST /api/auth/register
  { phone: "08123456789", password: "test", role: "consumer" }

POST /api/auth/verify-otp
  { phone: "08123456789", otp: "123456" }
```

### Products
```
GET /api/products?page=1&per_page=10&search=keripik&category=makanan

GET /api/products/prod_1

GET /api/products/categories
```

### Orders
```
GET /api/orders

GET /api/orders/order_123

POST /api/orders
  { shippingAddress: "Jl. Test", paymentMethod: "gopay", items: [] }
```

### User Profile
```
GET /api/users/profile

PUT /api/users/profile
  { name: "John", email: "john@test.com", address: "Jl. Test", city: "Jakarta" }
```

### UMKM
```
GET /api/umkms

GET /api/umkms/umkm_1

GET /api/umkms/umkm_1/analytics
```

### Wallet
```
GET /api/wallet

GET /api/wallet/transactions
```

### Notifications
```
GET /api/notifications

PUT /api/notifications/notif_1/read
```

---

## 🧩 Project Structure

```
c:\project uas\
├── frontend/                    # Flutter app
│   └── lib/
│       ├── config/
│       │   └── constants.dart  # ✅ apiBaseUrl = localhost:8000
│       ├── providers/
│       ├── screens/
│       ├── models/
│       ├── services/
│       └── widgets/
│
├── backend/                     # Node.js/Express server
│   ├── server.js               # Main server (600+ lines)
│   ├── package.json            # Dependencies
│   ├── public/
│   │   └── api-test.html       # Testing dashboard
│   ├── README.md               # Backend docs
│   └── .gitignore
│
├── SETUP.md                     # This file
└── (android/, ios/, web/, etc.)
```

---

## 🔧 Port Configuration

Default ports:
- **Backend Server**: 8000
- **Flutter Web** (optional): 5000

If port 8000 is already in use:

### Option 1: Use Different Port
Edit `server.js`:
```javascript
const PORT = process.env.PORT || 3000;  // Change from 8000
```

### Option 2: Kill Process Using Port 8000
```bash
# Windows - Find process using port 8000
netstat -ano | findstr :8000

# Kill the process
taskkill /PID <PID> /F

# Or restart computer
```

---

## 🚀 Complete Setup Checklist

Backend Setup:
- [ ] Node.js v14+ installed (`node --version`)
- [ ] npm installed (`npm --version`)
- [ ] Navigated to backend folder
- [ ] Ran `npm install` successfully
- [ ] Started server with `npm start` or `npm run dev`
- [ ] Server running on http://localhost:8000
- [ ] Accessed http://localhost:8000/api-test.html (shows "ONLINE")

Backend Testing:
- [ ] Health check endpoint working
- [ ] Quick test buttons work
- [ ] All API endpoints responding
- [ ] Sample data loading correctly

Flutter Setup:
- [ ] Flutter analysis shows 0 errors (`flutter analyze`)
- [ ] API URL points to localhost:8000
- [ ] Flutter run successful
- [ ] App can call backend APIs

---

## 📝 Development Workflow

### Frontend Development
```bash
cd "c:\project uas\frontend"
flutter run              # Hot reload enabled
# Edit .dart files, save, and hot reload automatically
```

### Backend Development
```bash
cd "c:\project uas\backend"
npm run dev              # Uses nodemon for auto-reload
# Edit server.js, save, and restart automatically
```

### Simultaneous Development
Terminal 1:
```bash
cd "c:\project uas\backend"
npm run dev
```

Terminal 2:
```bash
cd "c:\project uas\frontend"
flutter run
```

Now both backend and frontend are hot-reloading!

---

## 🐛 Troubleshooting

### "npm: command not found"
**Solution:**
1. Install Node.js from https://nodejs.org/
2. Restart terminal/computer
3. Verify: `node --version && npm --version`

### "Port 8000 already in use"
**Solution:**
```bash
# Find process using port 8000
netstat -ano | findstr :8000

# Kill it
taskkill /PID <PID> /F

# Or use different port (edit server.js)
```

### "Cannot GET /api-test.html"
**Solution:**
- Verify file exists: `c:\project uas\backend\public\api-test.html`
- Server running with `npm start`
- Try hard refresh: Ctrl+Shift+R

### Flutter CORS errors
**Solution:**
- Backend already has CORS enabled
- Make sure backend is running
- Check browser console for error details

### Cannot connect from Android Emulator
**Solution:**
- Use `10.0.2.2:8000` instead of `localhost:8000`
- Edit `lib/config/constants.dart`:
```dart
static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
```

### Backend not reloading with nodemon
**Solution:**
- Check if nodemon installed: `npm list nodemon`
- Try: `npm run dev` instead of `npm start`
- Restart terminal

---

## 📚 File References

**Backend:**
- Server logic: [c:\project uas\backend\server.js](c:\project%20uas\backend\server.js)
- Config: [c:\project uas\backend\package.json](c:\project%20uas\backend\package.json)
- API Test: [c:\project uas\backend\public\api-test.html](c:\project%20uas\backend\public\api-test.html)
- Docs: [c:\project uas\backend\README.md](c:\project%20uas\backend\README.md)

**Frontend:**
- API Config: [c:\project uas\frontend\lib\config\constants.dart](c:\project%20uas\frontend\lib\config\constants.dart)
- API Service: [c:\project uas\frontend\lib\services\api_service.dart](c:\project%20uas\frontend\lib\services\api_service.dart)
- Main: [c:\project uas\frontend\lib\main.dart](c:\project%20uas\frontend\lib\main.dart)

---

## 🎯 Next Steps

1. **Install Node.js** (if not already installed)
2. **Run `npm install`** in backend folder
3. **Start server** with `npm start`
4. **Test endpoints** via http://localhost:8000/api-test.html
5. **Run Flutter app** with `flutter run`
6. **Start developing!** Both will have hot-reload

---

## 💡 Tips & Tricks

### Quick Backend Restart
```bash
# Terminal shortcut (Windows)
cd "c:\project uas\backend" && npm start
```

### Test All Endpoints at Once
Use the "Quick Test Endpoints" section in api-test.html

### Monitor Requests
Backend logs all requests to terminal - check there for issues

### Database Reset
Server data resets when you restart server (in-memory storage)

---

## 🤝 Support

If you encounter issues:
1. Check troubleshooting section above
2. Verify all prerequisites installed
3. Check terminal output for error messages
4. Try restarting server and app

---

**Ready to build amazing things! 🚀**
