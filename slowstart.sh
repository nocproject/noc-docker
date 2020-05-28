#!/bin/sh

docker-compose up -d mongodb-repl-set-init
docker-compose up -d mongo
docker-compose up -d postgres
docker-compose up -d consul
docker-compose up -d nginx
docker-compose up -d mongo
docker-compose up -d mongo
docker-compose up -d mongo
docker-compose up -d mongo
docker-compose up -d mongo
docker-compose up -d mongo
docker-compose up -d
