ARG HYPERF_VERSION=latest

FROM hyperf/hyperf:${HYPERF_VERSION}

LABEL maintainer="Tamadock"

ENV APP_ENV=prod \
    SCAN_CACHEABLE=true \
    COMPOSER_ALLOW_SUPERUSER=1 \
    HYPERF_APP_PATH=/var/www/troy \
    HYPERF_START_COMMAND=server:watch

WORKDIR /var/www

ARG INSTALL_RDKAFKA=false
ARG INSTALL_GRPC=false
ARG INSTALL_PROTOBUF=false
ARG INSTALL_XLS_WRITER=false
ARG INSTALL_AHOCORASICK=false

RUN set -eux; \
    PHP_BUILD_VERSION="$(php -r 'echo PHP_MAJOR_VERSION . PHP_MINOR_VERSION;')"; \
    PHP_CONF_DIR="/etc/php${PHP_BUILD_VERSION}/conf.d"; \
    apk add --no-cache \
        "php${PHP_BUILD_VERSION}-exif" \
        "php${PHP_BUILD_VERSION}-intl" \
        "php${PHP_BUILD_VERSION}-mysqli" \
        "php${PHP_BUILD_VERSION}-pdo_pgsql" \
        "php${PHP_BUILD_VERSION}-pgsql" \
        git; \
    if [ "${INSTALL_RDKAFKA}" = true ]; then \
        apk add --no-cache librdkafka; \
    fi; \
    if [ "${INSTALL_PROTOBUF}" = true ]; then \
        apk add --no-cache protobuf-dev; \
    fi; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        librdkafka-dev; \
    ln -sf "/usr/bin/phpize${PHP_BUILD_VERSION}" /usr/local/bin/phpize; \
    ln -sf "/usr/bin/php-config${PHP_BUILD_VERSION}" /usr/local/bin/php-config; \
    ln -sf "/usr/bin/pecl${PHP_BUILD_VERSION}" /usr/local/bin/pecl; \
    if [ "${INSTALL_RDKAFKA}" = true ]; then \
        pecl install rdkafka; \
        echo "extension=rdkafka.so" > "${PHP_CONF_DIR}/30_rdkafka.ini"; \
        php -m | grep -q '^rdkafka$'; \
    fi; \
    if [ "${INSTALL_GRPC}" = true ]; then \
        pecl install grpc; \
        echo "extension=grpc.so" > "${PHP_CONF_DIR}/30_grpc.ini"; \
        php -m | grep -q '^grpc$'; \
    fi; \
    if [ "${INSTALL_PROTOBUF}" = true ]; then \
        pecl install protobuf; \
        echo "extension=protobuf.so" > "${PHP_CONF_DIR}/30_protobuf.ini"; \
        php -m | grep -q '^protobuf$'; \
    fi; \
    if [ "${INSTALL_XLS_WRITER}" = true ]; then \
        pecl install xlswriter; \
        echo "extension=xlswriter.so" > "${PHP_CONF_DIR}/30_xlswriter.ini"; \
        php -m | grep -q '^xlswriter$'; \
    fi; \
    if [ "${INSTALL_AHOCORASICK}" = true ]; then \
        git clone --depth 1 https://git.papamk.com/packagist/aho-corasick.git /tmp/aho-corasick; \
        cd /tmp/aho-corasick; \
        ./build.sh; \
        cp .libs/ahocorasick.so "$(php-config --extension-dir)/ahocorasick.so"; \
        echo "extension=ahocorasick.so" > "${PHP_CONF_DIR}/40_ahocorasick.ini"; \
        php -m | grep -q '^ahocorasick$'; \
    fi; \
    apk del .build-deps; \
    rm -rf /var/cache/apk/* /tmp/* /usr/share/man

EXPOSE 9501

ENTRYPOINT ["sh", "-c", "exec php \"${HYPERF_APP_PATH}/bin/hyperf.php\" ${HYPERF_START_COMMAND}"]
