This project has been created as part of the 42 curriculum by <login>.

Inception
Description

Inception is a system administration and Docker project from the 42 curriculum.

The goal of the project is to build a small infrastructure composed of several Docker containers, each running a specific service. The infrastructure is orchestrated with Docker Compose and provides a complete WordPress website served through an NGINX web server and connected to a MariaDB database.

The stack is composed of three main services:

NGINX: acts as the web server and reverse proxy. It handles HTTPS connections using TLS 1.2/1.3 and forwards PHP requests to WordPress.

WordPress + PHP-FPM: provides the website and its administration interface.

MariaDB: stores the WordPress database.

The services communicate through a dedicated Docker bridge network.

The project also uses persistent Docker volumes so that WordPress files and MariaDB data remain available when containers are stopped or recreated.

Project Description
Docker architecture

The project uses Docker to isolate each service into its own container.

The architecture is:

                    HTTPS :443
                        |
                        v
                +---------------+
                |     NGINX     |
                |  TLS 1.2/1.3  |
                +-------+-------+
                        |
                    FastCGI :9000
                        |
                        v
              +-------------------+
              |     WORDPRESS     |
              |    PHP-FPM        |
              +---------+---------+
                        |
                     MySQL :3306
                        |
                        v
              +-------------------+
              |      MARIADB      |
              +-------------------+

              Docker bridge network


Only NGINX exposes a port to the host:

Host 443 -> NGINX 443


WordPress PHP-FPM and MariaDB are only accessible through the Docker network.

Main design choices

The project follows a multi-container architecture where each container has a single main responsibility.

NGINX handles HTTPS and web requests.

WordPress handles PHP execution and the CMS.

MariaDB handles persistent database storage.

Docker Compose manages the complete application stack.

A private Docker bridge network allows containers to communicate by service name.

Docker volumes provide persistent storage.

TLS certificates are used to serve the website over HTTPS.

Virtual Machines vs Docker
Virtual Machines	Docker
Virtualizes an entire operating system	Uses containers sharing the host kernel
Usually requires more memory and storage	Lightweight compared with full VMs
Each VM contains its own OS	Containers contain only the required userspace
Slower to start	Containers start quickly
Stronger isolation at the OS level	Process-level isolation

For this project, Docker is appropriate because the objective is to isolate individual services without requiring a complete virtual machine for each service.

Secrets vs Environment Variables

Environment variables are convenient for configuration values such as database names, usernames, and domain names.

However, passwords and other sensitive credentials should ideally be managed as secrets rather than being directly stored in environment variables.

Environment variables have the advantage of being simple to configure and consume from Docker Compose, but they can be visible through container configuration and inspection commands.

Docker secrets provide a more appropriate mechanism for sensitive values because applications can read them from files inside the container.

For this project, environment variables are used by the initialization scripts to configure the services. In a production environment, sensitive passwords should preferably be managed using a dedicated secret-management mechanism.

Docker Network vs Host Network

A Docker bridge network provides an isolated virtual network for the containers.

In this project, services can communicate using their Docker service names:

wordpress -> mariadb:3306
nginx     -> wordpress:9000


The host network would remove much of this network isolation and make containers use the host's network namespace.

The Docker bridge network is therefore appropriate for this architecture because only NGINX needs to be reachable from the host.

Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker and are designed to persist container data independently from the container lifecycle.

This project uses volumes for:

/var/lib/mysql
/var/www/wordpress


The configured volumes are backed by host directories:

/home/<login>/data/mariadb
/home/<login>/data/wordpress


This allows the project data to persist when containers are recreated.

A bind mount directly maps an explicit host path into a container. It provides direct access to the host filesystem but requires the host path and permissions to be managed manually.

Docker-managed volumes are generally easier to manage through Docker, while bind mounts are useful when direct access to host files is required.

Services
NGINX

NGINX is the public entry point of the infrastructure.

It:

listens on port 443;

provides HTTPS;

uses TLS 1.2 and TLS 1.3;

serves the WordPress files;

forwards PHP requests to WordPress PHP-FPM.

WordPress

WordPress provides the CMS and website.

PHP-FPM listens internally on:

9000


It is not exposed directly to the host.

MariaDB

MariaDB provides the relational database used by WordPress.

It listens internally on:

3306


It is not published on the host.

Instructions
Prerequisites

The project requires:

Linux environment;

Docker;

Docker Compose;

GNU Make;

Git.

Verify Docker:

docker --version
docker compose version
make --version

Configuration

The project uses environment variables for configuration.

The main values include:

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


The domain used by this project is:

jsantini.42.fr


The host machine must resolve this domain to the Docker host.

For a local setup, /etc/hosts can contain:

127.0.0.1 jsantini.42.fr

Build and start

From the repository root:

make


The Makefile starts the Docker Compose infrastructure.

The project can also be started directly with:

docker compose -f ./srcs/docker-compose.yml up -d --build

Check the containers
docker compose -f ./srcs/docker-compose.yml ps


Expected services:

mariadb
wordpress
nginx

Access the website

Open:

https://jsantini.42.fr


Because the project uses a local/self-signed certificate, the browser may display a certificate warning.

Access WordPress administration

The administration interface is available at:

https://jsantini.42.fr/wp-admin/


Use the WordPress administrator credentials configured for the project.

Stop the project

To stop the containers:

docker compose -f ./srcs/docker-compose.yml stop


To stop and remove the containers:

docker compose -f ./srcs/docker-compose.yml down

Remove containers and volumes

The clean target removes the Compose containers and volumes:

make clean


Be careful: removing volumes can remove persistent Docker data depending on the configuration.

Full cleanup
make fclean


This also performs Docker system cleanup.

Rebuild from scratch
make re


This removes the existing infrastructure and rebuilds it.

Useful commands

View logs:

docker compose -f ./srcs/docker-compose.yml logs


Follow logs:

docker compose -f ./srcs/docker-compose.yml logs -f


View the NGINX configuration:

docker compose -f ./srcs/docker-compose.yml exec nginx nginx -T


Check the WordPress database configuration:

docker compose -f ./srcs/docker-compose.yml exec wordpress grep -E 'DB_(NAME|USER|HOST)' /var/www/wordpress/wp-config.php


Test HTTPS:

curl -kI https://jsantini.42.fr


A successful configuration should return an HTTP response such as:

HTTP/1.1 200 OK

Data Persistence

The project uses two persistent volumes.

MariaDB
/home/<login>/data/mariadb


mounted inside the MariaDB container as:

/var/lib/mysql

WordPress
/home/<login>/data/wordpress


mounted inside the WordPress container as:

/var/www/wordpress


Therefore, recreating the containers does not necessarily remove the website and database data.

Resources
Official documentation

Docker documentation: https://docs.docker.com/

Docker Compose documentation: https://docs.docker.com/compose/

NGINX documentation: https://nginx.org/en/docs/

WordPress documentation: https://developer.wordpress.org/

MariaDB documentation: https://mariadb.com/docs/

PHP-FPM documentation: https://www.php.net/manual/en/install.fpm.php

TLS documentation: https://developer.mozilla.org/en-US/docs/Web/Security/Transport_Layer_Security

AI usage

AI tools were used as a learning and assistance resource during the development of this project.

They were used for:

understanding Docker and Docker Compose concepts;

troubleshooting container communication;

understanding NGINX and PHP-FPM configuration;

checking Docker networking and volume concepts;

debugging commands and configuration errors;

improving documentation structure and explanations;

reviewing shell commands and Makefile logic.

The final project configuration, source files, commands, and architecture were reviewed and adapted manually to match the requirements of the 42 Inception subject.

Project Structure

A simplified project structure is:

.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs
    ├── docker-compose.yml
    └── requirements
        ├── mariadb
        ├── nginx
        └── wordpress


Each service has its own Dockerfile and configuration files.

Makefile

The main Makefile targets are:

make        Build and start the infrastructure
make clean  Stop and remove containers and volumes
make fclean Clean Docker resources
make re     Rebuild the complete infrastructure
