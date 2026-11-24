#!/bin/bash
set -e

user=$(cat /run/secrets/mysql_user)
pass=$(cat /run/secrets/mysql_pass)
root_pass=$(cat /run/secrets/mysql_root_pass)

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

#first start only (the wordpress database doesn't exist yet)
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then

	#initial database setup, if already exists skip
	if [ ! -d /var/lib/mysql/mysql ]; then
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
	fi

	mariadbd --user=mysql --skip-networking & #start mariadb in bg to configure database
	pid=$!

	#wait for process to start correctly but gives up after 30s
	for i in $(seq 1 30); do
		mysqladmin ping > /dev/null 2>&1 && break
		sleep 1
	done

	mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}"
	mysql -u root -e "CREATE USER IF NOT EXISTS '${user}'@'%' IDENTIFIED BY '${pass}'"
	mysql -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${user}'@'%'"
	mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${root_pass}'"
	mysql -u root -p"${root_pass}" -e "FLUSH PRIVILEGES"
	mysqladmin -u root -p"${root_pass}" shutdown #shut down server after setup
	wait "$pid"
fi

exec mariadbd --user=mysql #run server (as PID 1) after first time setup
