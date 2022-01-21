ARG PHP_VERSION

FROM php:$PHP_VERSION-cli-alpine

LABEL org.opencontainers.image.authors="chenzheyu@wufeng-network.com"

# Start as root
USER root

ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN apk --update add $PHPIZE_DEPS autoconf build-base linux-headers libressl-dev libmcrypt-dev libressl libxml2-dev libzip-dev oniguruma-dev pcre-dev zlib-dev \
  wget bash curl sudo \
  libzip \
  freetype-dev libjpeg-turbo-dev jpeg-dev libpng-dev \
  nodejs npm yarn \
  && pecl channel-update pecl.php.net \
  && pecl install -o -f redis   && pecl install -o -f redis && docker-php-ext-enable redis \
  && docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install gd \
  && rm -rf /tmp/pear

RUN docker-php-ext-configure zip && docker-php-ext-install bcmath exif mysqli pcntl pdo_mysql zip

RUN curl -s https://getcomposer.org/installer | php \
        && echo "export PATH=${PATH}:/var/www/backend/vendor/bin" >> ~/.bashrc \
        && mv composer.phar /usr/local/bin/composer

###########################################################################
# PHP GRPC:
###########################################################################

USER root

ARG INSTALL_GRPC=false

RUN if [ ${INSTALL_GRPC} = true ]; then \
  pecl install grpc \
  && docker-php-ext-enable grpc \
  && php -m | grep -q 'grpc' \
;fi

###########################################################################
# PHP GRPC:
###########################################################################

USER root

ARG INSTALL_PROTOBUF=false

RUN if [ ${INSTALL_PROTOBUF} = true ]; then \
  pecl install protobuf \
  && docker-php-ext-enable protobuf \
  && php -m | grep -q 'protobuf' \
;fi

###########################################################################
# ssh:
###########################################################################

ARG INSTALL_WORKSPACE_SSH=false

COPY insecure_id_rsa /tmp/id_rsa
COPY insecure_id_rsa.pub /tmp/id_rsa.pub

RUN if [ ${INSTALL_WORKSPACE_SSH} = true ]; then \
    apk add --update --no-cache openssh \
;fi


ARG TZ=UTC
ENV TZ ${TZ}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

USER root

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


WORKDIR /var/www
