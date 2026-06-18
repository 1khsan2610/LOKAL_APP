# 🐳 Docker Guide - LOKAL App

## 📋 Daftar Isi
1. [Quick Start](#quick-start)
2. [Docker Basics](#docker-basics)
3. [Setup Docker](#setup-docker)
4. [Running with Docker](#running-with-docker)
5. [Useful Commands](#useful-commands)
6. [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

### Cara Paling Cepat (3 langkah)

**Step 1: Install Docker Desktop**
- Download: https://www.docker.com/products/docker-desktop
- Install dan restart computer

**Step 2: Jalankan Docker**
```powershell
docker-compose -f docker-compose.simple.yml up -d
```

**Step 3: Akses Aplikasi**
- Backend: http://localhost:8000
- API: http://localhost:8000/api/v1
- Test: http://localhost:8000/test.html

**Done! ✅** Backend running di Docker

---

## 🐳 Docker Basics (Penjelasan)

### Apa itu Docker?
Docker adalah kontainer - seperti "mesin virtual ringan" yang membungkus aplikasi dengan semua dependencies-nya.

### Keuntungan Docker:
- ✅ Consistent environment (sama di local, dev, production)
- ✅ No "works on my machine" problems
- ✅ Easy to scale
- ✅ Version control untuk infrastructure
- ✅ Isolation (tidak conflict dengan aplikasi lain)

### Docker Terminology:
- **Image**: Template/blueprint (seperti ISO file)
- **Container**: Instance aplikasi yang running (seperti VM yang berjalan)
- **Dockerfile**: File untuk define/buat Docker image
- **Docker Compose**: Tool untuk run multiple containers sekaligus

---

## ⚙️ Setup Docker

### Langkah 1: Install Docker Desktop

#### Windows:
1. Download: https://www.docker.com/products/docker-desktop
2. Run installer
3. Restart komputer
4. Open PowerShell, test:
   ```powershell
   docker --version
   docker run hello-world
   ```

#### Mac:
```bash
brew install --cask docker
open /Applications/Docker.app
```

#### Linux (Ubuntu):
```bash
sudo apt-get install docker.io docker-compose
sudo usermod -aG docker $USER
```

### Langkah 2: Verify Installation

```powershell
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Test Docker
docker run hello-world
```

Expected output:
```
Docker version 29.4.3, build 055a478
Docker Compose version 2.x.x
Hello from Docker!
```

### Langkah 3: Understanding Project Structure

```
LOKAL_APP/
├── backend/
│   ├── app.py                ← Flask application
│   ├── requirements.txt       ← Python dependencies
│   ├── Dockerfile.flask       ← Docker image definition
│   └── ...
│
├── frontend/
│   ├── lib/
│   └── ...
│
├── docker-compose.simple.yml  ← Simple setup (recommended)
├── docker-compose.yml         ← Full setup (with MySQL, Redis, etc)
│
└── docs/
    └── DOCKER_GUIDE.md        ← This file
```

---

## 🚀 Running with Docker

### Option 1: Simple Setup (Recommended for Dev)

**Best for**: Quick development, testing

**File**: `docker-compose.simple.yml`

**Includes**: Only backend (Flask)

### Run Backend Only:

```powershell
cd d:\laragon\www\LOKAL_APP
docker-compose -f docker-compose.simple.yml up -d
```

Expected output:
```
[+] Building 15.3s (11/11) FINISHED
[+] Running 1/1
 ✓ lokal_backend
```

**Access Backend**:
- API: http://localhost:8000/api/v1
- Health: http://localhost:8000/api/v1/health
- Dashboard: http://localhost:8000/test.html

### Stop Backend:
```powershell
docker-compose -f docker-compose.simple.yml down
```

---

### Option 2: Full Setup (With Database & Cache)

**Best for**: Production-like environment

**File**: `docker-compose.yml`

**Includes**: Backend + MySQL + Redis + MinIO + Mail + n8n

### Uncomment Services (Optional):

Edit `docker-compose.yml` dan uncomment services yang mau digunakan:

```yaml
# Uncomment untuk MySQL
mysql:
  image: mysql:8.0
  # ...

# Uncomment untuk Redis
redis:
  image: redis:7-alpine
  # ...
```

### Run Full Stack:

```powershell
cd d:\laragon\www\LOKAL_APP
docker-compose up -d
```

### Services Available:

| Service | Port | URL |
|---------|------|-----|
| Backend | 8000 | http://localhost:8000 |
| MySQL | 3306 | mysql://localhost:3306 |
| Redis | 6379 | redis://localhost:6379 |
| MinIO | 9000 | http://localhost:9000 |
| Mail | 1025 | localhost:1025 |
| n8n | 5678 | http://localhost:5678 |

---

## 📝 Useful Docker Commands

### Container Management

```powershell
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Start container
docker start <container_name>

# Stop container
docker stop <container_name>

# Remove container
docker rm <container_name>

# View container logs
docker logs <container_name>

# Follow logs (real-time)
docker logs -f <container_name>

# Execute command in container
docker exec -it <container_name> bash
```

### Image Management

```powershell
# List images
docker images

# Build image
docker build -f Dockerfile.flask -t lokal-backend:latest .

# Remove image
docker rmi <image_name>

# Remove unused images
docker image prune
```

### Docker Compose Commands

```powershell
# Build images
docker-compose -f docker-compose.simple.yml build

# Start services
docker-compose -f docker-compose.simple.yml up

# Start in background
docker-compose -f docker-compose.simple.yml up -d

# Stop services
docker-compose -f docker-compose.simple.yml stop

# Remove containers & volumes
docker-compose -f docker-compose.simple.yml down

# Remove containers, volumes, images
docker-compose -f docker-compose.simple.yml down -v --rmi all

# View logs
docker-compose -f docker-compose.simple.yml logs

# Follow logs
docker-compose -f docker-compose.simple.yml logs -f backend
```

### Useful Shortcuts

```powershell
# Restart everything
docker-compose -f docker-compose.simple.yml restart

# Rebuild and run
docker-compose -f docker-compose.simple.yml up -d --build

# Check status
docker-compose -f docker-compose.simple.yml ps

# View resource usage
docker stats
```

---

## 🧪 Testing Docker Setup

### Test Backend Health

```powershell
# Inside container
docker exec lokal_backend curl http://localhost:8000/api/v1/health

# From host
curl http://localhost:8000/api/v1/health

# PowerShell
Invoke-WebRequest -Uri "http://localhost:8000/api/v1/health"
```

Expected response:
```json
{
  "message": "LOKAL Backend is running",
  "status": "OK",
  "timestamp": "2026-06-17T15:35:23.124872"
}
```

### Test API Endpoint

```powershell
# Get all products
curl http://localhost:8000/api/v1/products

# Get UMKMs
curl http://localhost:8000/api/v1/umkms

# Login
curl -X POST http://localhost:8000/api/v1/auth/login `
  -H "Content-Type: application/json" `
  -d '{"phone": "08123456789"}'
```

### Test with Dashboard

```
http://localhost:8000/test.html
```

---

## 🔧 Troubleshooting

### Problem: Port already in use

**Error**: `bind: address already in use`

**Solution**:
```powershell
# Find process using port 8000
Get-NetTCPConnection -LocalPort 8000

# Kill process
Stop-Process -Id <PID> -Force

# Or change port in docker-compose.yml
# ports:
#   - "8001:8000"  # Use 8001 instead
```

---

### Problem: Docker daemon not running

**Error**: `Cannot connect to Docker daemon`

**Solution**:
```powershell
# Start Docker Desktop
# Or restart Docker service
Restart-Service docker -Force
```

---

### Problem: Container won't start

**Error**: `docker: Error response from daemon`

**Solution**:
```powershell
# Check logs
docker logs <container_name>

# Rebuild everything
docker-compose -f docker-compose.simple.yml down -v
docker-compose -f docker-compose.simple.yml up -d --build

# Or rebuild specific image
docker build -f Dockerfile.flask -t lokal-backend:latest --no-cache backend/
```

---

### Problem: Flask app not responding

**Error**: `Connection refused`

**Solution**:
```powershell
# Check container is running
docker ps

# Check logs
docker logs -f lokal_backend

# Restart container
docker restart lokal_backend

# Check port mapping
docker port lokal_backend
```

---

### Problem: Out of disk space

**Error**: `no space left on device`

**Solution**:
```powershell
# Clean up unused images
docker image prune -a

# Clean up unused volumes
docker volume prune

# Clean up unused containers
docker container prune

# Or remove everything
docker system prune -a
```

---

## 🎯 Development Workflow with Docker

### Option A: Backend in Docker, Frontend Local

```powershell
# Terminal 1: Backend in Docker
docker-compose -f docker-compose.simple.yml up -d

# Terminal 2: Frontend local (Flutter)
cd frontend
flutter run -d chrome

# Terminal 3 (optional): View backend logs
docker-compose -f docker-compose.simple.yml logs -f backend
```

### Option B: Everything in Docker

```powershell
# Uncomment frontend in docker-compose.simple.yml
# Then:

docker-compose -f docker-compose.simple.yml up -d

# Access frontend: http://localhost:3000
# Access backend: http://localhost:8000
```

---

## 📊 Monitoring Docker

### View Running Containers

```powershell
docker ps
```

Output:
```
CONTAINER ID   IMAGE              COMMAND              PORTS
abc123         lokal-backend      "python app.py"      8000:8000
```

### View Container Details

```powershell
docker inspect <container_name>
```

### Monitor Resource Usage

```powershell
docker stats
```

Real-time stats:
```
CONTAINER       CPU %    MEM        MEM %
lokal_backend   0.5%     45.2MiB    2.3%
```

---

## 🔐 Environment Variables

### Override via `.env` file

**Create `.env` file:**
```
DB_DATABASE=lokal_app
DB_USERNAME=appuser
DB_PASSWORD=password
REDIS_PORT=6379
```

**Use in docker-compose:**
```powershell
docker-compose --env-file .env -f docker-compose.yml up -d
```

---

## 📚 Advanced Topics

### Building Custom Image

**Edit Dockerfile.flask:**
```dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8000
CMD ["python", "app.py"]
```

**Build:**
```powershell
docker build -f Dockerfile.flask -t lokal-backend:1.0 .
```

**Run:**
```powershell
docker run -p 8000:8000 lokal-backend:1.0
```

---

### Docker Hub (Share Image)

```powershell
# Login to Docker Hub
docker login

# Tag image
docker tag lokal-backend:latest yourusername/lokal-backend:latest

# Push to Docker Hub
docker push yourusername/lokal-backend:latest

# Pull from Docker Hub
docker pull yourusername/lokal-backend:latest
```

---

### Using Docker with Docker Compose Override

**Create `docker-compose.override.yml`:**
```yaml
services:
  backend:
    ports:
      - "8001:8000"  # Different port
    environment:
      FLASK_ENV: development
```

**Run:**
```powershell
docker-compose up -d
# Automatically uses both compose files
```

---

## 📋 Quick Cheat Sheet

| Task | Command |
|------|---------|
| Start backend | `docker-compose -f docker-compose.simple.yml up -d` |
| Stop backend | `docker-compose -f docker-compose.simple.yml down` |
| View logs | `docker logs -f lokal_backend` |
| SSH into container | `docker exec -it lokal_backend bash` |
| Rebuild | `docker-compose -f docker-compose.simple.yml up -d --build` |
| Clean everything | `docker system prune -a` |
| Test health | `curl http://localhost:8000/api/v1/health` |
| View containers | `docker ps` |
| Check stats | `docker stats` |

---

## ✅ Verification Checklist

- [ ] Docker Desktop installed
- [ ] `docker --version` returns v24+
- [ ] `docker-compose --version` returns v2+
- [ ] Can run `docker run hello-world`
- [ ] Backend started with `docker-compose up -d`
- [ ] Backend responds: `http://localhost:8000/api/v1/health`
- [ ] Test dashboard working: `http://localhost:8000/test.html`
- [ ] Logs visible with `docker logs -f lokal_backend`
- [ ] Can restart with `docker-compose restart`
- [ ] Can stop with `docker-compose down`

---

## 🎯 When to Use Docker

### Use Docker When:
- ✅ Working in team (consistency)
- ✅ Deploying to production
- ✅ Need isolated environments
- ✅ Multiple services (DB, cache, etc)
- ✅ Want reproducible builds
- ✅ Testing before production

### Don't Need Docker When:
- ❌ Solo development on local machine
- ❌ Rapid prototyping
- ❌ Very simple application
- ❌ Limited machine resources

---

## 📞 Support

- **Docker Docs**: https://docs.docker.com/
- **Docker Compose Docs**: https://docs.docker.com/compose/
- **Docker Hub**: https://hub.docker.com/
- **Stackoverflow**: Tag `docker`

---

## 🎉 You're Ready!

Docker setup is complete. Choose your development style:

### Option 1: Quick Development
```powershell
# Terminal 1: Backend in Docker
docker-compose -f docker-compose.simple.yml up -d

# Terminal 2: Frontend local
flutter run -d chrome
```

### Option 2: Full Production-like
```powershell
# Everything in Docker
docker-compose -f docker-compose.yml up -d
```

**Selamat menggunakan Docker! 🐳🚀**
