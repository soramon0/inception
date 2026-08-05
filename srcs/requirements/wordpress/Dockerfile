FROM alpine:3.23

RUN apk add --no-cache \
	php83 \
	php83-fpm \
	php83-mysqli \
	php83-json \
	php83-curl \
	php83-dom \
	php83-exif \
	php83-fileinfo \
	php83-mbstring \
	php83-openssl \
	php83-xml \
	php83-zip \
	php83-phar \
	php83-session \
	php83-iconv \
	php83-tokenizer \
	php83-ctype \
	php83-redis \
	curl \
	mariadb-client \
	&& ln -sf /usr/bin/php83 /usr/bin/php

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	-o /usr/local/bin/wp \
	&& chmod +x /usr/local/bin/wp

WORKDIR /var/www/html

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh \
	&& chown -R nobody:nobody /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
