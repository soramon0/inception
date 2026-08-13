FROM alpine:3.23

RUN apk add --no-cache redis

COPY conf/redis.conf /etc/redis.conf

EXPOSE 6379

ENTRYPOINT ["redis-server"]
CMD ["/etc/redis.conf"]
