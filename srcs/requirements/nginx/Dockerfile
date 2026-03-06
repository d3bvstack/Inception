FROM debian:12
LABEL org.opencontainers.image.authors=dbarba-v@student.42madrid.com

RUN apt-get update \
	&& apt-get install -y nginx gettext-base \
	&& rm -rf /var/lib/apt/lists/*

COPY --link ./tools/setup.sh /usr/local/bin/setup.sh

COPY --link ./nginx.conf /etc/nginx/nginx.conf
COPY --link ./conf.d/server.conf.tmpl /etc/nginx/conf.d/server.conf.tmpl

# COPY --link ./tools/index.html var/www/dbarba-v.42.fr/public/index.html

RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/setup.sh"]

EXPOSE 443