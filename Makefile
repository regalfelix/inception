include srcs/.env

DATA_DIR := /home/$(LOGIN)/data
COMPOSE  := docker compose -f ./srcs/docker-compose.yml --env-file ./srcs/.env

all:
	@echo "-- building inception"
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	@$(COMPOSE) up --build

up:
	@echo "-- booting inception"
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@$(COMPOSE) up

upd:
	@echo "-- booting inception (detached)"
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@$(COMPOSE) up -d --build

stop:
	@echo "-- stopping the containers"
	@$(COMPOSE) down

ps:
	@$(COMPOSE) ps

logs:
	@$(COMPOSE) logs -f

clean:
	@echo "-- removing all docker containers and volumes"
	@$(COMPOSE) down -v 2>/dev/null || true
	@docker rm -vf $$(docker ps -aq) 2>/dev/null || true
	@echo "-- removing all built docker images"
	@docker rmi -f $$(docker images -aq) 2>/dev/null || true
	@echo "-- deleting the unused networks"
	@docker network prune -f

fclean: clean
	@echo "-- deleting local files"
	@sudo rm -rf $(DATA_DIR)
	@echo "-- running docker prune"
	@docker system prune -af
	@echo "-- done!"

re: clean all

fre: fclean all

.PHONY: all up upd stop ps logs clean fclean re fre
