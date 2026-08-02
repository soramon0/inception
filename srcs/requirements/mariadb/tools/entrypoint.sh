#!/bin/sh
set -e

DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
DB_PASSWORD="$(cat /run/secrets/db_password)"

# First boot only: create datadir, database, and app user
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[mariadb] Initializing data directory..."
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null

	# Temporary server for setup (not PID 1 of the final container)
	mysqld --user=mysql --skip-networking &
	pid="$!"

	echo "[mariadb] Waiting for server..."
	i=0
	while [ "$i" -lt 60 ]; do
		if mysqladmin --socket=/run/mysqld/mysqld.sock ping --silent 2>/dev/null; then
			break
		fi
		i=$((i + 1))
		sleep 1
	done

	mysql --socket=/run/mysqld/mysqld.sock -u root <<-EOSQL
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		FLUSH PRIVILEGES;
	EOSQL

	mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASSWORD}" shutdown
	wait "$pid" || true
	echo "[mariadb] Database '${MYSQL_DATABASE}' and user '${MYSQL_USER}' ready."
fi

# Real daemon as PID 1
exec mysqld --user=mysql
