#!/bin/bash
set -euo pipefail

# Defaults
WP_CMD="/usr/local/bin/wp"
WP_VERSION="${WP_VERSION:-latest}"
WWW_USER="${WWW_USER:-www-data}"
WWW_GROUP="${WWW_GROUP:-$WWW_USER}"
DOMAIN_NAME="${DOMAIN_NAME:-${USER_LOGIN:-localhost}}"
ROOT_DOMAIN="${ROOT_DOMAIN:-${DOMAIN_NAME}}"
WWW_ROOT="/var/www/${DOMAIN_NAME}"
PHP_FPM_VERSION="8.2"

# Secrets
DB_PASS=$(cat /run/secrets/mysql_wp_db_admin_password)
ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)

# Apply templated php-fpm.conf if present
PHP_FPM_CONF="/etc/php/${PHP_FPM_VERSION}/fpm/php-fpm.conf.tmpl"
TARGET_PHP_FPM="/etc/php/${PHP_FPM_VERSION}/fpm/php-fpm.conf"
if [ -f "$PHP_FPM_CONF" ]; then
	echo "Config template \"$PHP_FPM_CONF\" found"
	echo "Generating config file \"$TARGET_PHP_FPM\""
	envsubst '\${NGINX_LISTEN_PORT}' < "$PHP_FPM_CONF" > "$TARGET_PHP_FPM"
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

	echo "Downloading WordPress ($WP_VERSION)"
	if [ "$WP_VERSION" = "latest" ]; then
		wp core download --path=${WWW_ROOT} --skip-content --force --allow-root
	else
		wp core download --path=${WWW_ROOT} --version="$WP_VERSION" --skip-content --force --allow-root
	fi

	wait_for_db() {
		echo "Waiting for database ${DB_HOST}:${DB_PORT} to be available..."
		local attempt=0
		# Try to open a TCP connection to the database port; works in bash
		while ! bash -c "</dev/tcp/${DB_HOST}/${DB_PORT}" >/dev/null 2>&1; do
			attempt=$((attempt + 1))
			if [ "$attempt" -ge 30 ]; then
				echo "Timed out waiting for database ${DB_HOST}:${DB_PORT}"
				return 1
			fi
			sleep 1
		done
		echo "Database ${DB_HOST}:${DB_PORT} is reachable"
		return 0
	}

	if ! wait_for_db; then
		echo "Database unreachable, aborting WordPress install"
		exit 1
	fi

	echo "Generating wp-config.php"
	# Use secrets read at the top of the script; fall back if missing
	wp --path=${WWW_ROOT} config create --dbname="${DB_NAME}" --dbuser="${DB_ADMIN}" --dbhost="${DB_HOST}:${DB_PORT}" --dbpass="$DB_PASS" --allow-root || true

	echo "Installing WordPress"
	wp --path=${WWW_ROOT} core install --url="${ROOT_DOMAIN}" --title="${SITE_TITLE}" --admin_user="${WP_ADMIN}" --admin_password="$ADMIN_PASS" --admin_email="${WP_ADMIN_MAIL}" --allow-root || true

	echo "Updating plugins"
	wp --path=${WWW_ROOT} plugin update --all --allow-root || true

	echo "Creating editor user"
	# wp user create may fail if user exists; allow failure
	wp --path=${WWW_ROOT} user create "${WP_USER}" "${WP_USER_MAIL}" --role="${WP_USER_ROLE}" --user_pass="$WP_USER_PASS" --porcelain --allow-root || true

	# Ensure a theme is installed and active (skip-content leaves no default themes)
	echo "Installing and activating default theme"
	wp --path=${WWW_ROOT} theme install twentytwentythree --activate --allow-root || true

	ID=$(wp --path=/var/www/${DOMAIN_NAME} post create --post_type=page --post_title="Welcome to Inception" --post_content="Welcome to dbarba-v inception." --post_status=publish --porcelain --allow-root)
	wp --path=/var/www/${DOMAIN_NAME} option update page_on_front $ID --allow-root \
	&& wp --path=/var/www/${DOMAIN_NAME} option update show_on_front page --allow-root

	chown -R "$WWW_USER":"$WWW_GROUP" "$WWW_ROOT"
	find "$WWW_ROOT" -type d -exec chmod 755 {} +
	find "$WWW_ROOT" -type f -exec chmod 644 {} +

	echo "WordPress setup complete"
}

# Run setup then start php-fpm in the foreground so the container stays alive.
main "$@"

if command -v "php-fpm${PHP_FPM_VERSION}" >/dev/null 2>&1; then
	echo "Starting php-fpm${PHP_FPM_VERSION} in foreground"
	exec "php-fpm${PHP_FPM_VERSION}" -F
elif command -v php-fpm >/dev/null 2>&1; then
	echo "Starting php-fpm in foreground"
	exec php-fpm -F
else
	echo "php-fpm binary not found, exiting"
	exit 1
fi
