FROM alpine:3.23

RUN apk add --no-cache nginx \
	&& mkdir -p /var/www/static /run/nginx \
	&& rm -f /etc/nginx/http.d/default.conf

COPY conf/nginx.conf /etc/nginx/http.d/static.conf
COPY www/ /var/www/static/
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
