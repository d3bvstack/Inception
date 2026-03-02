#!/bin/sh
# Healthcheck that uses the Docker secret for root password and returns 0 on success, 1 on failure
ROOT_PW_FILE=/run/secrets/mysql_root_password
if [ -f "$ROOT_PW_FILE" ]; then
    MYSQL_ROOT_PASSWORD=$(cat "$ROOT_PW_FILE")
else
    echo "Root password secret not found at $ROOT_PW_FILE" >&2
    exit 1
fi

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Service is UP"
    exit 0
else
    echo "Service is DOWN or not responding to requests." >&2
    exit 1
fi