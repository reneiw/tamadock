
FROM phusion/baseimage:bionic-1.0.0

LABEL org.opencontainers.image.authors="chenzheyu@wufeng-network.com"

USER root

COPY run-certbot.sh /root/certbot/run-certbot.sh

RUN curl https://get.acme.sh | sh -s email=${EMAIL}

ENTRYPOINT bash -c "bash /root/certbot/run-certbot.sh && sleep infinity"