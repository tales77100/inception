FILE_NAME=./srcs/docker-compose.yml

all:
	docker-compose -f $(FILE_NAME) up

clean:
	docker-compose -f $(FILE_NAME) stop
	docker-compose -f $(FILE_NAME) down -v

fclean: clean
	docker system prune -af
	docker volume prune -f

re: clean fclean all
