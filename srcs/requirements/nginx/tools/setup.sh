#!/bin/bash
set -euo pipefail

# Paths
TEMPLATE=/etc/nginx/conf.d/server.conf.tmpl
TARGET_DIR=/etc/nginx/conf.d
TARGET_CONF="$TARGET_DIR/$DOMAIN_NAME.conf"

# Substitute only the intended environment variables in the template (if present).
# Using a variable list prevents envsubst from replacing nginx variables like
# $base, $uri, $args, $fastcgi_script_name, etc.
if [ -f "$TEMPLATE" ]; then
    echo "Config template \"$TEMPLATE\" found"
    echo "Generating config file \"$TARGET_CONF\""
    # Only substitute these environment variables. Adjust list if you add more.
    envsubst '\${DOMAIN_NAME} \${NGINX_LISTEN_PORT} \${NGINX_HOST_PORT} \${CERT_NAME} \${KEY_NAME} \${CERT_PATH} \${KEY_PATH} \${WEB_DATA} \${WP_CONTAINER_NAME} \${PHPFPM_LISTEN_PORT}' < "$TEMPLATE" > "$TARGET_CONF"
else
    echo "No template found at $TEMPLATE, skipping envsubst"
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