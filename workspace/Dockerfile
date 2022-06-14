ARG PHP_VERSION

FROM php:8.1-cli-alpine3.16

LABEL org.opencontainers.image.authors="chenzheyu@wufeng-network.com"

# Start as root
USER root

RUN apk --update add $PHPIZE_DEPS autoconf build-base linux-headers libressl-dev libmcrypt-dev libressl libxml2-dev libzip-dev oniguruma-dev pcre-dev zlib-dev \
  wget bash curl sudo \
  libzip \
  freetype-dev libjpeg-turbo-dev jpeg-dev libpng-dev \
  nodejs npm yarn git \
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
# PHP SOCKETS:
###########################################################################

USER root

ARG INSTALL_SOCKETS=false
# in 8.1.2 alpine docker must add this env
ENV CFLAGS="$CFLAGS -D_GNU_SOURCE"

RUN if [ ${INSTALL_SOCKETS} = true ]; then \
    docker-php-ext-install sockets \
    && php -m | grep -q 'sockets' \
;fi


###########################################################################
# xlswriter:
###########################################################################

ARG INSTALL_XLS_WRITER=false

RUN if [ ${INSTALL_XLS_WRITER} = true ]; then \
  pecl install xlswriter \
  && docker-php-ext-enable xlswriter \
;fi

RUN curl -s https://getcomposer.org/installer | php \
        && echo "export PATH=${PATH}:/var/www/backend/vendor/bin" >> ~/.bashrc \
        && mv composer.phar /usr/local/bin/composer

ARG TZ=UTC
ENV TZ ${TZ}

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


RUN rm -rf /tmp/pear \
  && rm /var/cache/apk/* \
  && mkdir -p /var/www



ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN addgroup -g ${PGID} tamadock && \
  adduser -D -G tamadock -u ${PUID} tamadock

WORKDIR /var/www
