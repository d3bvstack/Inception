#!/bin/bash
set -e # Fail fast if any command returns non-zero

# Substitute environment variables in /etc/nginx/conf.d/server.conf.tmpl
if [ -f /etc/nginx/conf.d/server.conf.tmpl ]; then
    echo "Config template \"template.nginx.conf\" found"
    if [ ! -f /etc/nginx/conf.d/${}.conf ]; then
        echo "Config file \"nginx.conf\" not found, creating it"
        envsubst \
            < /etc/nginx/conf.d/server.conf.tmpl \
            > /etc/nginx/conf.d/${DOMAIN_NAME}.conf
    else
        echo "Config file \"nginx.conf\" already created"
    fi
fi

# Start/reload nginx
/usr/sbin/nginx