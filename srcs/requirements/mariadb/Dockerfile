FROM alpine:3.23

RUN apk update && apk add --no-cache \
	mariadb \
	mariadb-client \
	mariadb-server-utils \
	&& rm -rf /var/cache/apk/*

RUN mkdir -p /run/mysqld /var/lib/mysql \
	&& chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/zz-inception.cnf /etc/my.cnf.d/zz-inception.cnf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
