ARG PHP_VERSION=8.3
ARG DEBIAN_VERSION=bookworm

FROM php:${PHP_VERSION}-cli-${DEBIAN_VERSION}

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive

# Start as root
USER root

RUN set -eux; \
    apt-get update -yqq && \
    apt-get install -yqq \
    apt-utils \
    curl \
    git \
    gnupg2 \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    liblz4-dev \
    libmcrypt-dev \
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
    nodejs \
    npm \
    openssl \
    supervisor \
    unixodbc-dev \
    unzip \
    zip && \
    pecl channel-update pecl.php.net && \
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
# PHP AHOCORASICK:
###########################################################################

ARG INSTALL_AHOCORASICK=false

RUN if [ "${INSTALL_AHOCORASICK}" = true ]; then \
    git clone --depth 1 https://git.papamk.com/packagist/aho-corasick.git /tmp/aho-corasick && \
    cd /tmp/aho-corasick && \
    ./build.sh && \
    cp .libs/ahocorasick.so "$(php-config --extension-dir)/ahocorasick.so" && \
    docker-php-ext-enable ahocorasick && \
    php -m | grep -q '^ahocorasick$'; \
  fi

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
# PHP SWOOLE:
###########################################################################
ARG INSTALL_SWOOLE=false

RUN if [ ${INSTALL_SWOOLE} = true ]; then \
      pecl install swoole \
      && docker-php-ext-enable swoole \
      && echo "swoole.use_shortname='Off'" > /usr/local/etc/php/conf.d/zz-swoole.ini \
      && php -m | grep -q 'swoole' \
;fi

###########################################################################
# PHP GRPC:
###########################################################################

ARG INSTALL_GRPC=false

RUN if [ ${INSTALL_GRPC} = true ]; then \
      pecl install grpc \
      && docker-php-ext-enable grpc \
      && php -m | grep -q 'grpc' \
;fi

###########################################################################
# PHP GRPC:
###########################################################################

ARG INSTALL_PROTOBUF=false

RUN if [ ${INSTALL_PROTOBUF} = true ]; then \
      pecl install protobuf \
      && docker-php-ext-enable protobuf \
      && php -m | grep -q 'protobuf' \
;fi


###########################################################################
# xlswriter:
###########################################################################

ARG INSTALL_XLS_WRITER=false

RUN if [ ${INSTALL_XLS_WRITER} = true ]; then \
  pecl install xlswriter \
  && docker-php-ext-enable xlswriter \
;fi

COPY supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

# Add a non-root user:
ARG PUID=1000
ENV PUID=${PUID}
ARG PGID=1000
ENV PGID=${PGID}

RUN groupadd --gid ${PGID} tamadock && \
  useradd --uid ${PUID} --gid ${PGID} --create-home --shell /bin/bash tamadock

# Clean up
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && mkdir -p /var/www

WORKDIR /etc/supervisor/conf.d/
