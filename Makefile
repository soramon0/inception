NAME			= inception
COMPOSE		= docker compose -f srcs/docker-compose.yml --env-file srcs/.env
DATA_PATH	= $(shell grep '^DATA_PATH=' srcs/.env | cut -d '=' -f2)

ifeq ($(strip $(DATA_PATH)),)
$(error DATA_PATH is empty or missing in srcs/.env)
endif

.PHONY: all up down build stop start logs ps clean fclean re data secrets-check

all: up

data:
	@mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress

secrets-check:
	@test -f secrets/db_password.txt || (echo "Missing secrets/db_password.txt" && exit 1)
	@test -f secrets/db_root_password.txt || (echo "Missing secrets/db_root_password.txt" && exit 1)
	@test -f secrets/credentials.txt || (echo "Missing secrets/credentials.txt" && exit 1)

up: data secrets-check
	$(COMPOSE) up -d --build

build: data secrets-check
	$(COMPOSE) build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean:
	$(COMPOSE) down -v --rmi all --remove-orphans

fclean: clean
	@docker run --rm -v $(DATA_PATH):/data alpine:3.23 sh -c "rm -rf /data/mariadb /data/wordpress"

re: fclean all
