FROM		debian:bookworm

RUN		yes | ( apt-get update && \
		apt-get upgrade)

RUN		apt-get install wget -y

RUN	 	apt-get install -y	php8.2		\
			php8.2-fpm		\
			php8.2-mysql	\
			mariadb-client

RUN		wget https://fr.wordpress.org/wordpress-7.1-fr_FR.tar.gz -P /var/www

RUN		cd /var/www && tar -xzf wordpress-7.1-fr_FR.tar.gz && rm wordpress-7.1-fr_FR.tar.gz

RUN		chown -R www-data:www-data /var/www/wordpress

COPY		./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

RUN		wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

RUN		chmod +x wp-cli.phar

RUN		mv wp-cli.phar /usr/local/bin/wp

COPY		./tools/auto_conf.sh /home

ENTRYPOINT	bash /home/auto_conf.sh
