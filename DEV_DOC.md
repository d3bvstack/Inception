The project uses the following variables at .env that you can customize to change the configuration


USER_LOGIN: Name that will be used for domain name
DOMAIN_NAME: Domain name of resulting website

# Networks
Frontend network that connects nginx <-> internet and nginx <-> php-fpm
NETWORK_FRONTEND_NAME: name that will be given to the frontend network
NETWORK_FRONTEND_SUBNET: subnet that frontend network will use
NETWORK_FRONTEND_GATEWAY: frontend network gateway
NETWORK_FRONTEND_NGINX_IP: IP of NGINX container
NETWORK_FRONTEND_PHPFPM_IP: IP of container with the phpfpm runner

Backend network that connects php-fpm <-> mariadb
NETWORK_BACKEND_NAME: name that will be given to the backend network
NETWORK_BACKEND_SUBNET: subnet that backend network will use
NETWORK_BACKEND_GATEWAY: backend network gateway
NETWORK_BACKEND_PHPFPM_IP: IP of container with the phpfpm runner
NETWORK_BACKEND_DB_IP: IP of container with the database container

Volumes
VOLUME_DB_NAME: name for the database volume
VOLUME_DB_MOUNTPOINT: route on container where the volume will be mounted
VOLUME_DB_HOST_PATH: route on host where the volume will be saved
VOLUME_WP_NAME: name for the wordpress volume
VOLUME_WP_MOUNTPOINT: route on container where the volume will be mounted
VOLUME_WP_HOST_PATH: route on host where the volume will be saved

MariaDB
MDB_BUILD_CONTEXT: Context for mariadb image build
MDB_DOCKERFILE: Name of mariadb dockefile name
MDB_IMAGE_REPO: Name of Image repo
MDB_IMAGE_TAG: Name of Image tag
MDB_CONTAINER_NAME: Name for the new container

-----

- MDB_CONFIG_ENV=##
- MDB_ROOT_PASSWORD=## SECRET
- MDB_ADMIN=##
- MDB_ADMIN_PASSWORD=## SECRET
- MDB_CHARSET=##
- MDB_COLLATION=##
- MDB_ENGINE_PORT=##

-----

Wordpress
WP_DB_NAME: name for wordpress database on creation and for wp installation
WP_DB_ADMIN: name for the mariadb user that will have privileges over the wordpress db
WP_DB_ADMIN_PASSWORD=## SECRET
WP_DB_CHARSET: wordpress database charset
WP_DB_COLLATION: wordpress database collation

WP_BUILD_CONTEXT: Context for wordpress image build
WP_DOCKERFILE: Name of wordpress dockefile name
WP_IMAGE_REPO: Name of Image repo
WP_IMAGE_TAG: Name of Image tag
WP_CONTAINER_NAME: name of wordpress container

-----
- WP_CONFIG_ENV=##
- PHPFPM_LISTEN_PORT=##
- PHPFPM_USER=##
- NGINX=##
- NGINX_PORT=##
- DB_HOST=##
- DB_SERVICE_PORT=##
- DB_NAME=##
- DB_USER=##
- DB_USER_PASSWORD=##
- WP_USERS_CREATE=##
- WP_WEBROOT=##

-----

Nginx
NGINX_BUILD_CONTEXT: context for nginx image build
NGINX_DOCKERFILE: Name of dockerfile for nginx image
NGINX_IMAGE_REPO: nginx image repo name
NGINX_IMAGE_TAG: nginx image tag
NGINX_CONTAINER_NAME: container name of instantiating the container
