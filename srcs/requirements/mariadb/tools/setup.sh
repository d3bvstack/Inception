#!/bin/bash
set -euo pipefail

# Paths
TEMPLATE=/etc/mysql/mariadb.conf.d/99-custom.cnf.tmpl
TARGET_DIR=/etc/mysql/mariadb.conf.d
TARGET_CONF="$TARGET_DIR/99-custom.cnf"

# Source secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
WP_DB_ADMIN_PASSWORD=$(cat /run/secrets/mysql_wp_db_admin_password)

# env substitution from my.cnf.tmpl to my.cnf
if [ -f "$TEMPLATE" ]; then
    echo "Config template \"$TEMPLATE\" found"
    echo "Generating config file \"$TARGET_CONF\""
    envsubst '\${MDB_CHARSET} \${MDB_COLLATION} \${MDB_ENGINE_PORT}' < "$TEMPLATE" > "$TARGET_CONF"
    rm -f "$TEMPLATE"
else
    if [ -f "$TARGET_CONF" ]; then
        echo "No template found at $TEMPLATE, using existing $TARGET_CONF"
    else
        echo "No template found at $TEMPLATE and $TARGET_CONF does not exist — continuing without custom config"
    fi
fi

# Check if directory exists, which means database not initialized yet
if [ ! -d "/var/lib/mysql/mysql" ]; then
    if command -v mariadb-install-db >/dev/null 2>&1; then
        echo "Initializing MariaDB"
        mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
    else
        echo "No database initialization command found." >&2
        exit 1
    fi
fi

# Ensure MariaDB log directory exists so mariadbd can create mariadb.log
mkdir -p /var/log/mariadb
chown -R mysql:mysql /var/log/mariadb

# Start server with mysql server and no networking on background and save process id
/usr/sbin/mariadbd \
    --user=mysql \
    --datadir=/var/lib/mysql \
    --skip-networking > /var/log/mariadb_startup.log 2>&1 &
pid=$!

# Tries mysql ping command for 60 seconds, if successful, break and contiue, else exit
i=60
while [ "$i" -gt 0 ]; do
    if mysqladmin ping >/dev/null 2>&1; then
		echo "MariaDB started"
        break
    fi
    sleep 1
    i=$((i - 1))
done
if [ "$i" -eq 0 ]; then
    echo "MariaDB not reachable"
    echo "Stopping temporary server (if running)..."
    if [ -n "${pid:-}" ]; then
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    fi
    exit 1
fi

# Same as mysql_secure_installation but non-interactive
# Give/change root password
# Disallow remote root login
# Remove anonymous user
# Delete test database
# Reload privilige tables
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DROP USER IF EXISTS ''@'localhost';
DROP USER IF EXISTS ''@'$(hostname)';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

# Create database and admin user of that databse
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${WP_DB_NAME}\` CHARACTER SET ${WP_DB_CHARSET} COLLATE ${WP_DB_COLLATION};
CREATE USER IF NOT EXISTS '${MDB_ADMIN}'@'%' IDENTIFIED BY '${WP_DB_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${WP_DB_NAME}\`.* TO '${MDB_ADMIN}'@'%';
FLUSH PRIVILEGES;
EOF

# Shutdown temporary-setup instance
echo "Shutting down temporary instance..."
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
wait $pid

# Start definitive MariaDB instance
echo "Starting main MariaDB instane..."
exec /usr/sbin/mariadbd --user=mysql --datadir=/var/lib/mysql