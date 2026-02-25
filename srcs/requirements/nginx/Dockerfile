FROM alpine:3.22 AS ssl
ARG SSL_KEY
ARG SSL_CERT
RUN apk add --no-cache openssl
RUN mkdir -p /etc/ssl/private /etc/ssl/certs \
	&& openssl req -x509 \
		-newkey rsa:4096 \
		-keyout "/etc/ssl/private/${SSL_KEY}" \
		-out "/etc/ssl/certs/${SSL_CERT}" \
		-sha256 \
		-days 3650 \
		-nodes \
		-subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Inception/CN=dbarba-v.42.fr"

FROM debian:12
ARG SSL_KEY
ARG SSL_CERT
LABEL org.opencontainers.image.authors=dbarba-v@student.42madrid.com

RUN apt-get update \
	&& apt-get install -y nginx \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=SSL /etc/ssl/private/${SSL_KEY} /etc/ssl/private/${SSL_KEY}
COPY --from=SSL /etc/ssl/certs/${SSL_CERT} /etc/ssl/certs/${SSL_CERT}

COPY --link ./tools/setup.sh /usr/local/bin/setup.sh

COPY --link ./nginx.conf /etc/nginx/nginx.conf
COPY --link ./conf.d/server.conf.tmpl /etc/nginx/conf.d/server.conf.tmpl

RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT ["/bin/bash", "setup.sh"]