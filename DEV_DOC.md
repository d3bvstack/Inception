# Developer Documentation

## Table of Contents

- [Configuration (`.env`)](#configuration-env)
  - [General](#general)
  - [Networks](#networks)
  - [Volumes](#volumes)
  - [Services](#services)
  - [Derived Image Names](#derived-image-names)
- [Secrets](#secrets)
- [Configuration Files](#configuration-files)
- [Service Internals](#service-internals)
  - [NGINX](#nginx)
    - [How `nginx.conf` and `server.conf.tmpl` are used](#how-nginxconf-and-serverconftmpl-are-used)
    - [What the NGINX entrypoint does](#what-the-nginx-entrypoint-does)
  - [MariaDB](#mariadb)
    - [How `my.cnf.tmpl` is used](#how-mycnftmpl-is-used)
    - [What the MariaDB entrypoint does](#what-the-mariadb-entrypoint-does)
  - [WordPress + PHP-FPM](#wordpress--php-fpm)
    - [How `php-fpm.conf.tmpl` is used](#how-php-fpmconftmpl-is-used)
    - [What the WordPress + PHP-FPM entrypoint does](#what-the-wordpress--php-fpm-entrypoint-does)
- [Make Commands](#make-commands)
  - [Lifecycle](#lifecycle)
  - [Inspection](#inspection)
  - [Build & Cleanup](#build--cleanup)
- [Data Persistence](#data-persistence)

## Configuration (`.env`)

All project settings are controlled through `srcs/.env`. The variables are grouped by concern below.

### General

| Variable | Description |
|---|---|
| `USER_LOGIN` | Login name; used to derive the domain and host data |
| `DOMAIN_NAME` | Site domain (defaults to `${USER_LOGIN}.42.fr`) |
| `ROOT_DOMAIN` | Root domain used for WordPress install |
| `SITE_TITLE` | Title for the WordPress site |
| `COMPOSE_PROJECT_NAME` | Docker variable that names the compose project |

### Networks

Two Docker networks isolate traffic between services.

**Frontend Network** — Connects Internet ↔ NGINX ↔ PHP-FPM.

| Variable | Description |
|---|---|
| `NETWORK_FRONTEND_NAME` | Network name |
| `NETWORK_FRONTEND_SUBNET` | Subnet CIDR |
| `NETWORK_FRONTEND_GATEWAY` | Gateway IP |
| `NETWORK_FRONTEND_NGINX_IP` | Static IP for the NGINX container |
| `NETWORK_FRONTEND_PHPFPM_IP` | Static IP for the PHP-FPM container |

**Backend Network** — Connects PHP-FPM ↔ MariaDB.

| Variable | Description |
|---|---|
| `NETWORK_BACKEND_NAME` | Network name |
| `NETWORK_BACKEND_SUBNET` | Subnet CIDR |
| `NETWORK_BACKEND_GATEWAY` | Gateway IP |
| `NETWORK_BACKEND_PHPFPM_IP` | Static IP for the PHP-FPM container |
| `NETWORK_BACKEND_DB_IP` | Static IP for the MariaDB container |

### Volumes

| Variable | Description |
|---|---|
| `VOLUME_DB_NAME` | Docker volume name for MariaDB data |
| `VOLUME_DB_MOUNTPOINT` | Mount path inside the container (`/var/lib/mysql`) |
| `VOLUME_DB_HOST_PATH` | Host path where DB data is persisted |
| `VOLUME_WP_NAME` | Docker volume name for WordPress files |
| `VOLUME_WP_MOUNTPOINT` | Mount path inside the container (`/var/www`) |
| `VOLUME_WP_HOST_PATH` | Host path where WordPress files are persisted |

### Services

**MariaDB**

| Variable | Description |
|---|---|
| `MDB_BUILD_CONTEXT` | Build context path |
| `MDB_DOCKERFILE` | Dockerfile filename |
| `MDB_IMAGE_REPO` | Image repository name |
| `MDB_IMAGE_TAG` | Image tag |
| `MDB_CONTAINER_NAME` | Container name |
| `MDB_CONFIG_ENV` | Path to the service config env-file |
| `MDB_ADMIN` | MariaDB admin username |
| `MDB_CHARSET` | Default character set |
| `MDB_COLLATION` | Default collation |
| `MDB_ENGINE_PORT` | MariaDB engine port (default `3306`) |

**WordPress + PHP-FPM**

| Variable | Description |
|---|---|
| `WP_BUILD_CONTEXT` | Build context path |
| `WP_DOCKERFILE` | Dockerfile filename |
| `WP_IMAGE_REPO` | Image repository name |
| `WP_IMAGE_TAG` | Image tag |
| `WP_CONTAINER_NAME` | Container name |
| `WP_CONFIG_ENV` | Path to the service config env-file |
| `WP_DB_NAME` | WordPress database name |
| `WP_DB_ADMIN` | MariaDB user with privileges on the WordPress DB |
| `WP_DB_CHARSET` | WordPress database character set |
| `WP_DB_COLLATION` | WordPress database collation |
| `PHPFPM_LISTEN_PORT` | PHP-FPM listener port (default `9000`) |
| `DB_HOST` | Hostname of the MariaDB container |
| `DB_SERVICE_PORT` | MariaDB port reachable by WordPress |
| `DB_NAME` | Database name WordPress connects to |
| `DB_USER` | Database user WordPress connects as |
| `WP_VERSION` | WordPress version to install |
| `WP_ADMIN` | WordPress administrator username |
| `WP_ADMIN_MAIL` | Administrator email address |
| `WP_USER` | Additional WordPress user username |
| `WP_USER_ROLE` | Role for the additional user |
| `WP_USER_MAIL` | Email address for the additional user |
| `WP_WEBROOT` | Web root path inside the container |

**NGINX**

| Variable | Description |
|---|---|
| `NGINX_BUILD_CONTEXT` | Build context path |
| `NGINX_DOCKERFILE` | Dockerfile filename |
| `NGINX_IMAGE_REPO` | Image repository name |
| `NGINX_IMAGE_TAG` | Image tag |
| `NGINX_CONTAINER_NAME` | Container name |
| `NGINX_CONFIG_ENV` | Path to the service config env-file |
| `NGINX_HOST_PORT` | Host port exposed to the outside (default `443`) |
| `NGINX_LISTEN_PORT` | Port NGINX listens on inside the container |
| `NGINX_PHP_SERVICE` | Hostname of the PHP-FPM container |
| `NGINX_PHP_SERVICE_PORT` | PHP-FPM port NGINX forwards requests to |
| `WEB_DATA` | Root of served web content inside the container |

**SSL**

| Variable | Description |
|---|---|
| `KEY_NAME` | SSL private key filename |
| `KEY_PATH` | Directory inside the container for the key (`/run/secrets`) |
| `KEY_SECRET_NAME` | Name for the docker secret |
| `CERT_NAME` | SSL certificate filename |
| `CERT_PATH` | Directory inside the container for the certificate (`/run/secrets`) |
| `CERT_SECRET_NAME` | Name for the docker secret |


### Derived Image Names

These variables are composed from the repo and tag variables above and do not need to be set manually.

| Variable | Value pattern |
|---|---|
| `DB_IMAGE_NAME` | `${MDB_IMAGE_REPO}:${MDB_IMAGE_TAG}` |
| `WP_IMAGE_NAME` | `${WP_IMAGE_REPO}:${WP_IMAGE_TAG}` |
| `NGINX_IMAGE_NAME` | `${NGINX_IMAGE_REPO}:${NGINX_IMAGE_TAG}` |

---

## Secrets

Secret values are read from files and are **not** stored in `.env`. Create the following files before the first build:

```
secrets/
├── mariadb/
│   ├── mysql_root_password.secret         # mysql_root_password secret
│   └── mysql_wp_db_admin_password.secret  # mysql_wp_db_admin_password secret
├── wordpress-php/
│   ├── wp_admin_password.secret           # wp_admin_password secret
│   └── wp_user_password.secret            # wp_user_password secret
└── ssl/
    ├── dbarba-v.42.fr.cert                # SSL certificate secret
    └── dbarba-v.42.fr.key                 # SSL private key secret
```

---

## Configuration Files

| Service | File |
|---|---|
| NGINX | `srcs/requirements/nginx/conf/nginx.conf` |
| NGINX (vhost) | `srcs/requirements/nginx/conf/server.conf.tmpl` |
| PHP-FPM | `srcs/requirements/wordpress-php/conf/php-fpm.conf.tmpl` |
| MariaDB | `srcs/requirements/mariadb/conf/my.cnf.tmpl` |

---

## Service Internals

### NGINX

#### How `nginx.conf` and `server.conf.tmpl` are used

`nginx.conf` is the global NGINX configuration. It is copied by the entrypoint from the build-context path `/nginx-docker/conf/nginx.conf` to `/etc/nginx/nginx.conf`. It configures worker processes, events management, global TLS policy (TLS versions, available ciphers and SSL session cache), and it also adds the `include /etc/nginx/conf.d/*.conf`, which loads virtual host configs. It also sets `daemon off` so NGINX runs in the foreground and keeps the container alive.

`server.conf.tmpl` is a virtual host template. The entrypoint processes it with `envsubst`, substituting a list of variables:

```
${DOMAIN_NAME} ${NGINX_LISTEN_PORT} ${NGINX_HOST_PORT}
${CERT_NAME} ${KEY_NAME} ${CERT_PATH} ${KEY_PATH}
${WEB_DATA} ${WP_CONTAINER_NAME} ${PHPFPM_HOST} ${PHPFPM_LISTEN_PORT}
```

The new file with expanded variables is written to `/etc/nginx/conf.d/${DOMAIN_NAME}.conf` and the template is removed. The resulting vhost config:

- Rejects unknown hostnames with HTTP 444.
- Redirects all port 80 traffic to HTTPS port 443.
- Terminates TLS and serves WordPress files from `${WEB_DATA}/${DOMAIN_NAME}`.
- Forwards `*.php` requests to PHP-FPM on `${PHPFPM_HOST}:${PHPFPM_LISTEN_PORT}`.
- Adds OWASP-recommended security headers (`X-Frame-Options`, `X-Content-Type-Options`, CSP, etc.).
- Caches static assets in the browser for 180 days.
- Denies access to hidden files and PHP execution inside upload directories.

#### What the NGINX entrypoint does

`tools/setup.sh` runs once at container start and then `exec`s NGINX:

1. Moves `nginx.conf` from `/nginx-docker/conf/nginx.conf` → `/etc/nginx/nginx.conf`.
2. Runs `envsubst` on `server.conf.tmpl` with the explicit variable list and writes the result to `/etc/nginx/conf.d/${DOMAIN_NAME}.conf`. Removes the template afterwards.
3. On restart (template no longer present): verifies the config file exists and continues.
4. Validates the full NGINX configuration with `nginx -t`; exits non-zero on failure.
5. `exec /usr/sbin/nginx` replaces the shell process with NGINX.

---

### MariaDB

#### How `my.cnf.tmpl` is used

`my.cnf.tmpl` is a MariaDB config file template that configures the `[mysqld]` section: datadir, InnoDB engine settings, character set, collation, bind address, and port. The entrypoint substitutes the three environment-specific variables — `${MDB_CHARSET}`, `${MDB_COLLATION}`, and `${MDB_ENGINE_PORT}` — with `envsubst` and writes the result to `/etc/mysql/mariadb.conf.d/99-custom.cnf`. MariaDB automatically loads all `.cnf` files from that directory and the `99-` prefix ensures these settings apply last and override any defaults.

#### What the MariaDB entrypoint does

`tools/setup.sh` configures the database on first start and `exec` `mariadbd` for subsequent runs:

1. Reads secrets from `/run/secrets/mysql_root_password` and `/run/secrets/mysql_wp_db_admin_password`.
2. Processes `my.cnf.tmpl` → `/etc/mysql/mariadb.conf.d/99-custom.cnf`; on restart the template is gone but the rendered file already exists.
3. **First boot only**: runs `mariadb-install-db` to initialize the data directory at `/var/lib/mysql`.
4. Starts a temporary `mariadbd` instance with `--skip-networking` (no external connections accepted) in the background.
5. Polls `mysqladmin ping` every second for up to 60 s; aborts if the server never becomes reachable.
6. **Secures the install** (idempotent `ALTER USER`, so safe on restarts):
   - Sets the `root@localhost` password.
   - Drops anonymous users and the `test` database.
   - `FLUSH PRIVILEGES`.
7. Creates the WordPress database (`CREATE DATABASE IF NOT EXISTS`) and the DB admin user (`CREATE USER IF NOT EXISTS`) with `GRANT ALL PRIVILEGES` on that database.
8. Shuts down the temporary instance cleanly with `mysqladmin shutdown`.
9. `exec /usr/sbin/mariadbd --user=mysql --datadir=/var/lib/mysql` — replaces the shell with the real, network-facing server (PID 1).

---

### WordPress + PHP-FPM

#### How `php-fpm.conf.tmpl` is used

`php-fpm.conf.tmpl` is the main PHP-FPM configuration template. It defines the global FPM options and the `[www]` worker pool. The only variable substituted is `${PHPFPM_LISTEN_PORT}`, which sets the TCP address the pool listens on (`0.0.0.0:${PHPFPM_LISTEN_PORT}`), making the pool reachable by the NGINX container over the frontend network. The entrypoint renders the template with `envsubst '\${PHPFPM_LISTEN_PORT}'` and writes the result to `/etc/php/${PHP_FPM_VERSION}/fpm/php-fpm.conf`, replacing the distro-supplied default.

#### What the WordPress + PHP-FPM entrypoint does

`tools/setup.sh` installs and configures WordPress, then `exec`s PHP-FPM:

1. Reads secrets from `/run/secrets/` (DB admin password, WP admin password, WP user password).
2. Processes `php-fpm.conf.tmpl` → `/etc/php/${PHP_FPM_VERSION}/fpm/php-fpm.conf`; exits non-zero if the template is missing.
3. Installs **WP-CLI** (`wp`) into `/usr/local/bin/wp` if not already present.
4. **First boot only**: downloads WordPress core files with `wp core download --skip-content` at the configured version.
5. **First boot only**:
   - Generates `wp-config.php` with DB credentials read from secrets.
   - Runs `wp core install` (sets site URL, title, admin account).
   - Updates all plugins.
   - Creates the secondary WordPress user with the configured role.
   - Installs and activates the `twentytwentythree` theme.
   - Creates a static front page and sets it as the homepage.
6. Sets ownership of `${WP_WEBROOT}` to `www-data:www-data`.
7. `exec php-fpm${PHP_FPM_VERSION} -F` — replaces the shell with PHP-FPM running in the foreground (PID 1). Falls back to `php-fpm` if the versioned executable is not found.

---

## Make Commands

### Lifecycle

| Command | Description |
|---|---|
| `make` / `make inception` / `make all` / `make up` | Start all containers in detached mode |
| `make down` | Stop and remove containers and networks (keeps volumes) |
| `make stop` | Stop running containers without removing them |
| `make restart` | Restart all containers |

### Inspection

| Command | Description |
|---|---|
| `make ps` | Show container status |
| `make secrets` | Check for secrets and create missing ones |
| `make shell SERVICE=<name>` | Open `/bin/sh` inside a running container |
| `make config` | Print the resolved Compose configuration |

### Build & Cleanup

| Command | Description |
|---|---|
| `make build` | Rebuild images (reads the configured `.env`) |
| `make clean` | Remove containers and volumes |
| `make fclean` | Full cleanup — containers, volumes, images, and host data directories |
| `make re` | Full rebuild (`fclean` + `all`) |

---

## Data Persistence

| Volume Name | Container path | Host path |
|---|---|---|
| wordpress_data | `/var/www` | `/home/${USER_LOGIN}/data/wordpress` |
| database_data | `/var/lib/mysql` | `/home/${USER_LOGIN}/data/mariadb` |