FROM alpine:3.22 AS ssl
ARG KEY_NAME
ARG CERT_NAME
RUN apk add --no-cache openssl
RUN mkdir -p /etc/ssl/private /etc/ssl/certs \
	&& openssl req -x509 \
		-newkey rsa:4096 \
		-keyout "/etc/ssl/private/${KEY_NAME}" \
		-out "/etc/ssl/certs/${CERT_NAME}" \
		-sha256 \
		-days 3650 \
		-nodes \
		-subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Inception/CN=dbarba-v.42.fr"

FROM debian:12
ARG KEY_NAME
ARG CERT_NAME
LABEL org.opencontainers.image.authors=dbarba-v@student.42madrid.com

RUN apt-get update \
	&& apt-get install -y nginx gettext-base \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=SSL /etc/ssl/private/${KEY_NAME} /etc/ssl/private/${KEY_NAME}
COPY --from=SSL /etc/ssl/certs/${CERT_NAME} /etc/ssl/certs/${CERT_NAME}

COPY --link ./tools/setup.sh /usr/local/bin/setup.sh

COPY --link ./nginx.conf /etc/nginx/nginx.conf
COPY --link ./conf.d/server.conf.tmpl /etc/nginx/conf.d/server.conf.tmpl

# COPY --link ./tools/index.html var/www/dbarba-v.42.fr/public/index.html

RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/setup.sh"]

EXPOSE 9000
EXPOSE 443