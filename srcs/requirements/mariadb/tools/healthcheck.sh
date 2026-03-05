#!/bin/bash
set -euo pipefail

# Verifies:
#  - root can run queries
#  - the WordPress database exists
#  - the WordPress DB admin user can connect to that database

MYSQL_ROOT_PASSWORD=$(cat "/run/secrets/mysql_root_password")
MYSQL_WP_PASSWORD=$(cat "/run/secrets/mysql_wp_db_admin_password")

if [ -z "$WP_DB_NAME" ] || [ -z "$WP_DB_ADMIN" ]; then
    echo "Environment variables WP_DB_NAME and WP_DB_ADMIN must be set." >&2
    exit 1
fi

# Wait for the server to be reachable
echo "Healthcheck: waiting for mysqld to become available..."
timeout=30
i=$timeout
while [ "$i" -gt 0 ]; do
    if mysqladmin ping -u root -p"${MYSQL_ROOT_PASSWORD}" >/dev/null 2>&1; then
        echo "mysqld reachable"
        break
    fi
    sleep 1
    i=$((i - 1))
done
if [ "$i" -eq 0 ]; then
    echo "mysqld not reachable after ${timeout} seconds" >&2
    exit 1
fi

# Verify mysql is accessible with root
echo "Healthcheck: verifying root DB access..."
if ! mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; then
    echo "Root user cannot execute queries." >&2
    exit 1
fi

# Verify database exists
echo "Healthcheck: checking database '${WP_DB_NAME}' exists..."
DB_EXISTS=$(mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -N -s -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${WP_DB_NAME}';") || true
if [ "${DB_EXISTS}" != "${WP_DB_NAME}" ]; then
    echo "Database '${WP_DB_NAME}' not found yet." >&2
    exit 1
fi

# Verify WordPress database user can access the database
echo "Healthcheck: verifying WP DB user '${WP_DB_ADMIN}' can access '${WP_DB_NAME}'..."
if mysql -u "${WP_DB_ADMIN}" -p"${MYSQL_WP_PASSWORD}" "${WP_DB_NAME}" -e "SELECT 1;" >/dev/null 2>&1; then
    echo "Service is UP"
    exit 0
else
    echo "WP DB admin user cannot access database '${WP_DB_NAME}'." >&2
    exit 1
fi
