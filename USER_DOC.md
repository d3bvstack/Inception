Services provided by the infrastructure are
- nginx as reverse proxy
- wordpress for CMS
- PHPfpm for php runtime
- MariaDB for manageing mysql database

use make all/up/inception to get the infrastructure up,
make stop for stopping the infrastructure,
make restart to restart containers and infrastructure,
make fclean to stop, remove containers, networks and images

Once launched, you can access the page at dbarba-v.42.fr and access the admin panel via dbarba.42.fr/wp-admin or dbarba.42.fr/wp-login.php and entering valid credentials.

Credentials should be at /secrets as separate files
- ./secrets/database/dbuser_password
- ./secrets/database/root_password
- ./secrets/wordpress/admin_password
- ./secrets/wordpress/editor_password

Once started you can verify that the services are running correctly by using make ps or docker compose -f ./src/docker-compose.yml ps
