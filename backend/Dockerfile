FROM php:8.1-fpm-alpine AS builder

# Install runtime helpers and git (needed by composer), then build deps
RUN apk add --no-cache \
    curl \
    git \
    zip

RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    build-base \
    autoconf \
    libtool \
    pkgconf \
    libzip-dev \
    zlib-dev \
    libxml2-dev \
    openssl-dev \
    mariadb-dev

RUN docker-php-ext-install \
    zip \
    pdo \
    pdo_mysql \
    bcmath \
    ctype \
    dom \
    fileinfo \
    session \
    xml && \
    apk del .build-deps

RUN curl -fsSL https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm -f composer-setup.php

WORKDIR /app

# Copy composer files
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install \
    --no-interaction \
    --no-dev \
    --prefer-dist \
    --no-scripts \
    --optimize-autoloader \
    --ignore-platform-req=ext-tokenizer

# Stage 2: Runtime
FROM php:8.1-fpm-alpine

# Install runtime tools
RUN apk add --no-cache \
    curl

# Install build dependencies for PHP extensions compilation
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    libtool \
    pkgconf \
    libzip-dev \
    zlib-dev \
    libxml2-dev \
    mariadb-dev

# Install runtime dependencies
RUN apk add --no-cache \
    libzip \
    zlib \
    libxml2 \
    nginx \
    supervisor \
    curl

# Install PHP extensions
RUN docker-php-ext-install \
    zip \
    pdo \
    pdo_mysql \
    bcmath \
    ctype \
    dom \
    fileinfo \
    session \
    xml

# Remove build dependencies
RUN apk del --no-cache .build-deps

# Configure PHP
COPY config/php.ini /usr/local/etc/php/php.ini

# Create app user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copy application files
COPY --chown=appuser:appuser --from=builder /app/vendor ./vendor
COPY --chown=appuser:appuser . .

# Copy config files
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/supervisord.conf /etc/supervisord.conf

# Set permissions
RUN mkdir -p storage bootstrap/cache storage/logs && \
    chown -R appuser:appuser storage bootstrap/cache storage/logs && \
    chmod -R 775 storage bootstrap/cache storage/logs

# Create log directories
RUN mkdir -p storage/logs && \
    chown -R appuser:appuser storage/logs

# Expose port
EXPOSE 9000 80

# Run supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
