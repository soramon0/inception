FROM alpine:3.23

RUN apk add --no-cache nginx openssl \
	&& mkdir -p /etc/nginx/ssl /var/www/html /run/nginx \
	&& openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/klaayoun.key \
		-out /etc/nginx/ssl/klaayoun.crt \
		-subj "/C=MA/ST=KH/L=Khouribga/O=42/OU=42/CN=klaayoun.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
