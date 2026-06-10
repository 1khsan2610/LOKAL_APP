# Stage 1: Build dependencies
FROM php:8.1-fpm-alpine as builder

# Install system dependencies
RUN apk add --no-cache \
    curl \
    git \
    libzip-dev \
    zip

# Install PHP extensions
RUN docker-php-ext-install \
    zip \
    pdo \
    pdo_mysql \
    bcmath \
    ctype \
    fileinfo \
    json \
    tokenizer \
    xml

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy composer files
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-interaction --no-progress --no-dev --prefer-dist

# Stage 2: Runtime
FROM php:8.1-fpm-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    libzip \
    nginx \
    supervisor

# Install PHP extensions
RUN docker-php-ext-install \
    zip \
    pdo \
    pdo_mysql \
    bcmath \
    ctype \
    fileinfo \
    json \
    tokenizer \
    xml

# Configure PHP
COPY config/php.ini /usr/local/etc/php/php.ini

# Create app user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copy application files
COPY --from=builder /app/vendor ./vendor
COPY . .

# Copy config files
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/supervisord.conf /etc/supervisord.conf

# Set permissions
RUN chown -R appuser:appuser /app && \
    mkdir -p storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Create log directories
RUN mkdir -p storage/logs && \
    chown -R appuser:appuser storage/logs

# Expose port
EXPOSE 9000 80

# Run supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
