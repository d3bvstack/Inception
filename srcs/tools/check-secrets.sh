#!/bin/sh
set -eu

CRED_SECRETS="
srcs/secrets/wordpress-php/wp_admin_password.secret
srcs/secrets/wordpress-php/wp_user_password.secret
srcs/secrets/mariadb/mysql_root_password.secret
srcs/secrets/mariadb/mysql_wp_db_admin_password.secret
"

for file in $CRED_SECRETS; do
  [ -z "$file" ] && continue
  [ -f "$file" ] && continue

  { [ -r /dev/tty ] && [ -w /dev/tty ]; } || { printf "Error: missing %s and no TTY to prompt for value.\n" "$file" >&2; exit 1; }

  mkdir -p "$(dirname "$file")"
  printf "Enter value for %s: " "$file" >/dev/tty
  stty -echo </dev/tty 2>/dev/null || true
  IFS= read -r val </dev/tty
  stty echo </dev/tty 2>/dev/null || true
  printf "\n" >/dev/tty
  printf '%s' "$val" >"$file"
  chmod 0400 "$file" 2>/dev/null || true
  printf "Created %s\n" "$file" >&2
done

if [ ! -f "srcs/secrets/ssl/${KEY_NAME}" ] || [ ! -f "srcs/secrets/ssl/${CERT_NAME}" ]; then
  mkdir -p srcs/secrets/ssl
  printf "Generating SSL key and certificate.\n"
  openssl req -x509 \
		-newkey rsa:4096 \
		-keyout "srcs/secrets/ssl/${KEY_NAME}" \
		-out "srcs/secrets/ssl/${CERT_NAME}" \
		-sha256 \
		-days 3650 \
		-nodes \
		-subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Inception/CN=${USER_LOGIN}.42.fr"
fi