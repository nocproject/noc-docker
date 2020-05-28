#!/bin/sh

# The script starts the containers sequentially.
# Recommended for use on slow HDDs and laptops.

docker-compose up -d mongodb-repl-set-init
docker-compose up -d mongo
docker-compose up -d postgres
docker-compose up -d consul
docker-compose up -d nginx_openssl
docker-compose up -d traefik
docker-compose up -d redis
docker-compose up -d nginx
docker-compose up -d nsqd
docker-compose up -d nsqlookupd
docker-compose up -d clickhouse
docker-compose up -d grafana
docker-compose up -d migrate
docker-compose up -d tgsender
docker-compose up -d selfmon
docker-compose up -d mailsender
docker-compose up -d grafanads
docker-compose up -d datasource
docker-compose up -d datastream
docker-compose up -d chwriter
docker-compose up -d web
docker-compose up -d login
docker-compose up -d card
docker-compose up -d nbi
docker-compose up -d discovery-default
docker-compose up -d activator-default
docker-compose up -d correlator-default
docker-compose up -d classifier-default
docker-compose up -d escalator
docker-compose up -d sae
docker-compose up -d mrt
docker-compose up -d mib
docker-compose up -d ping-default
docker-compose up -d scheduler
docker-compose up -d syslogcollector-default
docker-compose up -d trapcollector-default
docker-compose up -d bi
docker-compose up -d
