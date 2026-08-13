FROM alpine:3.23

ARG CADVISOR_VERSION=0.49.1

RUN apk add --no-cache ca-certificates curl \
	&& curl -fsSL \
		"https://github.com/google/cadvisor/releases/download/v${CADVISOR_VERSION}/cadvisor-v${CADVISOR_VERSION}-linux-amd64" \
		-o /usr/local/bin/cadvisor \
	&& chmod +x /usr/local/bin/cadvisor

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/cadvisor"]
CMD ["--port=8080", "--docker_only=true", "--housekeeping_interval=30s"]
