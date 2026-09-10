FROM debian:bookworm

RUN	yes | (apt-get update && \
	apt-get upgrade && \
	apt-get install nginx)

RUN	mkdir -p /etc/nginx/ssl && \
	(yes | apt-get install openssl)

RUN	rm -rf /var/lib/apt/lists/*

RUN	openssl req -x509 -nodes \
	-out /etc/nginx/ssl/inception.crt \
	-keyout /etc/nginx/ssl/inception.key \
	-subj "/C=FR/ST=IDF/L=PARIS/O=42/OU=42/CN=jsantini.42.fr/UID=jsantini"

RUN	mkdir -p /var/run/nginx

COPY	conf/nginx.conf /etc/nginx/nginx.conf
COPY	conf/default.conf /etc/nginx/conf.d/default.conf

RUN	chmod 777 /var/www/html
RUN	chown -R www-data:www-data /var/www/html

CMD	[ "nginx", "-g", "daemon off;" ]
