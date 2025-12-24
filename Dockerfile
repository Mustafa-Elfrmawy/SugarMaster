# ========================================
#   Dockerfile - PHP 8.3 FPM for Laravel
# ========================================

FROM php:8.3-fpm
# RUN sed -i 's/deb.debian.org/ftp.de.debian.org/g' /etc/apt/sources.list.d/debian.sources
# إعداد مسار العمل الافتراضي
WORKDIR /var/www/SugarMaster

# السماح لـ composer بالعمل كمستخدم root
ENV COMPOSER_ALLOW_SUPERUSER=1

# ========================================
#   تثبيت الحزم الأساسية والإضافات
# ========================================
RUN apt-get update && apt-get install -y \
    bash \
    default-mysql-client \
    libicu-dev \
    libonig-dev \
    libzip-dev \
    zip \
    curl \
    git \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    imagemagick \
    libmagickwand-dev \
    linux-headers-amd64 \
    autoconf \
    dpkg-dev \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkg-config \
    re2c \
    $PHPIZE_DEPS \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd intl pdo_mysql bcmath zip sockets mbstring \
    && pecl install redis imagick \
    && docker-php-ext-enable redis imagick \
    && apt-get remove -y autoconf dpkg-dev file g++ gcc libc-dev make pkg-config re2c linux-headers-amd64 \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*



# ========================================
#   تثبيت Composer
# ========================================
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ========================================
#   ضبط المستخدم والصلاحيات
# ========================================

# تأكد أن UID و GID يطابقوا المستخدم على النظام المضيف
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# إنشاء مجلد المشروع والمجلدات الفرعية وضبط الصلاحيات
# RUN mkdir -p /var/www/backend/public/tempQrCode \
#     && chown -R www-data:www-data /var/www \
#     && chmod -R 775 /var/www \
#     && find /var/www -type d -exec chmod g+s {} \;

# تأكد من تطبيق umask بشكل دائم لكل جلسة
# RUN echo "umask 0002" >> /etc/profile

# ========================================
#   تشغيل الخدمة كمستخدم www-data
# ========================================
USER www-data

CMD ["php-fpm"]
