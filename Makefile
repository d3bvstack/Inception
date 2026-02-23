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

ENV = srcs/.env

UP = $(COMPOSE) -f $(DOCKERFILE) up -d

DOWN = $(COMPOSE) -f $(DOCKERFILE) down

STOP = $(COMPOSE) -f $(DOCKERFILE) stop

RESTART = $(COMPOSE) -f $(DOCKERFILE) restart

PS = $(COMPOSE) -f $(DOCKERFILE) ps

BUILD = $(COMPOSE) --env-file $(ENV) -f $(DOCKERFILE) build

CONFIG = $(COMPOSE) -f $(DOCKERFILE) config

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
	@echo "Usage: make [target] [SERVICE=<service>]"
	@echo "Targets: all up down stop restart ps shell build config clean fclean re help"
