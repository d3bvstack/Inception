# User Documentation

## Overview

This infrastructure runs a WordPress site backed by the following services:

| Service  | Role                  |
|----------|-----------------------|
| NGINX    | Reverse proxy         |
| WordPress | CMS                  |
| PHP-FPM  | PHP runtime           |
| MariaDB  | MySQL database        |

---

## Getting Started

### Start the infrastructure

```sh
make
```

> Aliases: `make inception` `make all` or `make up`

Note: The Makefile runs a small helper that will prompt for any missing secret files (created under `srcs/secrets/`) when starting the stack.

### Stop, restart, or clean up

| Command        | Effect                                              |
|----------------|-----------------------------------------------------|
| `make stop`    | Stop all running containers                         |
| `make restart` | Restart all containers                              |
| `make fclean`  | Stop and remove all containers, networks, and images|

---

## Accessing the Site

| URL                              | Description        |
|----------------------------------|--------------------|
| `https://dbarba-v.42.fr`         | Main site          |
| `https://dbarba-v.42.fr/wp-admin`     | WordPress admin panel |
| `https://dbarba-v.42.fr/wp-login.php` | WordPress login page  |

---

## Credentials

Secrets are stored as plain-text files under `srcs/secrets/`:

```
srcs/secrets/
├── mariadb/
│   ├── mysql_root_password.secret
│   └── mysql_wp_db_admin_password.secret
└── wordpress-php/
    ├── wp_admin_password.secret
    └── wp_user_password.secret
```

Each file must contain only the secret value (no trailing newline).

If a file is missing, `make` prompts interactively for its value and writes it with `0400` permissions. If in non-interactive environments (no TTY) the check will fail; create the files beforehand.

---

## Verifying the Infrastructure

Check that all services are running:

```sh
make ps
# or
docker compose -f ./srcs/docker-compose.yml ps
```
