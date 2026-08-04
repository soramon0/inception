FROM alpine:3.23

RUN apk add --no-cache vsftpd \
	&& mkdir -p /var/www/html /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 21 21000-21010

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
