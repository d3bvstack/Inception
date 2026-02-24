The project uses the following variables at .env that you can customize to change the configuration


USER_LOGIN: Name that will be used for domain name
DOMAIN_NAME: Domain name of resulting website

# Networks
# Frontend network that connects nginx <-> internet and nginx <-> php-fpm
NETWORK_FRONTEND_NAME: name that will be given to the frontend network
NETWORK_FRONTEND_SUBNET: subnet that frontend network will use
NETWORK_FRONTEND_GATEWAY: frontend network gateway
NETWORK_FRONTEND_NGINX_IP: IP of NGINX container
NETWORK_FRONTEND_PHPFPM_IP: IP of container with the phpfpm runner
# Backend network that connects php-fpm <-> mariadb
NETWORK_BACKEND_NAME: name that will be given to the backend network
NETWORK_BACKEND_SUBNET: subnet that backend network will use
NETWORK_BACKEND_GATEWAY: backend network gateway
NETWORK_BACKEND_PHPFPM_IP: IP of container with the phpfpm runner
NETWORK_BACKEND_DB_IP: IP of container with the database container

# Volumes
VOLUME_DB_NAME: name for the database
VOLUME_DB_MOUNTPOINT: route that will be used as volume where db data is
VOLUME_DB_HOST_PATH: route on host that will be used as volume where db data will be saved