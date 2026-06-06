#!/bin/bash

# Platform LOKAL Backend - Setup Script
# Initializes the backend environment

set -e

echo "==========================================="
echo "Platform LOKAL Backend Setup"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ .env created${NC}"
else
    echo -e "${GREEN}✓ .env exists${NC}"
fi

# Install composer dependencies
echo -e "${YELLOW}Installing composer dependencies...${NC}"
composer install --no-interaction
echo -e "${GREEN}✓ Dependencies installed${NC}"

# Generate app key
echo -e "${YELLOW}Generating APP_KEY...${NC}"
php artisan key:generate --force
echo -e "${GREEN}✓ APP_KEY generated${NC}"

# Run migrations
echo -e "${YELLOW}Running database migrations...${NC}"
php artisan migrate --force
echo -e "${GREEN}✓ Migrations completed${NC}"

# Create storage symlink
echo -e "${YELLOW}Creating storage symlink...${NC}"
php artisan storage:link
echo -e "${GREEN}✓ Storage symlink created${NC}"

# Clear cache
echo -e "${YELLOW}Clearing caches...${NC}"
php artisan config:cache
php artisan cache:clear
echo -e "${GREEN}✓ Caches cleared${NC}"

echo ""
echo -e "${GREEN}==========================================="
echo "Backend setup completed successfully!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Update .env with your service credentials"
echo "2. Run: php artisan serve"
echo "3. API will be available at: http://localhost:8000/api/v1"
echo ""
