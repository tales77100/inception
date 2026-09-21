User Documentation
1. Overview

This project provides a WordPress website running inside a Docker infrastructure.

The stack contains three services:

NGINX: receives HTTPS requests and serves the website.

WordPress: provides the website and administration interface through PHP-FPM.

MariaDB: stores the WordPress database.

The services communicate through a private Docker network.

Only NGINX is directly accessible from the host through port 443.

2. Starting the Project

From the repository root, run:

make


If the Makefile uses detached mode, the command returns to the shell after starting the containers.

You can also start the project directly:

docker compose -f ./srcs/docker-compose.yml up -d --build

3. Checking the Services

Check the status of all containers:

docker compose -f ./srcs/docker-compose.yml ps


The expected services are:

mariadb
wordpress
nginx


All three should have a running status.

To check the logs:

docker compose -f ./srcs/docker-compose.yml logs


To continuously follow the logs:

docker compose -f ./srcs/docker-compose.yml logs -f

4. Accessing the Website

The website is available through HTTPS:

https://jsantini.42.fr


The browser may display a certificate warning because the project uses a local/self-signed TLS certificate.

You can also test the website from a terminal:

curl -kI https://jsantini.42.fr


A working installation should return an HTTP response such as:

HTTP/1.1 200 OK

5. Accessing the WordPress Administration Panel

The WordPress administration interface is available at:

https://jsantini.42.fr/wp-admin/


Log in using the WordPress administrator account configured for the project.

6. Credentials

The project uses credentials for:

the MariaDB root account;

the MariaDB WordPress database user;

the WordPress administrator account;

the WordPress regular user account.

Credentials are configured through the project's environment/configuration files and Docker Compose environment.

Do not publish real passwords in a public repository.

To inspect the WordPress database configuration:

docker compose -f ./srcs/docker-compose.yml exec wordpress grep -E 'DB_(NAME|USER|HOST)' /var/www/wordpress/wp-config.php


For security reasons, avoid displaying or committing passwords unnecessarily.

7. Stopping the Project

To stop the running containers:

docker compose -f ./srcs/docker-compose.yml stop


This stops the services without removing their containers.

To stop and remove the containers:

docker compose -f ./srcs/docker-compose.yml down

8. Restarting the Project

After stopping the project:

docker compose -f ./srcs/docker-compose.yml start


Alternatively, rebuild and start the complete infrastructure:

make

9. Data Persistence

The project stores persistent data outside the containers.

WordPress data

WordPress data is stored on the host under:

/home/<login>/data/wordpress


It is mounted inside the WordPress and NGINX containers at:

/var/www/wordpress

MariaDB data

MariaDB data is stored on the host under:

/home/<login>/data/mariadb


It is mounted inside the MariaDB container at:

/var/lib/mysql


This allows the data to survive container recreation.

10. Troubleshooting
Containers are not running

Check:

docker compose -f ./srcs/docker-compose.yml ps


Then inspect the logs:

docker compose -f ./srcs/docker-compose.yml logs

Website does not load

Check that NGINX is running:

docker compose -f ./srcs/docker-compose.yml ps nginx


Check the NGINX configuration:

docker compose -f ./srcs/docker-compose.yml exec nginx nginx -t


Test HTTPS:

curl -kI https://jsantini.42.fr

WordPress cannot connect to MariaDB

Check that both containers are running:

docker compose -f ./srcs/docker-compose.yml ps


Check that WordPress can resolve MariaDB:

docker compose -f ./srcs/docker-compose.yml exec wordpress getent hosts mariadb


Check the WordPress database configuration:

docker compose -f ./srcs/docker-compose.yml exec wordpress grep -E 'DB_(NAME|USER|HOST)' /var/www/wordpress/wp-config.php


The database host should use the Docker service name:

mariadb:3306

11. Removing the Project

The Makefile provides:

make clean


and:

make fclean


Be careful when using cleanup commands because volumes contain persistent WordPress and MariaDB data.
