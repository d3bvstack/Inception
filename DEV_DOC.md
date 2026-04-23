# Developer Documentation

Technical reference for the Inception Docker stack.

This document is designed for anyone who needs to understand how configuration, secrets, templates, and entrypoints behave on the Inception project implementation.

## Table of Contents

- [System Model](#system-model)
- [Configuration Model (`srcs/.env`)](#configuration-model-srcsenv)
  - [General](#general)
  - [Networks](#networks)
  - [Volumes](#volumes)
  - [Service Variables](#service-variables)
  - [Derived Image Names](#derived-image-names)
- [Secrets Model](#secrets-model)
- [Configuration Sources](#configuration-sources)
- [Runtime Service Internals](#runtime-service-internals)
  - [NGINX](#nginx)
  - [MariaDB](#mariadb)
  - [WordPress + PHP-FPM](#wordpress--php-fpm)
- [Make Targets](#make-targets)
- [Persistence](#persistence)

## System Model

The stack is split across two Docker networks:

- Frontend network: internet-facing path (`client -> nginx -> php-fpm`).
- Backend network: data path (`php-fpm -> mariadb`).

Persistence is provided by two host-backed Docker volumes:

- WordPress data (`/var/www` in container).
- MariaDB data (`/var/lib/mysql` in container).

## Configuration Model (`srcs/.env`)

All non-secret configuration is centralized in `srcs/.env`.

### General

| Variable | Description |
|---|---|
| `USER_LOGIN` | Login name; used to derive domain and host data paths |
| `DOMAIN_NAME` | Site domain (default: `${USER_LOGIN}.42.fr`) |
| `ROOT_DOMAIN` | Root domain used for WordPress setup |
| `SITE_TITLE` | WordPress site title |
| `COMPOSE_PROJECT_NAME` | Docker Compose project name |

### Networks

Two isolated networks are created.

Frontend network (`internet <-> nginx <-> php-fpm`):

| Variable | Description |
|---|---|
| `NETWORK_FRONTEND_NAME` | Network name |
| `NETWORK_FRONTEND_SUBNET` | Subnet CIDR |
| `NETWORK_FRONTEND_GATEWAY` | Gateway IP |
| `NETWORK_FRONTEND_NGINX_IP` | Static IP for NGINX |
| `NETWORK_FRONTEND_PHPFPM_IP` | Static IP for PHP-FPM |

Backend network (`php-fpm <-> mariadb`):

| Variable | Description |
|---|---|
| `NETWORK_BACKEND_NAME` | Network name |
| `NETWORK_BACKEND_SUBNET` | Subnet CIDR |
| `NETWORK_BACKEND_GATEWAY` | Gateway IP |
| `NETWORK_BACKEND_PHPFPM_IP` | Static IP for PHP-FPM |
| `NETWORK_BACKEND_DB_IP` | Static IP for MariaDB |

### Volumes

| Variable | Description |
|---|---|
| `VOLUME_DB_NAME` | Docker volume name for MariaDB data |
| `VOLUME_DB_MOUNTPOINT` | Container mount point for DB data (`/var/lib/mysql`) |
| `VOLUME_DB_HOST_PATH` | Host path for DB persistence |
| `VOLUME_WP_NAME` | Docker volume name for WordPress data |
| `VOLUME_WP_MOUNTPOINT` | Container mount point for WordPress (`/var/www`) |
| `VOLUME_WP_HOST_PATH` | Host path for WordPress persistence |

### Service Variables

#### MariaDB

| Variable | Description |
|---|---|
| `MDB_BUILD_CONTEXT` | Build context path |
| `MDB_DOCKERFILE` | Dockerfile name |
| `MDB_IMAGE_REPO` | Image repository |
| `MDB_IMAGE_TAG` | Image tag |
| `MDB_CONTAINER_NAME` | Container name |
| `MDB_CONFIG_ENV` | Env file path for the service |
| `MDB_ADMIN` | MariaDB admin username (stored as secret) |
| `MDB_CHARSET` | Default character set |
| `MDB_COLLATION` | Default collation |
| `MDB_ENGINE_PORT` | MariaDB engine port (default: `3306`) |

#### WordPress + PHP-FPM

| Variable | Description |
|---|---|
| `WP_BUILD_CONTEXT` | Build context path |
| `WP_DOCKERFILE` | Dockerfile name |
| `WP_IMAGE_REPO` | Image repository |
| `WP_IMAGE_TAG` | Image tag |
| `WP_CONTAINER_NAME` | Container name |
| `WP_CONFIG_ENV` | Env file path for the service |
| `WP_DB_NAME` | WordPress database name |
| `WP_DB_ADMIN` | DB user with privileges on WordPress DB (stored as secret) |
| `WP_DB_CHARSET` | WordPress DB character set |
| `WP_DB_COLLATION` | WordPress DB collation |
| `PHPFPM_LISTEN_PORT` | PHP-FPM listen port (default: `9000`) |
| `DB_HOST` | MariaDB host reachable by WordPress |
| `DB_SERVICE_PORT` | MariaDB port reachable by WordPress |
| `DB_NAME` | Database name used by WordPress |
| `DB_USER` | Database user used by WordPress |
| `WP_VERSION` | WordPress version to install |
| `WP_ADMIN` | WordPress admin username (stored as secret) |
| `WP_ADMIN_MAIL` | WordPress admin email (stored as secret) |
| `WP_USER` | Additional WordPress username (stored as secret) |
| `WP_USER_ROLE` | Role for the additional user |
| `WP_USER_MAIL` | Email for the additional user (stored as secret) |
| `WP_WEBROOT` | Web root path inside the container |

#### NGINX

| Variable | Description |
|---|---|
| `NGINX_BUILD_CONTEXT` | Build context path |
| `NGINX_DOCKERFILE` | Dockerfile name |
| `NGINX_IMAGE_REPO` | Image repository |
| `NGINX_IMAGE_TAG` | Image tag |
| `NGINX_CONTAINER_NAME` | Container name |
| `NGINX_CONFIG_ENV` | Env file path for the service |
| `NGINX_HOST_PORT` | Exposed host port (default: `443`) |
| `NGINX_LISTEN_PORT` | Internal NGINX listen port |
| `NGINX_PHP_SERVICE` | PHP-FPM hostname |
| `NGINX_PHP_SERVICE_PORT` | PHP-FPM port used by NGINX |
| `WEB_DATA` | Root directory for served content |

#### SSL

| Variable | Description |
|---|---|
| `KEY_NAME` | SSL private key filename |
| `KEY_PATH` | Key directory in container (`/run/secrets`) |
| `KEY_SECRET_NAME` | Docker secret name for key |
| `CERT_NAME` | SSL certificate filename |
| `CERT_PATH` | Certificate directory in container (`/run/secrets`) |
| `CERT_SECRET_NAME` | Docker secret name for cert |

### Derived Image Names

These values are composed automatically from repository and tag variables.

| Variable | Pattern |
|---|---|
| `DB_IMAGE_NAME` | `${MDB_IMAGE_REPO}:${MDB_IMAGE_TAG}` |
| `WP_IMAGE_NAME` | `${WP_IMAGE_REPO}:${WP_IMAGE_TAG}` |
| `NGINX_IMAGE_NAME` | `${NGINX_IMAGE_REPO}:${NGINX_IMAGE_TAG}` |

## Secrets Model

Secret values are file-based and must not be placed in `srcs/.env`.

Required structure:

```text
secrets/
├── mariadb/
│   ├── mysql_root_password.secret
│   ├── mysql_wp_db_admin_password.secret
│   └── mysql_wp_db_admin_username.secret
├── wordpress-php/
│   ├── wp_admin_password.secret
│   ├── wp_admin_username.secret
│   ├── wp_admin_mail.secret
│   ├── wp_user_password.secret
│   ├── wp_user_username.secret
│   └── wp_user_mail.secret
└── ssl/
    ├── dbarba-v.42.fr.cert
    └── dbarba-v.42.fr.key
```

## Configuration Sources

| Service | Source file |
|---|---|
| NGINX (global) | `srcs/requirements/nginx/conf/nginx.conf` |
| NGINX (vhost template) | `srcs/requirements/nginx/conf/server.conf.tmpl` |
| PHP-FPM template | `srcs/requirements/wordpress-php/conf/php-fpm.conf.tmpl` |
| MariaDB template | `srcs/requirements/mariadb/conf/my.cnf.tmpl` |

## Runtime Service Internals

### NGINX

#### Template rendering model

`nginx.conf` is copied from `/nginx-docker/conf/nginx.conf` to `/etc/nginx/nginx.conf`.

`server.conf.tmpl` is rendered with `envsubst` into `/etc/nginx/conf.d/${DOMAIN_NAME}.conf` using:

```text
${DOMAIN_NAME} ${NGINX_LISTEN_PORT} ${NGINX_HOST_PORT}
${CERT_NAME} ${KEY_NAME} ${CERT_PATH} ${KEY_PATH}
${WEB_DATA} ${WP_CONTAINER_NAME} ${PHPFPM_HOST} ${PHPFPM_LISTEN_PORT}
```

The resulting vhost:

- Rejects unknown hosts with HTTP `444`.
- Redirects HTTP (`80`) to HTTPS (`443`).
- Terminates TLS and serves content from `${WEB_DATA}/${DOMAIN_NAME}`.
- Proxies `*.php` to `${PHPFPM_HOST}:${PHPFPM_LISTEN_PORT}`.
- Applies security headers (for example `X-Frame-Options`, `X-Content-Type-Options`, CSP).
- Caches static assets for 180 days.
- Denies hidden files and PHP execution in upload directories.

#### Entrypoint behavior

`tools/setup.sh` performs startup orchestration, then `exec`s NGINX:

1. Move `nginx.conf` into `/etc/nginx/nginx.conf`.
2. Render `server.conf.tmpl` and remove the template.
3. On restart, verify rendered vhost config exists.
4. Validate config using `nginx -t`.
5. `exec /usr/sbin/nginx` so NGINX becomes PID 1.

### MariaDB

#### Template rendering model

`my.cnf.tmpl` is rendered into `/etc/mysql/mariadb.conf.d/99-custom.cnf` with:

- `${MDB_CHARSET}`
- `${MDB_COLLATION}`
- `${MDB_ENGINE_PORT}`

Because MariaDB loads files in that directory, the `99-` prefix ensures these values apply after defaults.

#### Entrypoint behavior

`tools/setup.sh` initializes on first boot and starts `mariadbd`:

1. Read secrets from `/run/secrets/mysql_root_password` and `/run/secrets/mysql_wp_db_admin_password`.
2. Render `my.cnf.tmpl` into `99-custom.cnf`.
3. First boot only: run `mariadb-install-db` on `/var/lib/mysql`.
4. Start temporary `mariadbd` with `--skip-networking`.
5. Poll readiness with `mysqladmin ping` for up to 60s.
6. Secure installation:
   - Set `root@localhost` password.
   - Remove anonymous users.
   - Remove `test` database.
   - `FLUSH PRIVILEGES`.
7. Create WordPress DB and DB admin user if missing.
8. Shut down temporary instance (`mysqladmin shutdown`).
9. `exec /usr/sbin/mariadbd --user=mysql --datadir=/var/lib/mysql`.

### WordPress + PHP-FPM

#### Template rendering model

`php-fpm.conf.tmpl` is rendered into `/etc/php/${PHP_FPM_VERSION}/fpm/php-fpm.conf`.

Substituted variable:

- `${PHPFPM_LISTEN_PORT}` (bind address becomes `0.0.0.0:${PHPFPM_LISTEN_PORT}`)

#### Entrypoint behavior

`tools/setup.sh` installs/configures WordPress, then starts PHP-FPM:

1. Read secrets from `/run/secrets` (DB admin password, WP admin password, WP user password).
2. Render `php-fpm.conf.tmpl`; fail fast if template is missing.
3. Install WP-CLI (`/usr/local/bin/wp`) if absent.
4. First boot only: download WordPress core with configured `WP_VERSION`.
5. First boot only:
   - Generate `wp-config.php` using DB credentials.
   - Run `wp core install`.
   - Update plugins.
   - Create secondary WordPress user.
   - Install and activate `twentytwentythree` theme.
   - Create a static front page and set it as homepage.
6. Set ownership of `${WP_WEBROOT}` to `www-data:www-data`.
7. `exec php-fpm${PHP_FPM_VERSION} -F`; fallback to `php-fpm` if needed.

## Make Targets

### Lifecycle

| Command | Description |
|---|---|
| `make` / `make inception` / `make all` / `make up` | Start all containers in detached mode |
| `make down` | Stop and remove containers and networks (volumes kept) |
| `make stop` | Stop containers without removing them |
| `make restart` | Restart all containers |

### Inspection

| Command | Description |
|---|---|
| `make ps` | Show container status |
| `make secrets` | Verify and create missing secret files |
| `make shell SERVICE=<name>` | Open `/bin/sh` in a running container |
| `make config` | Show fully resolved Compose config |

### Build and Cleanup

| Command | Description |
|---|---|
| `make build` | Rebuild images using configured `.env` |
| `make clean` | Remove containers, volumes, and host data directories |
| `make fclean` | Full cleanup: containers, volumes, images, host data |
| `make re` | Rebuild from scratch (`fclean` + `all`) |

## Persistence

| Volume Name | Container Path | Host Path |
|---|---|---|
| `wordpress_data` | `/var/www` | `/home/${USER_LOGIN}/data/wordpress` |
| `database_data` | `/var/lib/mysql` | `/home/${USER_LOGIN}/data/mariadb` |