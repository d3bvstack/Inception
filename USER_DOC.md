# User Documentation

## Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
	- [Start the infrastructure](#start-the-infrastructure)
	- [Commands](#commands)
- [Accessing the Site](#accessing-the-site)
- [Secrets](#secrets)
- [Verifying the Infrastructure](#verifying-the-infrastructure)

## Overview

This infrastructure runs a WordPress site backed by the following services:

| Service | Role |
|---|---|
| NGINX | Reverse proxy |
| WordPress + PHP-FPM | CMS, PHP runtime |
| MariaDB | MySQL database |

---

## Getting Started

> Add the following entries to `/etc/hosts`:
>
> `127.0.0.1     dbarba-v.42.fr`
> `127.0.0.1     www.dbarba-v.42.fr`

### Start the infrastructure

```sh
make
```

> Aliases: `make inception`, `make all`, or `make up`

> The Makefile runs a small helper that will prompt for any missing secret files (created under `secrets/`) when starting the stack.

### Commands

| Command | Description |
|---|---|
| `make` / `make inception` / `make all` / `make up` | Start all containers in detached mode |
| `make build` | Rebuild images (reads the configured `.env`) |
| `make down` | Stop and remove containers and networks (keeps volumes) |
| `make stop` | Stop running containers without removing them |
| `make restart` | Restart all containers |
| `make ps` | Show container status |
| `make shell SERVICE=<name>` | Open `/bin/sh` inside a running container |
| `make config` | Print the resolved Compose configuration |
| `make secrets` | Check for secrets and create missing ones |
| `make clean` | Remove containers and volumes |
| `make fclean` | Full cleanup — containers, volumes, images, and host data directories |
| `make re` | Full rebuild (`fclean` + `all`) |

---

## Accessing the Site

> The following URLs are valid only if the project is running on the default VM.

| URL | Description |
|---|---|
| `https://dbarba-v.42.fr` | Main site |
| `https://dbarba-v.42.fr/wp-admin` | WordPress admin panel |
| `https://dbarba-v.42.fr/wp-login.php` | WordPress login page |

---

## Secrets

Secret values (including usernames, emails, and passwords) are stored as plain-text files under `secrets/`:

```
secrets/
├── mariadb/
│   ├── mysql_root_password.secret         # mysql_root_password secret
│   ├── mysql_wp_db_admin_password.secret  # mysql_wp_db_admin_password secret
│   └── mysql_wp_db_admin_username.secret  # mysql_wp_db_admin_username secret
├── wordpress-php/
│   ├── wp_admin_password.secret           # wp_admin_password secret
│   ├── wp_admin_username.secret           # wp_admin_username secret
│   ├── wp_admin_mail.secret               # wp_admin_mail secret
│   ├── wp_user_password.secret            # wp_user_password secret
│   ├── wp_user_username.secret            # wp_user_username secret
│   └── wp_user_mail.secret                # wp_user_mail secret
└── ssl/
    ├── dbarba-v.42.fr.cert                # SSL certificate secret
    └── dbarba-v.42.fr.key                 # SSL private key secret
```

Each file must contain only the secret value (no trailing newline).

If a file is missing, `make` prompts interactively for its value. If in non-interactive environments (no TTY) the check will fail; create the files beforehand.

---

## Verifying the Infrastructure

Check that all services are running:

```sh
make ps
# or
docker compose -f ./srcs/docker-compose.yml ps
```
