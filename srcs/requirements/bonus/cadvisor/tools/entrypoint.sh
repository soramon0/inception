#!/bin/sh
set -e
exec /usr/local/bin/cadvisor \
	--port=8080 \
	--docker_only=true \
	--housekeeping_interval=30s
