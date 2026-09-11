sleep 15

mkdir -p /run/php

if  [ ! -f /var/www/wordpress/wp-config.php ]; then
	wp config create	--allow-root \
				--dbname=$SQL_DATABASE \
				--dbuser=$SQL_USER \
				--dbpass=$SQL_PASSWORD \
				--dbhost=mariadb:3306 \
				--path='/var/www/wordpress'
fi


if ! wp core is-installed --allow-root --path=/var/www/wordpress; then
	wp core install --allow-root 				\
			--url="$DOMAIN_NAME"			\
			--title="$WP_TITLE"			\
			--admin_user="$WP_ADMIN_USER"		\
			--admin_password="$WP_ADMIN_PASSWORD"	\
			--admin_email="$WP_ADMIN_EMAIL"		\
			--path=/var/www/wordpress

	wp user create	"$WP_USER"			\
			"$WP_USER_EMAIL"		\
			--user_pass="$WP_USER_PASSWORD"	\
			--allow-root			\
			--path=/var/www/wordpress
fi

exec /usr/sbin/php-fpm8.2 -F

