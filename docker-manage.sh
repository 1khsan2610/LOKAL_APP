#!/bin/bash

# LOKAL APP - Docker Management Script

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker tidak terinstall. Silakan download dari https://www.docker.com/products/docker-desktop/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose tidak terinstall."
        exit 1
    fi
    
    print_success "Docker sudah terinstall"
}

# Main menu
show_menu() {
    echo ""
    print_header "LOKAL APP - Docker Management"
    echo "1. Build dan Start Services"
    echo "2. Start Services"
    echo "3. Stop Services"
    echo "4. View Logs (all services)"
    echo "5. View Logs (backend)"
    echo "6. View Logs (frontend)"
    echo "7. View Logs (mysql)"
    echo "8. Run Database Migration"
    echo "9. Run Database Seeder"
    echo "10. Access MySQL CLI"
    echo "11. Access Backend Bash"
    echo "12. Clear Backend Cache"
    echo "13. Show Service Status"
    echo "14. Clean Up & Remove Everything"
    echo "15. Exit"
    echo ""
    read -p "Pilih opsi (1-15): " choice
}

# Build and start
build_and_start() {
    print_header "Building Docker Images"
    docker-compose build
    print_success "Build selesai"
    
    print_header "Starting Services"
    docker-compose up -d
    print_success "Services berhasil distart"
    
    echo ""
    print_header "Checking Services Status"
    docker-compose ps
    
    echo ""
    print_warning "Tunggu 10 detik untuk database selesai initialize..."
    sleep 10
    
    print_header "Running Database Migration"
    docker-compose exec -T backend php artisan migrate --force
    print_success "Migration selesai"
}

# Start services
start_services() {
    print_header "Starting Services"
    docker-compose up -d
    print_success "Services berhasil distart"
    docker-compose ps
}

# Stop services
stop_services() {
    print_header "Stopping Services"
    docker-compose stop
    print_success "Services berhasil dihentikan"
}

# View logs
view_logs() {
    print_header "Logs - All Services (Press Ctrl+C to exit)"
    docker-compose logs -f
}

view_backend_logs() {
    print_header "Logs - Backend (Press Ctrl+C to exit)"
    docker-compose logs -f backend
}

view_frontend_logs() {
    print_header "Logs - Frontend Web (Press Ctrl+C to exit)"
    docker-compose logs -f frontend_web
}

view_mysql_logs() {
    print_header "Logs - MySQL (Press Ctrl+C to exit)"
    docker-compose logs -f mysql
}

# Database migration
run_migration() {
    print_header "Running Database Migration"
    docker-compose exec -T backend php artisan migrate
    print_success "Migration selesai"
}

# Database seeder
run_seeder() {
    print_header "Running Database Seeder"
    docker-compose exec -T backend php artisan db:seed
    print_success "Seeder selesai"
}

# MySQL CLI
access_mysql() {
    print_header "Accessing MySQL CLI"
    docker-compose exec mysql mysql -u appuser -p lokal_app
}

# Backend bash
access_backend_bash() {
    print_header "Accessing Backend Bash"
    docker-compose exec backend bash
}

# Clear cache
clear_cache() {
    print_header "Clearing Backend Cache"
    docker-compose exec -T backend php artisan cache:clear
    docker-compose exec -T backend php artisan config:clear
    docker-compose exec -T backend php artisan route:clear
    print_success "Cache berhasil dihapus"
}

# Status
show_status() {
    print_header "Service Status"
    docker-compose ps
}

# Cleanup
cleanup() {
    print_warning "Ini akan menghapus semua containers, images, dan volumes!"
    read -p "Lanjutkan? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        print_header "Removing Services"
        docker-compose down -v --rmi all
        print_success "Cleanup selesai"
    else
        print_warning "Dibatalkan"
    fi
}

# Main loop
check_docker

while true; do
    show_menu
    
    case $choice in
        1) build_and_start ;;
        2) start_services ;;
        3) stop_services ;;
        4) view_logs ;;
        5) view_backend_logs ;;
        6) view_frontend_logs ;;
        7) view_mysql_logs ;;
        8) run_migration ;;
        9) run_seeder ;;
        10) access_mysql ;;
        11) access_backend_bash ;;
        12) clear_cache ;;
        13) show_status ;;
        14) cleanup ;;
        15) echo "Terima kasih!"; exit 0 ;;
        *) print_error "Opsi tidak valid" ;;
    esac
done
