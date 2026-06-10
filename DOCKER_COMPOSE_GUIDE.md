# Docker Compose Setup Guide - LOKAL Backend

Panduan lengkap untuk setup dan menjalankan aplikasi LOKAL menggunakan Docker Compose.

## 📋 Prasyarat

- Docker Desktop v4.0+ ([Download](https://www.docker.com/products/docker-desktop/))
- Docker Compose v2.0+
- Git
- Terminal/PowerShell (untuk Windows)

## 🏗️ Arsitektur Services

```
┌─────────────────────────────────────────────────────┐
│                    Docker Network                    │
├─────────────────────────────────────────────────────┤
│                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐  │
│  │  Frontend    │  │  Backend     │  │ MailPit   │  │
│  │  (React)     │  │  (Laravel)   │  │ (Email)   │  │
│  │  :3000       │  │  :8000       │  │ :8025     │  │
│  └──────────────┘  └──────────────┘  └───────────┘  │
│         ▲                  ▲                           │
│         └──────────────────┴───────────────────┐      │
│                                                │      │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────▼──┐  │
│  │   MySQL      │  │    Redis     │  │   MinIO    │  │
│  │   :3306      │  │   :6379      │  │   :9000    │  │
│  └──────────────┘  └──────────────┘  └────────────┘  │
│                                                       │
│  ┌────────────────────────┐  ┌────────────────────┐  │
│  │   n8n Automation       │  │  PostgreSQL (n8n)  │  │
│  │   :5678                │  │  (internal)        │  │
│  └────────────────────────┘  └────────────────────┘  │
│                                                       │
└─────────────────────────────────────────────────────┘
```

### Services dan Port

| Service | Container | Port | Deskripsi |
|---------|-----------|------|-----------|
| **Frontend** | lokal_app_web | 3000 | React Web Application |
| **Backend** | lokal_app_backend | 8000 | Laravel API Server |
| **MySQL** | lokal_app_mysql | 3306 | Database |
| **Redis** | lokal_app_redis | 6379 | Cache & Session |
| **MinIO** | lokal_app_minio | 9000/9001 | Object Storage (S3-compatible) |
| **n8n** | lokal_app_n8n | 5678 | Workflow Automation |
| **MailPit** | lokal_app_mailpit | 8025 | Email Testing UI |
| **PostgreSQL (n8n)** | lokal_app_n8n_postgres | - | n8n Database |

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone <repository-url>
cd LOKAL_APP
```

### 2. Setup Environment Variables

```bash
# Copy template environment
cp .env.docker .env

# Edit konfigurasi (optional)
# Windows: notepad .env
# Linux/Mac: nano .env
```

### 3. Build Docker Images

```bash
# Build semua service
docker-compose build

# Atau build service tertentu
docker-compose build backend
docker-compose build frontend_web
```

### 4. Start Services

```bash
# Start all services in background
docker-compose up -d

# Atau dengan output log
docker-compose up

# Stop services
docker-compose down

# Stop dan remove volumes
docker-compose down -v
```

### 5. Check Status Services

```bash
# List all running services
docker-compose ps

# Expected output:
# NAME                  STATUS          PORTS
# lokal_app_backend     Up 2 minutes    0.0.0.0:8000->80/tcp
# lokal_app_mysql       Up 3 minutes    0.0.0.0:3306->3306/tcp
# lokal_app_redis       Up 3 minutes    0.0.0.0:6379->6379/tcp
# lokal_app_web         Up 1 minute     0.0.0.0:3000->3000/tcp
# lokal_app_minio       Up 2 minutes    0.0.0.0:9000->9000/tcp, 9001/tcp
# lokal_app_n8n         Up 1 minute     0.0.0.0:5678->5678/tcp
# lokal_app_mailpit     Up 2 minutes    0.0.0.0:8025->8025/tcp
```

### 6. Initialize Database (jika perlu)

```bash
# Run migrations
docker-compose exec backend php artisan migrate

# Seed database (optional)
docker-compose exec backend php artisan db:seed

# Clear cache
docker-compose exec backend php artisan cache:clear
docker-compose exec backend php artisan config:clear
docker-compose exec backend php artisan route:clear
```

## 🌐 Access Applications

| Aplikasi | URL | Kredensial |
|----------|-----|-----------|
| **Backend API** | http://localhost:8000 | - |
| **Backend Docs** | http://localhost:8000/api/documentation | - |
| **Frontend** | http://localhost:3000 | - |
| **MinIO Console** | http://localhost:9001 | admin / minioadmin |
| **n8n Dashboard** | http://localhost:5678 | admin / admin |
| **MailPit UI** | http://localhost:8025 | - |
| **MySQL** | localhost:3306 | appuser / password |
| **Redis CLI** | redis-cli -h localhost -p 6379 | - |

## 📝 Perintah Umum

### Laravel Artisan Commands

```bash
# Run migrations
docker-compose exec backend php artisan migrate

# Seed database
docker-compose exec backend php artisan db:seed

# Tinker shell
docker-compose exec backend php artisan tinker

# Generate cache
docker-compose exec backend php artisan cache:clear
docker-compose exec backend php artisan config:cache
docker-compose exec backend php artisan route:cache

# Create migration
docker-compose exec backend php artisan make:migration create_users_table

# Create controller
docker-compose exec backend php artisan make:controller UserController

# Create model
docker-compose exec backend php artisan make:model User
```

### Composer Commands

```bash
# Install dependencies
docker-compose exec backend composer install

# Require package
docker-compose exec backend composer require vendor/package

# Update dependencies
docker-compose exec backend composer update

# Show installed packages
docker-compose exec backend composer show
```

### Database Commands

```bash
# Access MySQL CLI
docker-compose exec mysql mysql -u appuser -p lokal_app

# Backup database
docker-compose exec mysql mysqldump -u appuser -p lokal_app > backup.sql

# Restore database
docker-compose exec -T mysql mysql -u appuser -p lokal_app < backup.sql
```

### Redis Commands

```bash
# Access Redis CLI
docker-compose exec redis redis-cli

# Clear all cache
docker-compose exec redis redis-cli FLUSHALL

# Get cache info
docker-compose exec redis redis-cli INFO stats
```

### View Logs

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs backend
docker-compose logs mysql
docker-compose logs redis

# Follow logs in real-time
docker-compose logs -f backend

# View last 100 lines
docker-compose logs --tail=100 backend
```

### Rebuild Services

```bash
# Rebuild specific service
docker-compose build --no-cache backend

# Rebuild all services
docker-compose build --no-cache

# Rebuild and restart
docker-compose up -d --build
```

## 🔧 Troubleshooting

### Backend tidak bisa terhubung ke MySQL

```bash
# Check MySQL health
docker-compose exec mysql mysqladmin ping -h localhost

# View MySQL logs
docker-compose logs mysql

# Restart MySQL
docker-compose restart mysql
```

### Redis connection error

```bash
# Check Redis health
docker-compose exec redis redis-cli ping

# View Redis logs
docker-compose logs redis

# Restart Redis
docker-compose restart redis
```

### Backend crashes

```bash
# View backend logs
docker-compose logs backend

# Restart backend
docker-compose restart backend

# Check PHP errors
docker-compose exec backend tail -f storage/logs/laravel.log
```

### Port sudah digunakan

```bash
# Ubah port di .env file
BACKEND_PORT=8001
DB_PORT=3307
REDIS_PORT=6380

# Atau kill existing process
# Linux/Mac:
lsof -ti:8000 | xargs kill -9

# Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

### Remove dangling containers/images

```bash
# Clean up stopped containers
docker-compose down

# Remove unused volumes
docker volume prune

# Remove unused images
docker image prune

# Deep clean (remove everything except running containers)
docker system prune -a
```

## 🔐 Security Configuration

### Untuk Production:

1. **Update .env variables:**
   ```env
   APP_ENV=production
   APP_DEBUG=false
   JWT_SECRET=generate-a-secure-random-string
   MINIO_KEY=change-default-credentials
   MINIO_SECRET=change-default-credentials
   N8N_PASSWORD=change-default-password
   ```

2. **Update MySQL password:**
   ```env
   DB_ROOT_PASSWORD=secure-root-password
   DB_PASSWORD=secure-user-password
   ```

3. **Setup SSL/TLS:**
   - Gunakan Nginx reverse proxy dengan SSL
   - Setup Let's Encrypt certificates
   - Configure CORS domain

4. **Backup configuration:**
   ```bash
   # Backup database
   docker-compose exec mysql mysqldump -u root -p --all-databases > full-backup.sql
   
   # Backup MinIO data
   docker run --rm --volumes-from lokal_app_minio -v $(pwd):/backup ubuntu tar czf /backup/minio-backup.tar.gz /data
   ```

## 📊 Performance Optimization

1. **Increase PHP memory:**
   ```
   Ubah di backend/config/php.ini:
   memory_limit = 512M
   ```

2. **Optimize Docker:**
   - Use named volumes untuk better performance
   - Enable BuildKit: `export DOCKER_BUILDKIT=1`
   - Use `.dockerignore` untuk exclude unnecessary files

3. **Database optimization:**
   ```bash
   docker-compose exec mysql mysql -u root -p -e "ANALYZE TABLE users;"
   ```

4. **Redis optimization:**
   ```bash
   docker-compose exec redis redis-cli CONFIG SET maxmemory 512mb
   docker-compose exec redis redis-cli CONFIG SET maxmemory-policy allkeys-lru
   ```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Laravel Docker Guide](https://laravel.com/docs/11/deployment/docker)
- [MinIO Documentation](https://docs.min.io/)
- [n8n Documentation](https://docs.n8n.io/)

## 💡 Tips & Best Practices

1. **Always backup database sebelum major updates**
   ```bash
   docker-compose exec mysql mysqldump -u appuser -p lokal_app > backup-$(date +%Y%m%d).sql
   ```

2. **Monitor resource usage**
   ```bash
   docker stats
   ```

3. **Keep Docker images updated**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

4. **Use environment-specific files**
   - `.env.local` untuk development
   - `.env.staging` untuk staging
   - `.env.production` untuk production

5. **Test aplikasi sebelum production**
   ```bash
   docker-compose exec backend php artisan test
   ```

---

**Last Updated:** 2024  
**Maintained by:** Development Team
