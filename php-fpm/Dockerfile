FROM php:8.1-fpm-alpine3.16

LABEL maintainer="Mahmoud Zalt <mahmoud@zalt.me>"

ARG LARADOCK_PHP_VERSION

USER root

RUN apk --update add $PHPIZE_DEPS autoconf build-base linux-headers libressl-dev libmcrypt-dev libressl libxml2-dev libzip-dev oniguruma-dev pcre-dev zlib-dev \
  wget bash curl sudo \
  libzip \
  freetype-dev libjpeg-turbo-dev jpeg-dev libpng-dev \
  && pecl channel-update pecl.php.net \
  && pecl install -o -f redis   && pecl install -o -f redis && docker-php-ext-enable redis \
  && docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install gd \
  && rm -rf /tmp/pear

RUN docker-php-ext-configure zip && docker-php-ext-install bcmath exif mysqli pdo_mysql opcache pcntl zip

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
ARG INSTALL_XLSWRITER=false

RUN if [ ${INSTALL_XLSWRITER} = true ]; then \
  pecl install xlswriter \
  && docker-php-ext-enable xlswriter \
;fi

###########################################################################
# Check PHP version:
###########################################################################

#RUN set -xe; php -v | head -n 1 | grep -q "PHP ${LARADOCK_PHP_VERSION}."

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

COPY ./laravel.ini /usr/local/etc/php/conf.d
COPY ./xlaravel.pool.conf /usr/local/etc/php-fpm.d/
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

USER root

# Configure non-root user.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN addgroup -g ${PGID} www && \
    adduser -D -G www -u ${PUID} www

# Configure locale.
ARG LOCALE=POSIX
ENV LC_ALL ${LOCALE}

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000
