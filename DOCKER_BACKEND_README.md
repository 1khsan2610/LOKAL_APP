# 🐳 Docker Compose Backend Setup - LOKAL App

Panduan lengkap untuk menjalankan backend LOKAL menggunakan Docker Compose.

## 📦 Yang Sudah Siap

✅ **docker-compose.yml** - Konfigurasi lengkap untuk semua services
✅ **.env.docker** - Template environment variables
✅ **Dockerfile** - Image untuk backend Laravel
✅ **DOCKER_COMPOSE_GUIDE.md** - Dokumentasi lengkap
✅ **docker-start.sh/docker-start.bat** - Quick start scripts

## 🚀 Quickstart (3 Langkah)

### 1️⃣ Setup Environment

```bash
# Copy template env
cp .env.docker .env

# Edit jika perlu (optional)
# Windows: notepad .env
# Linux/Mac: nano .env
```

### 2️⃣ Start Services

**Windows:**
```powershell
# Make script executable (first time only)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run services
.\docker-start.bat start

# Or manual
docker-compose up -d
```

**Linux/Mac:**
```bash
# Make executable
chmod +x docker-start.sh

# Run services
./docker-start.sh start

# Or manual
docker-compose up -d
```

### 3️⃣ Initialize Database

```bash
# Option 1: Using script
./docker-start.sh init-db  # Linux/Mac
docker-start.bat init-db   # Windows

# Option 2: Manual
docker-compose exec backend php artisan migrate --force
```

## 🌐 Access Applications

Setelah services berjalan, akses aplikasi di:

| Aplikasi | URL | Akun |
|----------|-----|------|
| **Backend API** | http://localhost:8000 | - |
| **Frontend** | http://localhost:3000 | - |
| **MinIO Console** | http://localhost:9001 | admin / minioadmin |
| **n8n Dashboard** | http://localhost:5678 | admin / admin |
| **MailPit UI** | http://localhost:8025 | - |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                     │
    ┌───▼────┐                           ┌───▼────┐
    │Frontend │                           │Backend │
    │ :3000   │                           │ :8000  │
    └────┬────┘                           └───┬────┘
         │                                    │
         └────────────────────┬───────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
          ┌───▼────┐    ┌────▼─────┐    ┌───▼────┐
          │ MySQL  │    │  Redis   │    │MinIO   │
          │ :3306  │    │ :6379    │    │ :9000  │
          └────────┘    └──────────┘    └────────┘

          ┌────────────────────────────┐
          │ n8n Automation             │
          │ :5678                      │
          └────────────────────────────┘

          ┌────────────────────────────┐
          │ MailPit                    │
          │ :8025 (UI) / :1025 (SMTP)  │
          └────────────────────────────┘
```

## 📊 Services Detail

### 1. **MySQL Database** (lokal_app_mysql)
- **Image**: mysql:8.0
- **Port**: 3306
- **Volume**: `mysql_data` (persisten)
- **Healthcheck**: ✅ Enabled

Fungsi: Database utama untuk aplikasi

### 2. **Redis Cache** (lokal_app_redis)
- **Image**: redis:7-alpine
- **Port**: 6379
- **Volume**: `redis_data` (persisten)
- **Healthcheck**: ✅ Enabled

Fungsi: Cache, session storage, queue broker

### 3. **Backend Laravel** (lokal_app_backend)
- **Image**: Custom (Dockerfile)
- **Port**: 8000
- **PHP Version**: 8.1-fpm-alpine
- **Includes**: PHP-FPM, Nginx, Supervisor

Fitur:
- ✅ Auto-migration on startup
- ✅ Config caching
- ✅ Route caching
- ✅ Supervisor untuk queue/jobs
- ✅ Healthcheck endpoint

### 4. **MinIO Object Storage** (lokal_app_minio)
- **Image**: minio/minio:latest
- **Ports**: 9000 (API), 9001 (Console)
- **Volume**: `minio_data` (persisten)

Fungsi: S3-compatible object storage untuk file uploads

**Console**: http://localhost:9001
- Username: `minioadmin`
- Password: `minioadmin`

### 5. **n8n Automation** (lokal_app_n8n)
- **Image**: n8nio/n8n:latest
- **Port**: 5678
- **Database**: PostgreSQL (n8n_postgres)

Fungsi: Workflow automation dan integration

**Dashboard**: http://localhost:5678
- Username: `admin`
- Password: `admin`

### 6. **MailPit** (lokal_app_mailpit)
- **Image**: axllent/mailpit:latest
- **Ports**: 1025 (SMTP), 8025 (UI)

Fungsi: Email testing & debugging

**UI**: http://localhost:8025

### 7. **Frontend React** (lokal_app_web)
- **Image**: Custom (dari welcome-to-docker)
- **Port**: 3000

## 📝 Perintah Penting

### Quick Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View status
docker-compose ps

# View logs
docker-compose logs -f backend

# Access shell
docker-compose exec backend /bin/sh

# Run artisan command
docker-compose exec backend php artisan tinker
```

### Database

```bash
# Run migrations
docker-compose exec backend php artisan migrate

# Seed database
docker-compose exec backend php artisan db:seed

# Create backup
docker-compose exec mysql mysqldump -u appuser -p lokal_app > backup.sql

# Access MySQL CLI
docker-compose exec mysql mysql -u appuser -p lokal_app
```

### Cache & Configuration

```bash
# Clear cache
docker-compose exec backend php artisan cache:clear

# Clear config
docker-compose exec backend php artisan config:clear

# Clear routes
docker-compose exec backend php artisan route:clear

# Regenerate all
docker-compose exec backend php artisan cache:clear && \
  php artisan config:cache && \
  php artisan route:cache
```

### Redis

```bash
# Access Redis CLI
docker-compose exec redis redis-cli

# Monitor commands
docker-compose exec redis redis-cli MONITOR

# Clear all data
docker-compose exec redis redis-cli FLUSHALL
```

## 🔍 Troubleshooting

### Backend tidak connect ke MySQL

```bash
# Check MySQL
docker-compose logs mysql

# Test connection
docker-compose exec backend php artisan tinker
# Dalam tinker: DB::connection()->getPdo();
```

### Redis connection error

```bash
# Check Redis
docker-compose logs redis

# Test Redis
docker-compose exec redis redis-cli ping
# Should return: PONG
```

### Port sudah digunakan

```bash
# Ubah di .env
BACKEND_PORT=8001
DB_PORT=3307

# Atau kill proses
# Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux/Mac:
lsof -ti:8000 | xargs kill -9
```

### Container crashes

```bash
# View logs
docker-compose logs backend

# Rebuild
docker-compose build --no-cache backend

# Restart
docker-compose restart backend
```

### Full reset

```bash
# Stop dan hapus semua (termasuk data!)
docker-compose down -v

# Rebuild dan restart
docker-compose build
docker-compose up -d
```

## 🔐 Environment Variables

Penting untuk dikonfigurasi:

```env
# Application
APP_ENV=local
APP_DEBUG=true
APP_KEY=base64:xp4FLVmVJYLdgQ8OFcGDWq3Tnq4wvP5XQK4xR6JK2VQ=

# Database
DB_DATABASE=lokal_app
DB_USERNAME=appuser
DB_PASSWORD=password
DB_ROOT_PASSWORD=root

# JWT Authentication
JWT_SECRET=your-secret-key-here

# External Services
MIDTRANS_SERVER_KEY=your_key
TWILIO_ACCOUNT_SID=your_sid
GOOGLE_MAPS_API_KEY=your_key

# MinIO
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin
```

## 📈 Performance Tips

1. **Use named volumes** untuk better I/O
2. **Enable Docker BuildKit**: `export DOCKER_BUILDKIT=1`
3. **Increase PHP memory** di `config/php.ini`
4. **Optimize MySQL** dengan proper indexing
5. **Monitor resource usage**: `docker stats`

## 📚 Dokumentasi Lengkap

Lihat **DOCKER_COMPOSE_GUIDE.md** untuk:
- ✅ Setup detail setiap service
- ✅ Perintah lengkap
- ✅ Troubleshooting advanced
- ✅ Production configuration
- ✅ Backup & restore procedures

## 🆘 Getting Help

1. **Check logs**: `docker-compose logs [service]`
2. **Read documentation**: DOCKER_COMPOSE_GUIDE.md
3. **Check service health**: `./docker-start.sh status`
4. **Test connectivity**: `docker-compose exec [service] [command]`

## 🚀 Next Steps

1. ✅ Configure .env file
2. ✅ Start services: `docker-compose up -d`
3. ✅ Initialize database: `docker-compose exec backend php artisan migrate`
4. ✅ Seed data (optional): `docker-compose exec backend php artisan db:seed`
5. ✅ Test API: http://localhost:8000/api/health
6. ✅ Access frontend: http://localhost:3000

---

**Created**: 2024
**Last Updated**: 2024
**Maintained by**: Development Team

**Need help?** Refer to DOCKER_COMPOSE_GUIDE.md for comprehensive documentation.
