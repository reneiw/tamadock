ARG PHP_VERSION=8.3
ARG DEBIAN_VERSION=bookworm

FROM php:${PHP_VERSION}-cli-${DEBIAN_VERSION}

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive

# Start as root
USER root

RUN set -eux; \
    apt-get update -yqq && \
    apt-get upgrade -y && \
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
    unixodbc-dev \
    zip \
    unzip && \
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
# xlswriter:
###########################################################################

ARG INSTALL_XLS_WRITER=false

RUN if [ ${INSTALL_XLS_WRITER} = true ]; then \
  pecl install xlswriter \
  && docker-php-ext-enable xlswriter \
;fi


###########################################################################
# Swoole EXTENSION
###########################################################################

ARG INSTALL_SWOOLE=false

RUN if [ ${INSTALL_SWOOLE} = true ]; then \
  # Install Php Swoole Extension
  pecl install swoole \
  && docker-php-ext-enable swoole \
;fi

###########################################################################
# Node / NVM:
###########################################################################

# Check if NVM needs to be installed
ARG INSTALL_NODE=false
ARG NODE_VERSION=node
ENV NVM_DIR="/root/.nvm"

RUN if [ ${INSTALL_NODE} = true ]; then \
    # Install nvm (A Node Version Manager)
    mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install ${NODE_VERSION} \
    && nvm use ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION} \
    && npm cache clear --force && \
    echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="$NVM_DIR"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc \
;fi


RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

ARG TZ=UTC
ENV TZ=${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY ./laravel.ini /usr/local/etc/php/conf.d
COPY ./aliases.sh /root/aliases.sh
COPY ./aliases.sh /home/laradock/aliases.sh

RUN sed -i 's/\r//' /root/aliases.sh && \
  echo "" >> ~/.bashrc && \
  echo "# Load Custom Aliases" >> ~/.bashrc && \
  echo "source ~/aliases.sh" >> ~/.bashrc && \
  echo "export PS1='[\u@\h \W]$'" >> ~/.bashrc && \
  echo "" >> ~/.bashrc

USER root

# Clean up
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -f /var/log/lastlog /var/log/faillog

# Set default work directory
WORKDIR /var/www