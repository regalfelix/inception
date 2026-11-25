#!/bin/bash
set -e

echo "Waiting for MariaDB..."
max_attempts=30
attempt=0

mysql_user=$(cat /run/secrets/mysql_user)
mysql_pass=$(cat /run/secrets/mysql_pass)
until mariadb -h mariadb -u"${mysql_user}" -p"${mysql_pass}" -e "SELECT 1" &> /dev/null; do
	attempt=$((attempt + 1))
	if [ $attempt -eq $max_attempts ]; then
		echo "ERROR: MariaDB not available after $max_attempts attempts"
		exit 1
	fi
	echo "Attempt $attempt/$max_attempts..."
	sleep 3
done
echo "MariaDB is ready!"


if [ ! -f "/var/www/html/init" ]; then

	echo "Running first time setup for Wordpress..."

	cd /var/www/html
	chown -R www-data:www-data "$PWD"

	export WP_CLI_CACHE_DIR=/tmp/wp-cli-cache

	wget -q -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x /usr/local/bin/wp

	# wordpress installation
	sudo -E -u www-data wp core download --locale=en_US --force

	#connect to mariadb
	sudo -E -u www-data wp config create \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${mysql_user}" \
		--dbpass="${mysql_pass}" \
		--dbhost=mariadb \
		--force

	sudo -E -u www-data wp config set WP_HOME "isset(\$_SERVER['HTTP_HOST']) ? 'https://' . \$_SERVER['HTTP_HOST'] : 'https://${DOMAIN_NAME}'" --raw
	sudo -E -u www-data wp config set WP_SITEURL "isset(\$_SERVER['HTTP_HOST']) ? 'https://' . \$_SERVER['HTTP_HOST'] : 'https://${DOMAIN_NAME}'" --raw

	# initialize webpage and stuff
	sudo -E -u www-data wp core is-installed || \
	sudo -E -u www-data wp core install \
		--url="https://${DOMAIN_NAME}" \
		--title="Inception" \
		--admin_user="$(cat /run/secrets/wp_admin)" \
		--admin_password="$(cat /run/secrets/wp_admin_pass)" \
		--admin_email="$(cat /run/secrets/wp_admin_email)" \
		--skip-email

	sudo -E -u www-data wp user get "$(cat /run/secrets/wp_user)" &> /dev/null || \
	sudo -E -u www-data wp user create \
		"$(cat /run/secrets/wp_user)" "$(cat /run/secrets/wp_user_email)" \
		--user_pass="$(cat /run/secrets/wp_user_pass)" \
		--role=author

	touch /var/www/html/init
	echo "Setup finished!!!"
fi

echo "Running php-fpm now..."
exec php-fpm8.2 -F
