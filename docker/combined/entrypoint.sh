#!/bin/sh
set -e

# Start php-fpm in the background, then run nginx in the foreground so the
# container's lifecycle tracks the web server. Forward SIGTERM to both.
php-fpm --daemonize --pid /run/php-fpm.pid

term() {
    [ -f /run/php-fpm.pid ] && kill -TERM "$(cat /run/php-fpm.pid)" 2>/dev/null || true
    [ -f /run/nginx.pid ] && kill -TERM "$(cat /run/nginx.pid)" 2>/dev/null || true
}
trap term TERM INT

exec nginx
