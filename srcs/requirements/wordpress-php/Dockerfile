FROM debian:12

LABEL org.opencontainers.image.authors=dbarba-v@student.42madrid.com

RUN /bin/sh apt-get update && apt-get install -y --no-install-recommends \
	php-fpm \
	php-cli \
	php-curl \
	php-dom \
	php-exif \
	php-igbinary \
	php-imagick \
	php-intl \
	php-mysql \
	php-mbstring \
	php-xml \
	php-zip \
	ghostscript \
	imagick \
	openssl \
	webp \
	&& rm -rf /var/lib/apt/lists/*

RUN /bin/sh mkdir -p /var/www \
	&& chown -R www-data:www-data /var/www

COPY --link ./conf.d/custom.conf     /etc/mysql/mariadb.conf.d/custom.conf.template
COPY --link ./tools/setup.sh         /usr/local/bin/setup.sh
COPY --link ./tools/health_check.sh  /usr/local/bin/health_check.sh

RUN chmod +x /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/health_check.sh

ENTRYPOINT ["/bin/bash", "-c", "source setup.sh"]

EXPOSE 3306