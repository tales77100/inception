FROM		debian:bookworm

RUN		yes | ( apt upgrade && \
		apt update)

RUN		apt-get install mariadb-server -y

COPY		conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY		./tools/config_db.sh /etc/mysql/mariadb.conf.d/config_db.sh

ENTRYPOINT	bash /etc/mysql/mariadb.conf.d/config_db.sh
