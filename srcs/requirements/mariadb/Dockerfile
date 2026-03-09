FROM debian:12

LABEL org.opencontainers.image.authors=dbarba-v@student.42madrid.com

RUN apt-get update && apt-get install -y --no-install-recommends \
	mariadb-server \
	mariadb-client \
	gettext-base \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld /var/lib/mysql /var/log/mariadb \
	&& chown -R mysql:mysql /run/mysqld /var/lib/mysql /etc/mysql/mariadb.conf.d/ /var/log/

WORKDIR /mariadb-docker

COPY --link . .

RUN chmod +x /mariadb-docker/tools/setup.sh
RUN chmod +x /mariadb-docker/tools/healthcheck.sh

ENTRYPOINT ["/bin/bash", "/mariadb-docker/tools/setup.sh"]

EXPOSE 3306
