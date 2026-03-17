#!/bin/sh
set -eu


CRED_SECRETS="
secrets/wordpress-php/wp_admin_username.secret
secrets/wordpress-php/wp_admin_mail.secret
secrets/wordpress-php/wp_admin_password.secret
secrets/wordpress-php/wp_user_username.secret
secrets/wordpress-php/wp_user_mail.secret
secrets/wordpress-php/wp_user_password.secret
secrets/mariadb/mysql_wp_db_admin_username.secret
secrets/mariadb/mysql_wp_db_admin_password.secret
secrets/mariadb/mysql_root_password.secret
"

for file in $CRED_SECRETS; do
  [ -z "$file" ] && continue
  [ -f "$file" ] && continue

  { [ -r /dev/tty ] && [ -w /dev/tty ]; } || { printf "Error: missing %s and no TTY to prompt for value.\n" "$file" >&2; exit 1; }

  mkdir -p "$(dirname "$file")"
  prompt_name=$(basename "$file")
  prompt_name=${prompt_name%.secret}
  prompt_display=$(printf "%s" "$prompt_name" | tr '_' ' ')
  printf "Enter value for %s: " "$prompt_display" >/dev/tty
  stty -echo </dev/tty 2>/dev/null || true
  IFS= read -r val </dev/tty
  stty echo </dev/tty 2>/dev/null || true
  printf "\n" >/dev/tty
  printf '%s' "$val" >"$file"
  printf "Created %s\n" "$file" >&2
done

if [ ! -f "secrets/ssl/${KEY_NAME}" ] || [ ! -f "secrets/ssl/${CERT_NAME}" ]; then
  mkdir -p secrets/ssl
  printf "Generating SSL key and certificate.\n"
  openssl req -x509 \
		-newkey rsa:4096 \
		-keyout "secrets/ssl/${KEY_NAME}" \
		-out "secrets/ssl/${CERT_NAME}" \
		-sha256 \
		-days 3650 \
		-nodes \
		-subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Inception/CN=${USER_LOGIN}.42.fr"
fi