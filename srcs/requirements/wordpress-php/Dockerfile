FROM debian:12

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

WORKDIR /wordpress-php-docker

COPY --link . .

RUN chmod +x /wordpress-php-docker/tools/setup.sh

ENTRYPOINT ["/bin/bash", "/wordpress-php-docker/tools/setup.sh"]

EXPOSE 9000