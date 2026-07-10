# Gunakan base image PHP 8.2 FPM
FROM php:8.4-fpm

# 1. Update sistem dan install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libgd-dev \
    nginx \
    supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Install PHP Extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# 3. Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# 4. Install Composer (diambil dari image resmi)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Buat direktori yang dibutuhkan agar supervisord tidak error
RUN mkdir -p /var/log/php-fpm /var/log/nginx /var/log/supervisor /var/run/php /var/lib/nginx/tmp

# 6. Set Working Directory
WORKDIR /var/www/html

# 7. Copy seluruh source code
COPY . .

# 8. Berikan permission ke folder penyimpanan agar bisa diakses Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 9. Copy konfigurasi Supervisord dan Nginx ke dalam container
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# 10. Expose port 80 untuk web
EXPOSE 80

# 11. Jalankan Supervisord untuk memanajemen Nginx, PHP-FPM, dan Queue
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]