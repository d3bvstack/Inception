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
make all
```

> Aliases: `make up` or `make inception`

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

Secrets are stored as plain-text files under `./secrets/`:

```
secrets/
├── database/
│   ├── dbuser_password
│   └── root_password
└── wordpress/
    ├── admin_password
    └── editor_password
```

---

## Verifying the Infrastructure

Check that all services are running:

```sh
make ps
# or
docker compose -f ./srcs/docker-compose.yml ps
```
