FROM debian:12

ARG DOMAIN_NAME
ARG PHP_FPM_VERSION

LABEL org.opencontainers.image.authors=dbarba-v@student.42madrid.com

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		gnupg \
		lsb-release \
		php-fpm \
		php-cli \
		php-curl \
		php-xml \
		php-intl \
		php-mysql \
		php-mbstring \
		php-zip \
		php-imagick \
		ghostscript \
		imagemagick \
		openssl \
		gettext-base \
		netcat-openbsd \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www \
	&& chown -R www-data:www-data /var/www

COPY --link ./php-fpm.conf     /etc/php/${PHP_FPM_VERSION}/fpm/php-fpm.conf.tmpl
COPY --link ./tools/setup.sh         /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh
# RUN chmod +x /usr/local/bin/health_check.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/setup.sh"]

EXPOSE 9000