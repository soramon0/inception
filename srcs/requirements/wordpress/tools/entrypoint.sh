#!/bin/sh
set -e

if [ "${1#-}" != "$1" ]; then
	set -- php-fpm83 "$@"
fi

if [ "$1" = "php-fpm83" ]; then
	: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
	: "${MYSQL_USER:?MYSQL_USER is required}"
	: "${MYSQL_HOST:?MYSQL_HOST is required}"
	: "${DOMAIN_NAME:?DOMAIN_NAME is required}"
	: "${WP_TITLE:?WP_TITLE is required}"
	: "${WP_ADMIN_USER:?WP_ADMIN_USER is required}"
	: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}"
	: "${WP_USER:?WP_USER is required}"
	: "${WP_USER_EMAIL:?WP_USER_EMAIL is required}"

	DB_PASSWORD="$(tr -d '\r\n' < /run/secrets/db_password)"

	WP_ADMIN_PASSWORD=""
	WP_USER_PASSWORD=""
	while IFS='=' read -r key value; do
		case "$key" in
			\#*|"") continue ;;
		esac
		value="$(printf '%s' "$value" | tr -d '\r')"
		case "$key" in
			WP_ADMIN_PASSWORD) WP_ADMIN_PASSWORD="$value" ;;
			WP_USER_PASSWORD) WP_USER_PASSWORD="$value" ;;
		esac
	done < /run/secrets/credentials

	: "${DB_PASSWORD:?db_password secret is empty}"
	: "${WP_ADMIN_PASSWORD:?WP_ADMIN_PASSWORD is required in credentials}"
	: "${WP_USER_PASSWORD:?WP_USER_PASSWORD is required in credentials}"

	# WP-CLI needs more than the default 128M to extract WordPress
	wp() {
		php -d memory_limit=512M /usr/local/bin/wp "$@"
	}

	echo "[wordpress] Waiting for MariaDB..."
	i=0
	until mysqladmin ping -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
		i=$((i + 1))
		if [ "$i" -ge 60 ]; then
			echo "[wordpress] Timed out waiting for MariaDB" >&2
			exit 1
		fi
		sleep 2
	done
	echo "[wordpress] MariaDB is up."

	if [ ! -f wp-config.php ]; then
		echo "[wordpress] Downloading WordPress..."
		# Clear partial downloads from a previous failed attempt
		find . -mindepth 1 -maxdepth 1 -exec rm -rf {} +

		wp core download --allow-root

		wp config create \
			--dbname="${MYSQL_DATABASE}" \
			--dbuser="${MYSQL_USER}" \
			--dbpass="${DB_PASSWORD}" \
			--dbhost="${MYSQL_HOST}" \
			--allow-root

		wp core install \
			--url="https://${DOMAIN_NAME}" \
			--title="${WP_TITLE}" \
			--admin_user="${WP_ADMIN_USER}" \
			--admin_password="${WP_ADMIN_PASSWORD}" \
			--admin_email="${WP_ADMIN_EMAIL}" \
			--skip-email \
			--allow-root

		wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
			--user_pass="${WP_USER_PASSWORD}" \
			--role=author \
			--allow-root

		wp config set WP_REDIS_HOST redis --allow-root
		wp config set WP_REDIS_PORT 6379 --raw --allow-root
		wp plugin install redis-cache --activate --allow-root || true
		wp redis enable --allow-root || true

		chown -R www:www /var/www/html
		echo "[wordpress] Installation complete."
	else
		echo "[wordpress] Already installed."
	fi
fi

exec "$@"
