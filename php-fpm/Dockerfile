ARG PHP_VERSION=8.3
ARG DEBIAN_VERSION=bookworm

FROM php:${PHP_VERSION}-fpm-${DEBIAN_VERSION}

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

# in 8.1.2 alpine docker must add this env
ENV CFLAGS="$CFLAGS -D_GNU_SOURCE"

# Start as root
USER root

RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
            curl \
            libmemcached-dev \
            libz-dev \
            libpq-dev \
            libjpeg-dev \
            libpng-dev \
            libfreetype6-dev \
            libssl-dev \
            libwebp-dev \
            libxpm-dev \
            libmcrypt-dev \
            libonig-dev;

RUN set -eux; \
    docker-php-ext-install bcmath exif mysqli pcntl pdo_mysql pdo_pgsql pgsql; \
    # Install the PHP gd library
    docker-php-ext-configure gd \
            --prefix=/usr \
            --with-jpeg \
            --with-webp \
            --with-xpm \
            --with-freetype; \
    docker-php-ext-install gd; \
    php -r 'var_dump(gd_info());'

RUN apt-get install -yqq  libzip-dev zip unzip && \
    docker-php-ext-configure zip && docker-php-ext-install zip;

RUN apt-get install -yqq liblz4-dev && \
    pecl install -o -f -D 'enable-redis-igbinary="yes" enable-redis-lz4="yes"' igbinary redis && docker-php-ext-enable igbinary redis;

###########################################################################
# PHP GRPC:
###########################################################################
ARG INSTALL_GRPC=false

RUN if [ ${INSTALL_GRPC} = true ]; then \
  pecl channel-update pecl.php.net \
  &&  pecl install grpc \
  && docker-php-ext-enable grpc \
  && php -m | grep -q 'grpc' \
  ;fi

###########################################################################
# PHP GRPC:
###########################################################################
ARG INSTALL_PROTOBUF=false

RUN if [ ${INSTALL_PROTOBUF} = true ]; then \
  pecl channel-update pecl.php.net \
  &&  pecl install protobuf \
  && docker-php-ext-enable protobuf \
  && php -m | grep -q 'protobuf' \
  ;fi

###########################################################################
# PHP SOCKETS:
###########################################################################
ARG INSTALL_SOCKETS=false


RUN if [ ${INSTALL_SOCKETS} = true ]; then \
  docker-php-ext-install sockets \
  && php -m | grep -q 'sockets' \
  ;fi


###########################################################################
# xDebug:
###########################################################################
ARG INSTALL_XDEBUG=false

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
  # Install the xdebug extension
  # https://xdebug.org/docs/compat
  pecl install xdebug-3.4.0 \
  && docker-php-ext-enable xdebug \
  ;fi
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

###########################################################################
# xlswriter:
###########################################################################
ARG INSTALL_XLS_WRITER=false

RUN if [ ${INSTALL_XLS_WRITER} = true ]; then \
  pecl install xlswriter \
  && docker-php-ext-enable xlswriter \
  ;fi


ARG INSTALL_XHPROF=false

RUN set -eux; \
  if [ ${INSTALL_XHPROF} = true ]; then \
  # Install the php xhprof extension
  pecl install xhprof \
  && docker-php-ext-enable xhprof \
  ;fi


###########################################################################
# MongoDB:
###########################################################################

ARG INSTALL_MONGO=false

RUN if [ ${INSTALL_MONGO} = true ]; then \
  pecl install mongodb \
  && docker-php-ext-enable mongodb; \
  fi

COPY ./laravel.ini /usr/local/etc/php/conf.d
COPY ./xlaravel.pool.conf /usr/local/etc/php-fpm.d/
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -f /var/log/lastlog /var/log/faillog

# Configure non-root user.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data

# Configure locale.
ARG LOCALE=POSIX
ENV LC_ALL ${LOCALE}

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000
