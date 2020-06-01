#!/bin/bash

# The script starts the containers sequentially.
# Recommended for use on slow HDDs and laptops.

declare -a arr

arr=(mongodb-repl-set-init
    mongo
    postgres
    consul
    nginx_openssl
    traefik
    redis
    nginx
    nsqd
    nsqlookupd
    clickhouse
    grafana
    migrate
    tgsender
    selfmon
    mailsender
    grafanads
    datasource
    datastream
    chwriter
    web
    login
    card
    nbi
    discovery-default
    activator-default
    correlator-default
    classifier-default
    escalator
    sae
    mrt
    mib
    ping-default
    scheduler
    syslogcollector-default
    trapcollector-default
    bi
)

for item in ${arr[*]}
do
    docker-compose up -d "$item"
done

