#!/bin/bash
set -euo pipefail

# Defaults
WP_CMD="/usr/local/bin/wp"
WWW_USER="${WWW_USER:-www-data}"
WWW_GROUP="${WWW_GROUP:-$WWW_USER}"

DB_PASS=$(cat /run/secrets/mysql_wp_db_admin_password)
ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)
WP_ADMIN=$(cat /run/secrets/wp_admin_username)
WP_USER=$(cat /run/secrets/wp_user_username)
WP_ADMIN_MAIL=$(cat /run/secrets/wp_admin_mail)
WP_USER_MAIL=$(cat /run/secrets/wp_user_mail)

# Apply templated php-fpm.conf if present
PHP_FPM_CONF="/wordpress-php-docker/conf/php-fpm.conf.tmpl"
TARGET_PHP_FPM="/etc/php/${PHP_FPM_VERSION}/fpm/php-fpm.conf"
if [ -f "$PHP_FPM_CONF" ]; then
	echo "Config template \"$PHP_FPM_CONF\" found"
	echo "Generating config file \"$TARGET_PHP_FPM\""
	envsubst '\${PHPFPM_LISTEN_PORT}' < "$PHP_FPM_CONF" > "$TARGET_PHP_FPM"
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

	mkdir -p "$WP_WEBROOT"

	# Download core files only if not already present
	if [ ! -f "${WP_WEBROOT}/wp-load.php" ]; then
		echo "Downloading WordPress ($WP_VERSION)"
		if [ "$WP_VERSION" = "latest" ]; then
			wp core download --path=${WP_WEBROOT} --skip-content --allow-root
		else
			wp core download --path=${WP_WEBROOT} --version="$WP_VERSION" --skip-content --allow-root
		fi
	else
		echo "WordPress core files already present at ${WP_WEBROOT}, skipping download"
	fi

	# Configure and install only if wp-config.php is missing
	if [ ! -f "${WP_WEBROOT}/wp-config.php" ]; then
		echo "Generating wp-config.php"
		wp --path=${WP_WEBROOT} config create --dbname="${DB_NAME}" --dbuser="${DB_ADMIN}" --dbhost="${DB_HOST}:${DB_PORT}" --dbpass="$DB_PASS" --allow-root

		echo "Installing WordPress"
		wp --path=${WP_WEBROOT} core install --url="https://${DOMAIN_NAME}" --title="${SITE_TITLE}" --admin_user="${WP_ADMIN}" --admin_password="$ADMIN_PASS" --admin_email="${WP_ADMIN_MAIL}" --allow-root

		echo "Updating plugins"
		wp --path=${WP_WEBROOT} plugin update --all --allow-root || true

		echo "Creating editor user"
		wp --path=${WP_WEBROOT} user create "${WP_USER}" "${WP_USER_MAIL}" --role="${WP_USER_ROLE}" --user_pass="$WP_USER_PASS" --porcelain --allow-root || true

		echo "Installing and activating default theme"
		wp --path=${WP_WEBROOT} theme install twentytwentythree --activate --allow-root || true

		ID=$(wp --path=/var/www/${DOMAIN_NAME} post create --post_type=page --post_title="Welcome to Inception" --post_content="Welcome to dbarba-v inception." --post_status=publish --porcelain --allow-root)
		wp --path=/var/www/${DOMAIN_NAME} option update page_on_front $ID --allow-root \
		&& wp --path=/var/www/${DOMAIN_NAME} option update show_on_front page --allow-root

		echo "WordPress initial setup complete"
	else
		echo "wp-config.php already present, skipping configuration and install"
	fi

}

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
