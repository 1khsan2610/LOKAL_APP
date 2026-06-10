@echo off
REM Docker Compose Quick Start Script untuk Windows
REM Usage: docker-start.bat [command]
REM Commands: build, start, stop, restart, logs, clean, reset

setlocal enabledelayedexpansion

set COMMAND=%1

if "%COMMAND%"=="" (
    echo.
    echo ╔══════════════════════════════════════════════════════════════════╗
    echo ║         LOKAL App - Docker Compose Quick Start                  ║
    echo ╚══════════════════════════════════════════════════════════════════╝
    echo.
    echo Usage: docker-start.bat [command]
    echo.
    echo Available commands:
    echo   build        - Build Docker images
    echo   start        - Start all services
    echo   stop         - Stop all services
    echo   restart      - Restart all services
    echo   logs         - View logs from all services
    echo   logs-backend - View backend logs only
    echo   ps           - List running containers
    echo   clean        - Stop and remove containers
    echo   reset        - Remove everything (volumes, containers, images^)
    echo   init-db      - Initialize database (migrate^)
    echo   seed-db      - Seed database with sample data
    echo   clear-cache  - Clear Laravel cache
    echo   shell        - Access backend shell
    echo   status       - Check services status
    echo.
    echo Example:
    echo   docker-start.bat start
    echo   docker-start.bat logs-backend
    echo.
    goto :end
)

REM Check if docker-compose is installed
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose not found. Please install Docker Desktop.
    echo Download: https://www.docker.com/products/docker-desktop/
    exit /b 1
)

REM Check if .env file exists
if not exist .env (
    echo.
    echo [WARNING] .env file not found!
    echo Creating .env from .env.docker template...
    copy .env.docker .env >nul
    echo [OK] .env file created. Please review and adjust if needed.
    echo.
)

echo.
echo [INFO] Running command: %COMMAND%
echo.

if "%COMMAND%"=="build" (
    echo [*] Building Docker images...
    docker-compose build
    goto :success
)

if "%COMMAND%"=="start" (
    echo [*] Starting all services...
    docker-compose up -d
    timeout /t 3 /nobreak
    docker-compose ps
    echo.
    echo [OK] Services started! Access applications at:
    echo   - Backend:   http://localhost:8000
    echo   - Frontend:  http://localhost:3000
    echo   - MinIO:     http://localhost:9001 (admin/minioadmin^)
    echo   - n8n:       http://localhost:5678 (admin/admin^)
    echo   - MailPit:   http://localhost:8025
    goto :success
)

if "%COMMAND%"=="stop" (
    echo [*] Stopping all services...
    docker-compose stop
    goto :success
)

if "%COMMAND%"=="restart" (
    echo [*] Restarting all services...
    docker-compose restart
    timeout /t 2 /nobreak
    docker-compose ps
    goto :success
)

if "%COMMAND%"=="logs" (
    echo [*] Showing logs from all services...
    docker-compose logs -f
    goto :success
)

if "%COMMAND%"=="logs-backend" (
    echo [*] Showing backend logs...
    docker-compose logs -f backend
    goto :success
)

if "%COMMAND%"=="ps" (
    echo [*] Listing running services...
    docker-compose ps
    goto :success
)

if "%COMMAND%"=="clean" (
    echo [*] Stopping and removing containers...
    docker-compose down
    echo [OK] Containers removed. Data preserved.
    goto :success
)

if "%COMMAND%"=="reset" (
    echo.
    echo [WARNING] This will remove ALL containers, volumes, and cached data!
    echo.
    set /p confirm="Are you sure? (yes/no): "
    if /i "%confirm%"=="yes" (
        echo [*] Removing everything...
        docker-compose down -v
        echo [OK] Complete reset done.
    ) else (
        echo [CANCELLED] Reset cancelled.
    )
    goto :success
)

if "%COMMAND%"=="init-db" (
    echo [*] Running database migrations...
    docker-compose exec backend php artisan migrate --force
    goto :success
)

if "%COMMAND%"=="seed-db" (
    echo [*] Seeding database...
    docker-compose exec backend php artisan db:seed
    goto :success
)

if "%COMMAND%"=="clear-cache" (
    echo [*] Clearing Laravel cache...
    docker-compose exec backend php artisan cache:clear
    docker-compose exec backend php artisan config:clear
    docker-compose exec backend php artisan route:clear
    echo [OK] Cache cleared.
    goto :success
)

if "%COMMAND%"=="shell" (
    echo [*] Accessing backend container shell...
    docker-compose exec backend /bin/sh
    goto :success
)

if "%COMMAND%"=="status" (
    echo [*] Checking services status...
    echo.
    docker-compose ps
    echo.
    echo [*] Service health check:
    echo.
    
    echo Checking Backend...
    curl -s http://localhost:8000/api/health > nul
    if !errorlevel! equ 0 (
        echo   [OK] Backend is healthy
    ) else (
        echo   [ERROR] Backend is down
    )
    
    echo Checking Database...
    docker-compose exec mysql mysqladmin ping -h localhost > nul 2>&1
    if !errorlevel! equ 0 (
        echo   [OK] MySQL is healthy
    ) else (
        echo   [ERROR] MySQL is down
    )
    
    echo Checking Redis...
    docker-compose exec redis redis-cli ping > nul 2>&1
    if !errorlevel! equ 0 (
        echo   [OK] Redis is healthy
    ) else (
        echo   [ERROR] Redis is down
    )
    
    echo Checking MinIO...
    curl -s http://localhost:9000/minio/health/live > nul 2>&1
    if !errorlevel! equ 0 (
        echo   [OK] MinIO is healthy
    ) else (
        echo   [ERROR] MinIO is down
    )
    
    goto :success
)

echo [ERROR] Unknown command: %COMMAND%
echo Run "docker-start.bat" without arguments to see available commands.
exit /b 1

:success
echo.
echo [OK] Command executed successfully.
echo.
exit /b 0

:end
