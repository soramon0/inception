#!/bin/sh
set -e

FTP_PASSWORD=""
while IFS='=' read -r key value; do
	case "$key" in
		\#*|"") continue ;;
	esac
	case "$key" in
		FTP_PASSWORD) FTP_PASSWORD="$value" ;;
	esac
done < /run/secrets/credentials

if ! id -u "${FTP_USER}" >/dev/null 2>&1; then
	adduser -D -h /var/www/html -s /sbin/nologin "${FTP_USER}"
fi
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
echo "${FTP_USER}" > /etc/vsftpd.userlist
chown -R "${FTP_USER}:${FTP_USER}" /var/www/html

exec "$@"
