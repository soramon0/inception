FROM alpine:3.23

RUN apk add --no-cache \
	php83 \
	php83-session \
	php83-mysqli \
	php83-pdo \
	php83-pdo_mysql \
	curl \
	&& ln -sf /usr/bin/php83 /usr/bin/php \
	&& mkdir -p /var/www/adminer

RUN curl -fsSL https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
	-o /var/www/adminer/index.php

WORKDIR /var/www/adminer

EXPOSE 8080

ENTRYPOINT ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]
