FROM php:8.4-fpm-bullseye

# Network tooling required by the looking glass + nginx web server + supervisor.
RUN apt-get update && \
    apt-get --no-install-recommends -y install \
        iputils-ping mtr traceroute iproute2 libfcgi-bin \
        nginx && \
    rm -rf /var/lib/apt/lists/*

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/html

# Application code and container config.
COPY --chown=www-data:www-data . .
COPY docker/php-fpm/src/config.php config.php

# Combined web stack config and entrypoint.
COPY docker/combined/nginx.conf /etc/nginx/nginx.conf
COPY docker/combined/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

HEALTHCHECK --start-period=20s --interval=30s --timeout=3s --retries=5 \
    CMD cgi-fcgi -bind -connect localhost:9000 >/dev/null 2>&1 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
