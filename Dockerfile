FROM quay.io/venezia/alpine:3.13

LABEL description "Rainloop is a simple, modern & fast web-based client" \
      maintainer="Michael Venezia <mvenezia@gmail.com>"

ARG GPG_FINGERPRINT="3B79 7ECE 694F 3B7B 70F3  11A4 ED7C 49D9 87DA 4591"
ARG RAINLOOP_VERSION="1.15.0"

ENV UID=991 GID=991 UPLOAD_MAX_SIZE=25M LOG_TO_STDOUT=false MEMORY_LIMIT=128M

#RUN echo "@community https://nl.alpinelinux.org/alpine/v3.10/community" >> /etc/apk/repositories \
RUN apk -U upgrade \
 && apk add -t build-dependencies \
    gnupg \
    openssl \
    wget \
 && apk add \
    ca-certificates \
    nginx \
    s6 \
    su-exec \
    php8-fpm \
    php8-curl \
    php8-iconv \
    php8-xml \
    php8-dom \
    php8-openssl \
    php8-json \
    php8-zlib \
    php8-pdo_pgsql \
    php8-pdo_mysql \
    php8-pdo_sqlite \
    php8-sqlite3 \
    php8-ldap \
    php8-simplexml \
 && cd /tmp \
 && wget https://github.com/RainLoop/rainloop-webmail/releases/download/v${RAINLOOP_VERSION}/rainloop-${RAINLOOP_VERSION}.zip \
 && wget https://github.com/RainLoop/rainloop-webmail/releases/download/v${RAINLOOP_VERSION}/rainloop-${RAINLOOP_VERSION}.zip.asc \
 && wget https://www.rainloop.net/repository/RainLoop.asc \
 && gpg --import RainLoop.asc \
 && FINGERPRINT="$(LANG=C gpg --verify rainloop-${RAINLOOP_VERSION}.zip.asc rainloop-${RAINLOOP_VERSION}.zip 2>&1 \
  | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")" \
 && if [ -z "${FINGERPRINT}" ]; then echo "ERROR: Invalid GPG signature!" && exit 1; fi \
 && if [ "${FINGERPRINT}" != "${GPG_FINGERPRINT}" ]; then echo "ERROR: Wrong GPG fingerprint!" && exit 1; fi \
 && mkdir /rainloop && unzip -q /tmp/rainloop-${RAINLOOP_VERSION}.zip -d /rainloop \
 && find /rainloop -type d -exec chmod 755 {} \; \
 && find /rainloop -type f -exec chmod 644 {} \; \
 && apk del build-dependencies \
 && rm -rf /tmp/* /var/cache/apk/* /root/.gnupg

COPY rootfs /
RUN chmod +x /usr/local/bin/run.sh /services/*/run /services/.s6-svscan/*
VOLUME /rainloop/data
EXPOSE 8888
CMD ["run.sh"]
