ARG PHP_VERSION=8.3
ARG DEBIAN_VERSION=bookworm

FROM php:${PHP_VERSION}-fpm-${DEBIAN_VERSION}

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive


# Start as root
USER root

RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
            curl \
            git \
            libcurl4-openssl-dev \
            libfreetype6-dev \
            libicu-dev \
            libjpeg-dev \
            liblz4-dev \
            libmemcached-dev \
            libonig-dev \
            libpng-dev \
            libpq-dev \
            libreadline-dev \
            libsqlite3-dev \
            libssl-dev \
            libwebp-dev \
            libxpm-dev \
            libxml2-dev \
            libz-dev \
            libzip-dev \
            unixodbc-dev \
            zip \
            unzip;

RUN set -eux; \
    pecl channel-update pecl.php.net; \
    install_php_ext() { \
      extension="$1"; \
      if ! php -m | grep -qi "^${extension}$"; then \
        docker-php-ext-install -j"$(nproc)" "${extension}"; \
      fi; \
    }; \
    for extension in \
      bcmath curl dom exif fileinfo intl mbstring mysqli pcntl \
      pdo_mysql pdo_pgsql pdo_sqlite pgsql readline simplexml sockets \
      sysvmsg sysvsem sysvshm xml xmlreader xmlwriter zip; do \
      install_php_ext "${extension}"; \
    done; \
    if ! php -m | grep -qi 'pdo_odbc'; then \
      docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr && \
      docker-php-ext-install -j"$(nproc)" pdo_odbc; \
    fi; \
    docker-php-ext-configure gd \
            --prefix=/usr \
            --with-jpeg \
            --with-webp \
            --with-xpm \
            --with-freetype && \
    docker-php-ext-install -j"$(nproc)" gd && \
    pecl install -o -f -D 'enable-redis-igbinary="yes" enable-redis-lz4="yes"' igbinary redis && \
    docker-php-ext-enable igbinary redis && \
    if ! php -m | grep -qi '^msgpack$'; then \
      pecl install msgpack && docker-php-ext-enable msgpack; \
    fi; \
    php -m | grep -qi 'intl' && \
    php -m | grep -qi 'msgpack' && \
    php -m | grep -qi 'pdo_odbc' && \
    php -m | grep -qi 'pdo_pgsql' && \
    php -m | grep -qi 'sockets' && \
    php -m | grep -qi 'opcache';

###########################################################################
# PHP RDKAFKA:
###########################################################################
ARG INSTALL_RDKAFKA=false

RUN if [ ${INSTALL_RDKAFKA} = true ]; then \
  apt-get install -yqq --no-install-recommends librdkafka-dev \
  && pecl install rdkafka \
  && docker-php-ext-enable rdkafka \
  && php -m | grep -q 'rdkafka' \
;fi

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
# PHP AHOCORASICK:
###########################################################################
ARG INSTALL_AHOCORASICK=false

RUN if [ "${INSTALL_AHOCORASICK}" = true ]; then \
  git clone --depth 1 https://git.papamk.com/packagist/aho-corasick.git /tmp/aho-corasick \
  && cd /tmp/aho-corasick \
  && ./build.sh \
  && cp .libs/ahocorasick.so "$(php-config --extension-dir)/ahocorasick.so" \
  && docker-php-ext-enable ahocorasick \
  && php -m | grep -q '^ahocorasick$' \
;fi


###########################################################################
# PHP SWOOLE:
###########################################################################
ARG INSTALL_SWOOLE=false

RUN if [ "${INSTALL_SWOOLE}" = true ]; then \
  pecl install swoole \
  && docker-php-ext-enable swoole \
  && echo "swoole.use_shortname='Off'" > /usr/local/etc/php/conf.d/zz-swoole.ini \
  && php -m | grep -q '^swoole$' \
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
ENV PUID=${PUID}
ARG PGID=1000
ENV PGID=${PGID}

RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data

# Configure locale.
ARG LOCALE=POSIX
ENV LC_ALL=${LOCALE}

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000
