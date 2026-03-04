#!/bin/sh
set -eu

SECRETS="
srcs/secrets/wordpress-php/wp_admin_password.secret
srcs/secrets/wordpress-php/wp_user_password.secret
srcs/secrets/mariadb/mysql_root_password.secret
srcs/secrets/mariadb/mysql_wp_db_admin_password.secret
"

for file in $SECRETS; do
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
