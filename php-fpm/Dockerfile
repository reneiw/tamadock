ARG PHP_VERSION
ARG DEBIAN_VERSION

FROM php:${PHP_VERSION}-fpm-${DEBIAN_VERSION}

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

# Start as root
USER root

RUN set -xe; \
    apt-get update -yqq && \
    apt-get upgrade -y; \
    pecl channel-update pecl.php.net && \
    apt-get install -yqq \
    apt-utils \
    curl \
    gnupg2 \
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
    libonig-dev \
    libzip-dev zip unzip && \
    docker-php-ext-configure zip && docker-php-ext-install zip && \
    pecl install -o -f redis && docker-php-ext-enable redis && \
    docker-php-ext-install bcmath exif mysqli opcache pcntl pdo_mysql pdo_pgsql pgsql;\
    docker-php-ext-configure gd \
      --prefix=/usr \
      --with-jpeg \
      --with-webp \
      --with-xpm \
      --with-freetype; \
    docker-php-ext-install gd; 

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
# in 8.1.2 alpine docker must add this env
ENV CFLAGS="$CFLAGS -D_GNU_SOURCE"

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
  pecl install xdebug-3.1.3 \
  && docker-php-ext-enable xdebug \
  ;fi

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
