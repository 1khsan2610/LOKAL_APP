# 🚀 Docker untuk LOKAL App - Panduan Cepat

## Apa itu Docker?
Docker adalah "kontainer" - seperti kotak yang berisi aplikasi + semua kebutuhan (dependencies) dalam satu paket. Jadi app bisa jalan di komputer manapun tanpa masalah.

**Keuntungan:**
- ✅ Tidak ada "works on my machine" problem
- ✅ Setup cepat & mudah
- ✅ Sama di local, dev, & production
- ✅ Gampang share dengan team

---

## 📥 Step 1: Install Docker

### Windows/Mac:
1. **Download**: https://www.docker.com/products/docker-desktop
2. **Install** seperti software biasa
3. **Restart** komputer
4. **Buka PowerShell**, test:
   ```powershell
   docker --version
   ```

### Linux (Ubuntu):
```bash
sudo apt-get install docker.io docker-compose
```

---

## 🚀 Step 2: Jalankan Backend dengan Docker

### Cara 1: Backend Only (Paling Cepat)

```powershell
cd d:\laragon\www\LOKAL_APP
docker-compose -f docker-compose.simple.yml up -d
```

**Tunggu sampai selesai**, kemudian:

```powershell
docker ps
```

Lihat `lokal_backend` running? ✅ Berhasil!

### Akses Backend:
- 🌐 http://localhost:8000
- 📡 API: http://localhost:8000/api/v1
- 🧪 Test: http://localhost:8000/test.html

---

## 🛑 Step 3: Stop Backend

```powershell
docker-compose -f docker-compose.simple.yml down
```

---

## 🔧 Perintah Docker Penting

### Lihat Container Running
```powershell
docker ps
```

### Lihat Logs Backend
```powershell
docker logs -f lokal_backend
```

### Restart Backend
```powershell
docker restart lokal_backend
```

### Masuk ke Container (Terminal)
```powershell
docker exec -it lokal_backend bash
```

### Bersihkan Semua (Hard Reset)
```powershell
docker-compose -f docker-compose.simple.yml down -v
docker system prune -a
```

---

## 🐛 Troubleshooting

| Masalah | Solusi |
|---------|--------|
| **Port 8000 sudah dipakai** | `docker-compose down` atau ubah port di file |
| **Container tidak jalan** | `docker logs -f lokal_backend` lihat error |
| **Docker tidak ketemu** | Pastikan Docker Desktop running |
| **Mau hard reset** | `docker system prune -a` lalu run ulang |

---

## 📝 Development Workflow

### Dengan Docker:

```powershell
# Terminal 1: Backend (auto-reload)
docker-compose -f docker-compose.simple.yml up -d

# Terminal 2: Frontend (Flutter)
cd frontend
flutter run -d chrome

# Terminal 3: Lihat logs (optional)
docker logs -f lokal_backend
```

### Ubah Backend Code?
Cukup save file, Docker auto-reload. Gampang!

---

## 🎯 Kapan Pakai Docker?

### ✅ Gunakan Docker:
- Team development
- Production deployment
- Multiple services (DB, Redis, dll)
- Mau reproducible environment

### ❌ Tidak perlu Docker:
- Solo dev lokal
- Prototyping cepat
- Simple app

---

## 📋 Setup Penuh (Optional - Dengan Database)

Kalau mau MySQL + Redis + MinIO:

**Edit `docker-compose.yml`** - uncomment services yang diinginkan

```powershell
docker-compose -f docker-compose.yml up -d
```

**Services available:**
- Backend: 8000
- MySQL: 3306
- Redis: 6379
- MinIO: 9000

---

## ✅ Verification

```powershell
# Check backend running
docker ps

# Test health check
curl http://localhost:8000/api/v1/health

# Lihat logs
docker logs lokal_backend

# Lihat resource usage
docker stats
```

---

## 🎁 Bonus: Docker Cheat Sheet

```powershell
# Start
docker-compose -f docker-compose.simple.yml up -d

# Stop
docker-compose -f docker-compose.simple.yml down

# Logs
docker logs -f lokal_backend

# Rebuild
docker-compose -f docker-compose.simple.yml up -d --build

# Shell into container
docker exec -it lokal_backend bash

# All containers
docker ps -a

# All images
docker images

# Clean
docker system prune -a
```

---

## 🎉 Done!

Backend Anda sekarang running di Docker. Gampang kan?

**Pertanyaan lain? Lihat:**
- Full guide: `DOCKER_GUIDE.md`
- Setup panduan: `SETUP_COMPLETE.md`

Selamat develop! 🚀
