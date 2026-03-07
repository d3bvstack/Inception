FROM debian:12
LABEL org.opencontainers.image.authors=dbarba-v@student.42madrid.com

RUN apt-get update \
	&& apt-get install -y nginx gettext-base \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /nginx-docker

COPY --link . .

RUN chmod +x /nginx-docker/tools/setup.sh

ENTRYPOINT ["/bin/bash", "/nginx-docker/tools/setup.sh"]

EXPOSE 443