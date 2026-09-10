#!/bin/bash

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

mysqld_safe --datadir=/var/lib/mysql &
pid=$!

until mysqladmin ping --silent; do
    sleep 2
done

mysql <<EOF
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF


wait $pid

if [ ! -f /var/lib/mysql/.initialized ]; then
    touch /var/lib/mysql/.initialized
fi

exec mysqld_safe --datadir=/var/lib/mysql
