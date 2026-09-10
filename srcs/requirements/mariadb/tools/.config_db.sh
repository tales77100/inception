#!/bin/bash


mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

mysqld_safe --datadir=/var/lib/mysql &
sleep 5

mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"

mysql -e "CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';"

mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%'"

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

mysql -e "FLUSH PRIVILEGES;"

mysqladmin -u root -p"{$SQL_ROOT_PASSWORD}" shutdown

exec mysqld_safe --datadir=/var/lib/mysql
