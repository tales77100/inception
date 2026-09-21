Developer Documentation
1. Development Environment

This project is a Docker-based infrastructure composed of:

NGINX;

WordPress;

PHP-FPM;

MariaDB;

Docker Compose;

a dedicated Docker bridge network;

persistent storage volumes;

TLS certificates.

The project is designed to run on a Linux environment.

2. Prerequisites

Install the following tools:

docker --version
docker compose version
make --version
git --version


The Docker daemon must be running.

The developer must also have sufficient permissions to run Docker commands.

3. Repository Structure

The project follows a structure similar to:

.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs
    ├── docker-compose.yml
    └── requirements
        ├── mariadb
        │   ├── Dockerfile
        │   └── ...
        ├── nginx
        │   ├── Dockerfile
        │   └── ...
        └── wordpress
            ├── Dockerfile
            └── ...


The exact contents of the service directories depend on the implementation.

4. Docker Compose

The main Compose file is:

srcs/docker-compose.yml


It defines three services:

mariadb
wordpress
nginx


The services share the Docker network:

srcs_inception

MariaDB

MariaDB provides the database used by WordPress.

The database service exposes port 3306 only inside the Docker network.

WordPress

WordPress runs PHP through PHP-FPM.

PHP-FPM listens on:

9000


This port is exposed to the Docker network but is not published directly to the host.

NGINX

NGINX is the public-facing service.

The host publishes:

443:443


NGINX communicates with WordPress through:

wordpress:9000

5. Configuration

The infrastructure uses configuration variables for the domain, database and WordPress installation.

Typical variables include:

DOMAIN_NAME
SQL_DATABASE
SQL_USER
SQL_PASSWORD
SQL_ROOT_PASSWORD

WP_ADMIN_USER
WP_ADMIN_PASSWORD
WP_ADMIN_EMAIL

WP_USER
WP_USER_PASSWORD
WP_USER_EMAIL
WP_TITLE


The configuration should be reviewed before starting a fresh installation.

Passwords should not be committed to a public Git repository.

For a production environment, sensitive values should preferably be provided through a dedicated secrets-management mechanism.

6. Domain Configuration

The project uses:

jsantini.42.fr


For local development, the domain should resolve to the Docker host.

For example:

127.0.0.1 jsantini.42.fr


can be added to:

/etc/hosts


The actual IP address should match the machine hosting the Docker infrastructure.

7. Building the Project

The recommended Makefile command is:

make


A direct Docker Compose build can be performed with:

docker compose -f ./srcs/docker-compose.yml build


To build and start everything:

docker compose -f ./srcs/docker-compose.yml up -d --build

8. Makefile Commands

The Makefile provides the main project lifecycle commands.

Start
make


Builds and starts the Docker infrastructure.

Clean
make clean


Stops and removes the Compose infrastructure according to the Makefile configuration.

Full cleanup
make fclean


Performs the project's complete Docker cleanup procedure.

Rebuild
make re


Performs a cleanup followed by a fresh build and start.

9. Container Management

List running containers:

docker compose -f ./srcs/docker-compose.yml ps


View all containers:

docker ps -a


View logs:

docker compose -f ./srcs/docker-compose.yml logs


Follow logs:

docker compose -f ./srcs/docker-compose.yml logs -f


View logs for one service:

docker compose -f ./srcs/docker-compose.yml logs -f nginx
docker compose -f ./srcs/docker-compose.yml logs -f wordpress
docker compose -f ./srcs/docker-compose.yml logs -f mariadb


Restart a service:

docker compose -f ./srcs/docker-compose.yml restart nginx


Open a shell in a container:

docker compose -f ./srcs/docker-compose.yml exec nginx sh
docker compose -f ./srcs/docker-compose.yml exec wordpress sh
docker compose -f ./srcs/docker-compose.yml exec mariadb sh

10. Network Management

List Docker networks:

docker network ls


Inspect the project network:

docker network inspect srcs_inception


The containers should be attached to the same network.

Docker's internal DNS allows services to communicate using their Compose service names.

For example:

wordpress -> mariadb
nginx     -> wordpress

11. Volumes and Persistence

The project uses persistent storage for both the database and WordPress files.

The Compose configuration defines:

mariadb
wordpress

MariaDB volume

The volume is mounted at:

/var/lib/mysql


and uses the host directory:

/home/<login>/data/mariadb

WordPress volume

The volume is mounted at:

/var/www/wordpress


and uses the host directory:

/home/<login>/data/wordpress


List volumes:

docker volume ls


Inspect a volume:

docker volume inspect srcs_mariadb
docker volume inspect srcs_wordpress


The persistent data should not be deleted during normal development unless a completely fresh installation is required.

12. NGINX Development

The active NGINX configuration can be inspected with:

docker compose -f ./srcs/docker-compose.yml exec nginx nginx -T


Validate the configuration:

docker compose -f ./srcs/docker-compose.yml exec nginx nginx -t


The project uses HTTPS on port 443.

The PHP requests are forwarded to:

wordpress:9000


The important NGINX configuration concept is:

location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass wordpress:9000;
}

13. WordPress Development

The WordPress installation is located inside the container at:

/var/www/wordpress


The database configuration can be checked with:

docker compose -f ./srcs/docker-compose.yml exec wordpress grep -E 'DB_(NAME|USER|HOST)' /var/www/wordpress/wp-config.php


The expected database host is:

mariadb:3306


This uses the Docker service name instead of an IP address.

14. MariaDB Development

From the WordPress container, the database can be tested using the MariaDB client:

docker compose -f ./srcs/docker-compose.yml exec wordpress mariadb -h mariadb -uuser -p


The database service can also be inspected through its logs:

docker compose -f ./srcs/docker-compose.yml logs mariadb


The database is stored persistently under:

/home/<login>/data/mariadb

15. Service Connectivity

The expected communication paths are:

Browser
   |
   | HTTPS :443
   v
NGINX
   |
   | FastCGI :9000
   v
WordPress / PHP-FPM
   |
   | MariaDB :3306
   v
MariaDB


Service name resolution can be tested from the containers.

From NGINX:

docker compose -f ./srcs/docker-compose.yml exec nginx getent hosts wordpress


From WordPress:

docker compose -f ./srcs/docker-compose.yml exec wordpress getent hosts mariadb

16. Testing

Test NGINX configuration:

docker compose -f ./srcs/docker-compose.yml exec nginx nginx -t


Test the HTTPS endpoint:

curl -kI https://jsantini.42.fr


Check the expected status:

HTTP/1.1 200 OK


Check the complete Compose configuration:

docker compose -f ./srcs/docker-compose.yml config


This is useful for detecting incorrect YAML, environment variables, networks, volumes and service definitions.

17. Rebuilding After Changes

After modifying a Dockerfile or build configuration:

docker compose -f ./srcs/docker-compose.yml up -d --build


To force a complete rebuild without using previous build layers:

docker compose -f ./srcs/docker-compose.yml build --no-cache


Then start the services:

docker compose -f ./srcs/docker-compose.yml up -d

18. Persistent Data and Fresh Installation

The containers are disposable, while the WordPress and MariaDB data are persistent.

Removing and recreating containers should not normally remove:

/home/<login>/data/wordpress
/home/<login>/data/mariadb


A fresh installation requires removing the persistent data as well.

This must be done carefully because deleting these directories permanently removes the stored WordPress files and MariaDB database.

19. Debugging Checklist

When the website does not work, check the stack from the outside toward the database:

Step 1: Containers
docker compose -f ./srcs/docker-compose.yml ps

Step 2: Logs
docker compose -f ./srcs/docker-compose.yml logs

Step 3: NGINX configuration
docker compose -f ./srcs/docker-compose.yml exec nginx nginx -t

Step 4: Docker DNS
docker compose -f ./srcs/docker-compose.yml exec nginx getent hosts wordpress

docker compose -f ./srcs/docker-compose.yml exec wordpress getent hosts mariadb

Step 5: WordPress database configuration
docker compose -f ./srcs/docker-compose.yml exec wordpress grep -E 'DB_(NAME|USER|HOST)' /var/www/wordpress/wp-config.php

Step 6: Database connectivity
docker compose -f ./srcs/docker-compose.yml exec wordpress mariadb -h mariadb -uuser -p

Step 7: HTTPS
curl -kI https://jsantini.42.fr


A working installation should return an HTTP response from NGINX/WordPress.

20. Security Considerations

Do not commit sensitive credentials to Git.

Avoid exposing MariaDB or PHP-FPM directly on the host.

The architecture intentionally exposes only:

443 -> NGINX


while:

3306 -> MariaDB
9000 -> PHP-FPM


remain internal to the Docker network.

TLS is enabled in NGINX using the project's certificate and key.

For production deployments, credentials should be managed using secrets rather than plain environment variables, and certificates should be issued by a trusted certificate authority.

21. AI Usage During Development

AI tools were used as a development and learning aid for:

understanding Docker concepts;

understanding Docker Compose service configuration;

troubleshooting networking and service connectivity;

debugging NGINX and PHP-FPM configuration;

understanding WordPress/MariaDB configuration;

reviewing Makefile commands;

troubleshooting Docker commands;

improving documentation.

AI-generated suggestions were checked against the actual project environment and adapted manually where necessary.
