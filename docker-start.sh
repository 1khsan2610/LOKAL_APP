#!/bin/bash

# Docker Compose Quick Start Script untuk Linux/Mac
# Usage: ./docker-start.sh [command]
# Commands: build, start, stop, restart, logs, clean, reset

set -e

COMMAND="${1:-}"

if [ -z "$COMMAND" ]; then
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════════╗
║         LOKAL App - Docker Compose Quick Start                  ║
╚══════════════════════════════════════════════════════════════════╝

Usage: ./docker-start.sh [command]

Available commands:
  build        - Build Docker images
  start        - Start all services
  stop         - Stop all services
  restart      - Restart all services
  logs         - View logs from all services
  logs-backend - View backend logs only
  ps           - List running containers
  clean        - Stop and remove containers
  reset        - Remove everything (volumes, containers, images)
  init-db      - Initialize database (migrate)
  seed-db      - Seed database with sample data
  clear-cache  - Clear Laravel cache
  shell        - Access backend shell
  status       - Check services status

Example:
  ./docker-start.sh start
  ./docker-start.sh logs-backend

EOF
    exit 0
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "[ERROR] Docker Compose not found. Please install Docker Desktop."
    echo "Download: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo ""
    echo "[WARNING] .env file not found!"
    echo "Creating .env from .env.docker template..."
    cp .env.docker .env
    echo "[OK] .env file created. Please review and adjust if needed."
    echo ""
fi

echo ""
echo "[INFO] Running command: $COMMAND"
echo ""

case "$COMMAND" in
    build)
        echo "[*] Building Docker images..."
        docker-compose build
        ;;
    
    start)
        echo "[*] Starting all services..."
        docker-compose up -d
        sleep 3
        docker-compose ps
        echo ""
        echo "[OK] Services started! Access applications at:"
        echo "   - Backend:   http://localhost:8000"
        echo "   - Frontend:  http://localhost:3000"
        echo "   - MinIO:     http://localhost:9001 (admin/minioadmin)"
        echo "   - n8n:       http://localhost:5678 (admin/admin)"
        echo "   - MailPit:   http://localhost:8025"
        ;;
    
    stop)
        echo "[*] Stopping all services..."
        docker-compose stop
        ;;
    
    restart)
        echo "[*] Restarting all services..."
        docker-compose restart
        sleep 2
        docker-compose ps
        ;;
    
    logs)
        echo "[*] Showing logs from all services..."
        docker-compose logs -f
        ;;
    
    logs-backend)
        echo "[*] Showing backend logs..."
        docker-compose logs -f backend
        ;;
    
    ps)
        echo "[*] Listing running services..."
        docker-compose ps
        ;;
    
    clean)
        echo "[*] Stopping and removing containers..."
        docker-compose down
        echo "[OK] Containers removed. Data preserved."
        ;;
    
    reset)
        echo ""
        echo "[WARNING] This will remove ALL containers, volumes, and cached data!"
        echo ""
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            echo "[*] Removing everything..."
            docker-compose down -v
            echo "[OK] Complete reset done."
        else
            echo "[CANCELLED] Reset cancelled."
        fi
        ;;
    
    init-db)
        echo "[*] Running database migrations..."
        docker-compose exec backend php artisan migrate --force
        ;;
    
    seed-db)
        echo "[*] Seeding database..."
        docker-compose exec backend php artisan db:seed
        ;;
    
    clear-cache)
        echo "[*] Clearing Laravel cache..."
        docker-compose exec backend php artisan cache:clear
        docker-compose exec backend php artisan config:clear
        docker-compose exec backend php artisan route:clear
        echo "[OK] Cache cleared."
        ;;
    
    shell)
        echo "[*] Accessing backend container shell..."
        docker-compose exec backend /bin/sh
        ;;
    
    status)
        echo "[*] Checking services status..."
        echo ""
        docker-compose ps
        echo ""
        echo "[*] Service health check:"
        echo ""
        
        echo -n "Checking Backend... "
        if curl -s http://localhost:8000/api/health > /dev/null; then
            echo "[OK] Backend is healthy"
        else
            echo "[ERROR] Backend is down"
        fi
        
        echo -n "Checking Database... "
        if docker-compose exec mysql mysqladmin ping -h localhost > /dev/null 2>&1; then
            echo "[OK] MySQL is healthy"
        else
            echo "[ERROR] MySQL is down"
        fi
        
        echo -n "Checking Redis... "
        if docker-compose exec redis redis-cli ping > /dev/null 2>&1; then
            echo "[OK] Redis is healthy"
        else
            echo "[ERROR] Redis is down"
        fi
        
        echo -n "Checking MinIO... "
        if curl -s http://localhost:9000/minio/health/live > /dev/null 2>&1; then
            echo "[OK] MinIO is healthy"
        else
            echo "[ERROR] MinIO is down"
        fi
        ;;
    
    *)
        echo "[ERROR] Unknown command: $COMMAND"
        echo "Run './docker-start.sh' without arguments to see available commands."
        exit 1
        ;;
esac

echo ""
echo "[OK] Command executed successfully."
echo ""
