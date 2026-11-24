FROM debian:12.15

RUN apt-get update && apt-get install -y --no-install-recommends \
        php8.2-fpm php8.2-mysql php8.2-curl php8.2-gd php8.2-mbstring \
        php8.2-xml php8.2-zip php8.2-intl \
        mariadb-client wget sudo ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY tools/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && mkdir -p /run/php /var/www/html \
    && sed -i 's|^error_log = .*|error_log = /proc/self/fd/2|' /etc/php/8.2/fpm/php-fpm.conf

WORKDIR /var/www/html
EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
