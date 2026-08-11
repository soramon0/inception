#!/bin/sh
set -e

# Options-only args → default to mysqld (e.g. `docker run mariadb --verbose`)
if [ "${1#-}" != "$1" ]; then
	set -- mysqld "$@"
fi

if [ "$1" = "mysqld" ]; then
	: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
	: "${MYSQL_USER:?MYSQL_USER is required}"

	DB_ROOT_PASSWORD="$(tr -d '\r\n' < /run/secrets/db_root_password)"
	DB_PASSWORD="$(tr -d '\r\n' < /run/secrets/db_password)"

	: "${DB_ROOT_PASSWORD:?db_root_password secret is empty}"
	: "${DB_PASSWORD:?db_password secret is empty}"

	MYSQL="mysql --protocol=socket --socket=/run/mysqld/mysqld.sock"
	MYSQLADMIN="mysqladmin --protocol=socket --socket=/run/mysqld/mysqld.sock"

	wait_socket() {
		i=0
		while [ "$i" -lt 60 ]; do
			if $MYSQLADMIN ping --silent 2>/dev/null; then
				return 0
			fi
			i=$((i + 1))
			sleep 1
		done
		echo "[mariadb] Timed out waiting for temporary server" >&2
		return 1
	}

	init_or_repair() {
		mysqld --user=mysql --skip-networking &
		pid="$!"
		wait_socket

		# Brand-new datadir: root has no password yet
		if $MYSQL -u root -e "SELECT 1" >/dev/null 2>&1; then
			$MYSQL -u root <<-EOSQL
				ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
				CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
				CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
				ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
				GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
				FLUSH PRIVILEGES;
			EOSQL
		else
			$MYSQL -u root -p"${DB_ROOT_PASSWORD}" <<-EOSQL
				CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
				CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
				ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
				GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
				FLUSH PRIVILEGES;
			EOSQL
		fi
		$MYSQLADMIN -u root -p"${DB_ROOT_PASSWORD}" shutdown

		wait "$pid" || true
	}

	if [ ! -d "/var/lib/mysql/mysql" ]; then
		echo "[mariadb] Initializing data directory..."
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null
		init_or_repair
		echo "[mariadb] Database '${MYSQL_DATABASE}' and user '${MYSQL_USER}' ready."
	elif [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
		echo "[mariadb] Repairing missing database/user..."
		init_or_repair
		echo "[mariadb] Repair complete."
	fi
fi

exec "$@"
