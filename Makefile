all: start

start:
	docker-compose -d up 

stop:
	docker-compose 
build:
	docker-compose build 

