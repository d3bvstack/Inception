#!/bin/bash
set -euo pipefail

# Defaults
WP_CMD="/usr/local/bin/wp"
WP_VERSION="${WP_VERSION:-latest}"
WWW_USER="${WWW_USER:-www-data}"
WWW_GROUP="${WWW_GROUP:-$WWW_USER}"
WWW_ROOT="/var/www/${DOMAIN_NAME}"
PHP_FPM_VERSION="8.2"

# Secrets


# Apply templated php-fpm.conf if present
PHP_FPM_CONF="/etc/php/${PHP_FPM_VERSION}/fpm/php-fpm.conf.tmpl"
TARGET_PHP_FPM="/etc/php/${PHP_FPM_VERSION}/fpm/php-fpm.conf"
NGINX_LISTEN_PORT="${NGINX_LISTEN_PORT:-9000}"
if [ -f "$PHP_FPM_CONF" ]; then
	echo "Config template \"$PHP_FPM_CONF\" found"
	echo "Generating config file \"$TARGET_PHP_FPM\""
    envsubst '\${NGINX_LISTEN_PORT}' < "$PHP_FPM_CONF" > "$TARGET_PHP_FPM" || true
else
    echo "No template found at $PHP_FPM_CONF, exiting"
	exit 1
fi


install_wp_cli() {
	if command -v wp >/dev/null 2>&1; then
		echo "wp-cli already installed"
		return
	else
		echo "Installing wp-cli"
		cd /tmp
		curl -fsSL -o wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
		chmod +x wp-cli.phar
		mv wp-cli.phar "$WP_CMD"
		chmod +x "$WP_CMD"
		return
	fi
}

main() {
	install_wp_cli

	mkdir -p "$WWW_ROOT"

	echo "Downloading WordPress ({WP_VERSION})"
	if [ "$WP_VERSION" = "latest" ]; then
		wp core download --path=${WWW_ROOT} --skip-content --force
	else
		wp core download --path=${WWW_ROOT} --version="$WP_VERSION" --skip-content --force
	fi

	echo "Generating wp-config.php"
	DB_PASS=$(cat /run/secrets/dbuser_password)
	wp --path=${WWW_ROOT} config create --dbname="${DB_NAME}" --dbuser="${DB_ADMIN}" --dbhost="${DB_HOST}:${DB_PORT}" --dbpass="$DB_PASS" --skip-check

	echo "Installing WordPress"
	ADMIN_PASS=$(cat /run/secrets/admin_password)
	wp --path=${WWW_ROOT} core install --url="${ROOT_DOMAIN}" --title="${SITE_TITLE}" --admin_user="${WP_ADMIN}" --admin_password="$ADMIN_PASS" --admin_email="${WP_ADMIN_MAIL}"

	echo "Updating plugins"
	wp --path=${WWW_ROOT} plugin update --all

	echo "Creating editor user"
	EDITOR_PASS=$(cat /run/secrets/editor_password)
	wp --path=${WWW_ROOT} user create "${WP_USER}" "${WP_USER_MAIL}" --role="${WP_USER_ROLE}" --user_pass="$EDITOR_PASS" --porcelain

	# Fix permissions
	chown -R "$WWW_USER":"$WWW_GROUP" "$WWW_ROOT"
	find "$WWW_ROOT" -type d -exec chmod 755 {} +
	find "$WWW_ROOT" -type f -exec chmod 644 {} +

	echo "WordPress setup complete"
}



