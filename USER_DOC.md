# User Documentation

Practical guide for running and using the Inception stack.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Daily Commands](#daily-commands)
- [Access the Site](#access-the-site)
- [Secrets](#secrets)
- [Verify the Stack](#verify-the-stack)
- [Troubleshooting Notes](#troubleshooting-notes)

## Overview

This project runs a WordPress website with three services:

| Service | Role |
|---|---|
| NGINX | HTTPS reverse proxy |
| WordPress + PHP-FPM | CMS and PHP runtime |
| MariaDB | Database backend |

## Quick Start

1. Add these host entries:

```text
127.0.0.1     dbarba-v.42.fr
127.0.0.1     www.dbarba-v.42.fr
```

2. Start the infrastructure:

```sh
make
```

Equivalent commands:

- `make inception`
- `make all`
- `make up`

When required secret files are missing, the Makefile helper prompts you to create them.

## Daily Commands

| Command | Description |
|---|---|
| `make` / `make inception` / `make all` / `make up` | Start all containers in detached mode |
| `make build` | Rebuild images from the configured `.env` |
| `make down` | Stop and remove containers and networks (volumes kept) |
| `make stop` | Stop running containers without removing them |
| `make restart` | Restart all containers |
| `make ps` | Show service/container status |
| `make shell SERVICE=<name>` | Open `/bin/sh` inside a running container |
| `make config` | Print resolved Docker Compose configuration |
| `make secrets` | Verify/create missing secret files |
| `make clean` | Remove containers, volumes, and host data directories |
| `make fclean` | Full cleanup: containers, volumes, images, and host data directories |
| `make re` | Rebuild from scratch (`fclean` + `all`) |

## Access the Site

These URLs are valid when running on the default VM setup:

| URL | Description |
|---|---|
| `https://dbarba-v.42.fr` | Main website |
| `https://dbarba-v.42.fr/wp-admin` | WordPress admin dashboard |
| `https://dbarba-v.42.fr/wp-login.php` | WordPress login page |

## Secrets

Secrets are stored as plain-text files under `secrets/`.

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

Rules:

- Each file contains only the secret value.
- Do not add trailing newline characters.
- Do not commit secret files to source control.

If you run in a non-interactive environment (no TTY), `make` cannot prompt for missing values. Create all secret files beforehand.

## Verify the Stack

Check that all services are up:

```sh
make ps
```

Alternative direct command:

```sh
docker compose -f ./srcs/docker-compose.yml ps
```

## Troubleshooting Notes

- Site is not reachable: confirm `/etc/hosts` has both domain entries and verify service state with `make ps`.
- `make` fails due to missing secrets: run `make secrets` or create files manually in `secrets/`.
- Changes to Dockerfiles or templates are not applied: run `make build` or force a clean rebuild with `make re`.
