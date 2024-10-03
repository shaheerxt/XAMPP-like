FROM php:7.4-apache

# Install dependencies first
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    libvpx-dev \
    libzip-dev \
    libicu-dev \
    libxslt1-dev \
    libmagickwand-dev --no-install-recommends \
    libonig-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install and configure GD
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-xpm --with-webp \
    && docker-php-ext-install -j$(nproc) gd

# Install remaining extensions that are not part of the core
RUN docker-php-ext-install -j$(nproc) \
    ffi \
    fileinfo \
    filter \
    ftp \
    gettext \
    iconv \
    intl \
    mbstring \
    bcmath \
    calendar \
    ctype \
    curl \
    exif \
    mysqli \
    pcntl \
    pdo_mysql \
    posix \
    shmop \
    simplexml \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    tokenizer \
    zip \
    opcache

# Install additional PHP extensions using PECL
RUN pecl install redis imagick igbinary && docker-php-ext-enable redis imagick igbinary

# Enable Apache modules
RUN a2enmod rewrite

# Set recommended PHP settings
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Verify installed PHP modules
RUN php -m
