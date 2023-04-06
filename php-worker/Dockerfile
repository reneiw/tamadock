ARG PHP_VERSION

FROM php:8.1-cli-alpine3.17

LABEL org.opencontainers.image.authors="chenzheyu@wufeng-network.com"

# Start as root
USER root

RUN apk --update add $PHPIZE_DEPS autoconf build-base linux-headers libressl-dev libmcrypt-dev libressl libxml2-dev libzip-dev oniguruma-dev pcre-dev zlib-dev \
  wget bash curl \
  libzip \
  freetype-dev libjpeg-turbo-dev jpeg-dev libpng-dev \
  nodejs npm supervisor \
  && pecl channel-update pecl.php.net \
  && pecl install -o -f redis   && pecl install -o -f redis && docker-php-ext-enable redis \
  && docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install gd \
  && rm -rf /tmp/pear

RUN docker-php-ext-configure zip && docker-php-ext-install bcmath exif mysqli pcntl pdo_mysql zip


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
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN addgroup -g ${PGID} tamadock && \
  adduser -D -G tamadock -u ${PUID} tamadock

RUN rm /var/cache/apk/* \
  && mkdir -p /var/www

WORKDIR /etc/supervisor/conf.d/
