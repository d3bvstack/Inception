# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dbarba-v <dbarba-v@student.42madrid.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/02/23 09:42:26 by dbarba-v          #+#    #+#              #
#    Updated: 2026/02/23 10:30:37 by dbarba-v         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = inception

COMPOSE = docker compose

DOCKERFILE = srcs/docker-compose.yml

# .env file, can be overridden
ENV ?= srcs/.env

UP = $(COMPOSE) -f $(DOCKERFILE) up -d
DOWN = $(COMPOSE) -f $(DOCKERFILE) down
STOP = $(COMPOSE) -f $(DOCKERFILE) stop
RESTART = $(COMPOSE) -f $(DOCKERFILE) restart
PS = $(COMPOSE) -f $(DOCKERFILE) ps
BUILD = $(COMPOSE) --env-file $(ENV) -f $(DOCKERFILE) build
CONFIG = $(COMPOSE) -f $(DOCKERFILE) config

# clean removes volumes
# fclean also prunes images
CLEAN = $(COMPOSE) -f $(DOCKERFILE) down --volumes
FCLEAN = $(COMPOSE) -f $(DOCKERFILE) down --volumes --rmi all

.PHONY: all up down stop restart ps shell build config clean fclean re help

all: up

up:
	$(UP)

down:
	$(DOWN)

stop:
	$(STOP)

restart:
	$(RESTART)

ps:
	$(PS)

shell:
	@# Usage: make shell SERVICE=<service>
	@if [ -z "$(SERVICE)" ]; then \
		echo "Error: SERVICE is not set"; \
		echo "Usage: make shell SERVICE=<service>"; \
		exit 1; \
	fi
	$(COMPOSE) -f $(DOCKERFILE) exec $(SERVICE) /bin/sh

build:
	$(BUILD)

config:
	$(CONFIG)

clean:
	$(CLEAN)

fclean:
	$(FCLEAN)

re: fclean all

help:
	@printf "\n"
	@echo "Inception - Makefile targets"
	@echo "Usage: make TARGET [VAR=value]               (e.g. make shell SERVICE=nginx)"
	@echo ""
	@echo "Targets:"
	@echo "  all        Start all containers (default -> up)"
	@echo "  up         Start all containers in detached mode"
	@echo "  down       Stop and remove all containers"
	@echo "  stop       Stop running containers"
	@echo "  restart    Restart containers"
	@echo "  ps         Show container status"
	@echo "  shell      Open a shell in a service (SERVICE=<name>)"
	@echo "  build      Build images (uses $(ENV) for build args)"
	@echo "  config     Validate and show compose configuration"
	@echo "  clean      Stop/remove containers and volumes"
	@echo "  fclean     Full cleanup: containers, volumes and images"
	@echo "  re         Full rebuild (fclean + all)"
	@echo "  help       Show this help"
	@echo ""
	@echo "Useful variables:"
	@echo "  SERVICE    Service name for 'shell' and 'exec' operations"
	@echo "  ENV        .env file used by build ($(ENV))"
	@echo ""
	@echo "Examples:"
	@echo "  make up                    # Start everything"
	@echo "  make shell SERVICE=nginx   # Open sh in nginx container"
	@echo "  make build                 # Build images with env from $(ENV)"
	@echo ""
