# Docker Setup Guide - LOKAL APP

Dokumentasi lengkap untuk setup dan menjalankan aplikasi menggunakan Docker.

## Prasyarat

- Docker Desktop v4.0+
- Docker Compose v2.0+

[Download Docker Desktop](https://www.docker.com/products/docker-desktop/)

## Struktur Services

Aplikasi Anda dijalankan dengan 4 services:

| Service | Port | Deskripsi |
|---------|------|-----------|
| **Backend (Laravel)** | 8000 | API Laravel dengan Nginx & PHP-FPM |
| **Frontend (React)** | 3000 | React Web Application |
| **MySQL Database** | 3306 | Database MySQL 8.0 |
| **Redis Cache** | 6379 | Cache & Session Storage |

## Quick Start

### 1. Setup Environment Variables

```bash
# Copy template environment
cp .env.docker .env.docker.local

# Edit konfigurasi jika diperlukan
# nano .env.docker.local
```

### 2. Build & Start Services

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# Check status
docker-compose ps
```

### 3. Initialize Backend

```bash
# Run migrations
docker-compose exec backend php artisan migrate

# Seed database (optional)
docker-compose exec backend php artisan db:seed

# Generate cache
docker-compose exec backend php artisan config:cache
docker-compose exec backend php artisan route:cache
```

## Mengakses Aplikasi

- **API Backend**: http://localhost:8000
- **Frontend Web**: http://localhost:3000
- **Database**: localhost:3306 (dari host machine)

## Perintah Umum

### Menjalankan Artisan Commands

```bash
# Run migrations
docker-compose exec backend php artisan migrate

# Run seeders
docker-compose exec backend php artisan db:seed

# Tinker shell
docker-compose exec backend php artisan tinker

# Clear cache
docker-compose exec backend php artisan cache:clear
docker-compose exec backend php artisan config:clear
docker-compose exec backend php artisan route:clear
```

### Menjalankan PHP

```bash
# Execute PHP command
docker-compose exec backend php -v

# Install Composer packages
docker-compose exec backend composer require vendor/package
```

### Menjalankan Database

```bash
# Access MySQL CLI
docker-compose exec mysql mysql -u appuser -p lokal_app

# Backup database
docker-compose exec mysql mysqldump -u appuser -p lokal_app > backup.sql

# Restore database
docker-compose exec mysql mysql -u appuser -p lokal_app < backup.sql
```

### View Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f mysql
docker-compose logs -f frontend_web

# View last 100 lines
docker-compose logs --tail=100 backend
```

## Melihat File Logs

Log files tersimpan di:

```
backend/storage/logs/
├── php-fpm.log
├── nginx.log
├── nginx-access.log
├── nginx-error.log
└── supervisord.log
```

## Development Mode

Untuk development dengan hot-reload:

```bash
# Frontend React sudah auto-reload
docker-compose up -d frontend_web

# Backend PHP - edit volume mapping di docker-compose.yml:
# Sudah dikonfigurasi untuk hot-reload dari ./backend:/app
```

## Stop & Clean Up

```bash
# Stop services
docker-compose stop

# Stop dan remove containers
docker-compose down

# Remove images
docker-compose down --rmi all

# Remove volumes (hati-hati - menghapus data database!)
docker-compose down -v
```

## Troubleshooting

### Database Connection Error

```bash
# Check MySQL status
docker-compose ps mysql

# Check MySQL logs
docker-compose logs mysql

# Restart MySQL
docker-compose restart mysql
```

### Port Already in Use

Jika port sudah terpakai, ubah di `.env.docker.local`:

```
BACKEND_PORT=8001
FRONTEND_WEB_PORT=3001
DB_PORT=3307
REDIS_PORT=6380
```

Kemudian restart:

```bash
docker-compose down
docker-compose up -d
```

### Permission Issues

```bash
# Reset permissions
docker-compose exec backend chown -R appuser:appuser /app
docker-compose exec backend chmod -R 775 storage bootstrap/cache
```

### Clear Everything & Start Fresh

```bash
# Remove semua containers, images, volumes
docker-compose down -v --rmi all

# Build dari awal
docker-compose build

# Start services
docker-compose up -d

# Initialize database
docker-compose exec backend php artisan migrate --seed
```

## Production Deployment

Untuk production, tambahkan `.env.production`:

```bash
APP_DEBUG=false
APP_ENV=production
```

Update `docker-compose.yml`:

```yaml
environment:
  APP_ENV: production
  APP_DEBUG: false
```

## Tips & Best Practices

1. **Selalu gunakan named volumes** untuk persistent data
2. **Jangan commit `.env.docker.local`** ke git
3. **Gunakan health checks** untuk monitoring
4. **Backup database reguler** dengan command di atas
5. **Monitor logs** untuk error dan performance issues

## References

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Laravel in Docker](https://laravel.com/docs/10.x/deployment#docker)
- [React Docker Best Practices](https://reactjs.org/docs/deployment.html)
