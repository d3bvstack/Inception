# Developer Documentation

## Table of Contents

1. [Configuration — `.env`](#1-configuration--env)
   1. [General](#11-general)
   2. [Networks](#12-networks)
      - [Frontend Network](#frontend-network)
      - [Backend Network](#backend-network)
   3. [Volumes](#13-volumes)
   4. [Services](#14-services)
      - [MariaDB](#mariadb)
      - [WordPress / PHP-FPM](#wordpress--php-fpm)
      - [NGINX](#nginx)
      - [SSL](#ssl)
   5. [Derived Image Names](#15-derived-image-names)
2. [Secrets](#2-secrets)
3. [Configuration Files](#3-configuration-files)
4. [Make Commands](#4-make-commands)
5. [Data Persistence](#5-data-persistence)

---

## 1. Configuration — `.env`

All project settings are controlled through `srcs/.env`. The variables are grouped by concern below.

### 1.1 General

| Variable | Description |
|---|---|
| `USER_LOGIN` | Login name; used to derive the domain and host data |
| `DOMAIN_NAME` | Site domain (defaults to `${USER_LOGIN}.42.fr`) |
| `ROOT_DOMAIN` | Root domain used for WordPress install |
| `SITE_TITLE` | Title for the WordPress site |
| `COMPOSE_PROJECT_NAME` | Docker variable that names the compose project |

### 1.2 Networks

Two Docker networks isolate traffic between services.

#### Frontend Network

Connects Internet ↔ NGINX ↔ PHP-FPM.

| Variable | Description |
|---|---|
| `NETWORK_FRONTEND_NAME` | Network name |
| `NETWORK_FRONTEND_SUBNET` | Subnet CIDR |
| `NETWORK_FRONTEND_GATEWAY` | Gateway IP |
| `NETWORK_FRONTEND_NGINX_IP` | Static IP for the NGINX container |
| `NETWORK_FRONTEND_PHPFPM_IP` | Static IP for the PHP-FPM container |

#### Backend Network

Connects PHP-FPM ↔ MariaDB.

| Variable | Description |
|---|---|
| `NETWORK_BACKEND_NAME` | Network name |
| `NETWORK_BACKEND_SUBNET` | Subnet CIDR |
| `NETWORK_BACKEND_GATEWAY` | Gateway IP |
| `NETWORK_BACKEND_PHPFPM_IP` | Static IP for the PHP-FPM container |
| `NETWORK_BACKEND_DB_IP` | Static IP for the MariaDB container |

### 1.3 Volumes

| Variable | Description |
|---|---|
| `VOLUME_DB_NAME` | Docker volume name for MariaDB data |
| `VOLUME_DB_MOUNTPOINT` | Mount path inside the container (`/var/lib/mysql`) |
| `VOLUME_DB_HOST_PATH` | Host path where DB data is persisted |
| `VOLUME_WP_NAME` | Docker volume name for WordPress files |
| `VOLUME_WP_MOUNTPOINT` | Mount path inside the container (`/var/www`) |
| `VOLUME_WP_HOST_PATH` | Host path where WordPress files are persisted |

### 1.4 Services

#### MariaDB

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

#### WordPress / PHP-FPM

| Variable |Description |
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

#### NGINX

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

#### SSL

| Variable | Description |
|---|---|
| `KEY_NAME` | SSL private key filename |
| `KEY_PATH` | Directory inside the container for the key (`/run/secrets`) |
| `KEY_SECRET_NAME` | Name for the docker secret |
| `CERT_NAME` | SSL certificate filename |
| `CERT_PATH` | Directory inside the container for the certificate (`/run/secrets`) |
| `CERT_SECRET_NAME` | Name for the docker secret  |


### 1.5 Derived Image Names

These variables are composed from the repo and tag variables above and do not need to be set manually.

| Variable | Value pattern |
|---|---|
| `DB_IMAGE_NAME` | `${MDB_IMAGE_REPO}:${MDB_IMAGE_TAG}` |
| `WP_IMAGE_NAME` | `${WP_IMAGE_REPO}:${WP_IMAGE_TAG}` |
| `NGINX_IMAGE_NAME` | `${NGINX_IMAGE_REPO}:${NGINX_IMAGE_TAG}` |

---

## 2. Secrets

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

## 3. Configuration Files

| Service | File |
|---|---|
| NGINX | `srcs/requirements/nginx/nginx.conf` |
| NGINX (vhost) | `srcs/requirements/nginx/conf/server.conf.tmpl` |
| PHP-FPM | `srcs/requirements/wordpress-php/php-fpm.conf` |
| MariaDB | `srcs/requirements/mariadb/conf/my.cnf.tmpl` |

---

## 4. Make Commands

### 4.1 Lifecycle

| Command | Description |
|---|---|
| `make` / `make inception` / `make all` / `make up` | Start all containers in detached mode |
| `make down` | Stop and remove containers and networks |
| `make stop` | Stop running containers without removing them |
| `make restart` | Restart all containers |

### 4.2 Inspection

| Command | Description |
|---|---|
| `make ps` | Show container status |
| `make secrets` | Check for secrets and create missing ones |
| `make shell SERVICE=<name>` | Open a shell inside a running container |
| `make config` | Print the resolved Compose configuration |

### 4.3 Build & Cleanup

| Command | Description |
|---|---|
| `make build` | Rebuild images (uses the configured `.env` for build args) |
| `make clean` | Remove containers and volumes |
| `make fclean` | Full cleanup — containers, volumes, images, and host data directories |
| `make re` | Full rebuild (`fclean` + `all`) |

---

## 5. Data Persistence

| Data | Container path | Host path |
|---|---|---|
| WordPress files | `/var/www` | `/home/${USER_LOGIN}/data/wordpress` |
| MariaDB database | `/var/lib/mysql` | `/home/${USER_LOGIN}/data/mariadb` |