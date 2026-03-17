#!/bin/bash
set -euo pipefail

# Paths
NGINX_CONF=/nginx-docker/conf/nginx.conf
NGINX_CONF_TARGET=/etc/nginx/nginx.conf

if [ -f "$NGINX_CONF" ]; then
    echo "Nginx config file \"$NGINX_CONF\" found"
    echo "Moving to \"$NGINX_CONF_TARGET\""
    mv -f $NGINX_CONF $NGINX_CONF_TARGET
elif [ -f "$NGINX_CONF_TARGET" ]; then
    echo "Using config at $NGINX_CONF_TARGET"
else
    echo "ERROR: No existing Nginx config at $NGINX_CONF"
    exit 1
fi

TEMPLATE=/nginx-docker/conf/server.conf.tmpl
TARGET_DIR=/etc/nginx/conf.d
TARGET_CONF="$TARGET_DIR/$DOMAIN_NAME.conf"

# Substitute only the intended environment variables in the template (if present).
# Using a variable list prevents envsubst from replacing nginx variables like
# $base, $uri, $args, $fastcgi_script_name, etc.
if [ -f "$TEMPLATE" ]; then
    echo "Config template \"$TEMPLATE\" found"
    echo "Generating config file \"$TARGET_CONF\""
    # Only substitute these environment variables. Adjust list if you add more.
    envsubst '\${DOMAIN_NAME} \${NGINX_LISTEN_PORT} \${NGINX_HOST_PORT} \${CERT_NAME} \${KEY_NAME} \${CERT_PATH} \${KEY_PATH} \${WEB_DATA} \${WP_CONTAINER_NAME} \${PHPFPM_HOST} \${PHPFPM_LISTEN_PORT}' < "$TEMPLATE" > "$TARGET_CONF"
    rm -rf "$TEMPLATE"
else
    echo "No template found at $TEMPLATE"
    if [ -f "$TARGET_CONF" ]; then
        echo "Config \"$TARGET_CONF\" found, continuing (container restart)"
    else
        echo "ERROR: No template and no existing config at $TARGET_CONF"
        exit 1
    fi
fi

# Validate nginx configuration before starting
if /usr/sbin/nginx -t >/dev/null 2>&1; then
    echo "nginx configuration test: OK"
else
    echo "nginx configuration test: FAILED"
    /usr/sbin/nginx -t || true
    exit 1
fi

exec /usr/sbin/nginx