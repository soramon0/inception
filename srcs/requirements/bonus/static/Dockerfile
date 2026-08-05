FROM alpine:3.23

RUN apk add --no-cache nginx

COPY conf/nginx.conf /etc/nginx/http.d/default.conf
COPY www/ /var/www/static/

EXPOSE 8080

ENTRYPOINT ["nginx", "-g", "daemon off;"]
