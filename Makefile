NAME		= inception
COMPOSE		= docker compose -f srcs/docker-compose.yml --env-file srcs/.env
# change username later to klaayoun
DATA_PATH	= /home/sora/data

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

clean: down
	$(COMPOSE) down -v --remove-orphans

fclean: clean
	@docker system prune -af --volumes 2>/dev/null || true
	@rm -rf $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress

re: fclean all
