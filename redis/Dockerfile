ARG REDIS_VERSION=latest
FROM valkey/valkey:${REDIS_VERSION}

VOLUME /data

COPY redis.conf /usr/local/etc/redis/redis.conf

EXPOSE 6379

CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]