FROM debian:12

LABEL org.opencontainers.image.authors=dbarba-v@student.42madrid.com

RUN apt-get update && apt-get install -y --no-install-recommends \
	mariadb-server \
	mariadb-client \
	gettext-base \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld /var/lib/mysql \
	&& chown -R mysql:mysql /run/mysqld /var/lib/mysql /etc/mysql/mariadb.conf.d/ /var/log/

COPY ./conf.d/my.cnf.tmpl /tmp/my.cnf.tmpl
COPY ./tools/setup.sh     /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/setup.sh"]

EXPOSE 3306
