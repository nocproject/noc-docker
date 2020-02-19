#!/bin/sh

# setup permissions
# setup promgrafana dashboards\sources

TMPPATH=$(mktemp -d -p /tmp)
TMPPATH1=$(mktemp -d -p /tmp)

CREATEDIR() {
    mkdir -p "$INSTALLPATH"/data/promgrafana/etc/provisioning/datasources
    mkdir -p "$INSTALLPATH"/data/promgrafana/etc/provisioning/notifiers
    mkdir -p "$INSTALLPATH"/data/promgrafana/etc/provisioning/dashboards
    mkdir -p "$INSTALLPATH"/data/promgrafana/etc/dashboards
    mkdir -p "$INSTALLPATH"/data/promgrafana/plugins
    mkdir -p "$INSTALLPATH"/data/promgrafana/db
    mkdir -p "$INSTALLPATH"/data/promvm
    mkdir -p "$INSTALLPATH"/data/prometheus/metrics
    mkdir -p "$INSTALLPATH"/data/prometheus/etc/rules.d
    mkdir -p "$INSTALLPATH"/data/consul
    mkdir -p "$INSTALLPATH"/data/clickhouse/data
    mkdir -p "$INSTALLPATH"/data/nsq
    mkdir -p "$INSTALLPATH"/data/mongo
    mkdir -p "$INSTALLPATH"/data/noc/custom
    mkdir -p "$INSTALLPATH"/data/postgres
    mkdir -p "$INSTALLPATH"/data/nginx/ssl
    mkdir -p "$INSTALLPATH"/data/grafana/plugins
    mkdir -p "$INSTALLPATH"/data/sentry/redis
    mkdir -p "$INSTALLPATH"/data/sentry/pg
}

SETPERMISSION() {
    chown 101 -R "$INSTALLPATH"/data/clickhouse/data
    chown 999 -R "$INSTALLPATH"/data/postgres
    chown 999 -R "$INSTALLPATH"/data/mongo
    chown 472 -R "$INSTALLPATH"/data/grafana/
    chown 65534 -R "$INSTALLPATH"/data/prometheus/metrics
    chown 472 -R "$INSTALLPATH"/data/promgrafana/plugins
    chown 999 -R "$INSTALLPATH"/data/sentry/redis
    chown 70 -R "$INSTALLPATH"/data/sentry/pg
}

SETUPPROMGRAFANA() {
    echo "Clone GRAFANA dashboards from code.getnoc.com"
    cd "$TMPPATH" && git clone https://code.getnoc.com/noc/grafana-selfmon-dashboards.git .
    cp -f -r "$TMPPATH"/dashboards/* "$INSTALLPATH"/data/promgrafana/etc/dashboards
    cp -f -r "$TMPPATH"/provisioning/* "$INSTALLPATH"/data/promgrafana/etc/provisioning
}

SETUPPROMRULES() {
    echo "Clone PROMETHEUS alert rules from code.getnoc.com"
    cd "$TMPPATH1" && git clone https://code.getnoc.com/noc/noc-prometheus-alerts.git .
    cp -f "$TMPPATH1"/*.yml "$INSTALLPATH"/data/prometheus/etc/rules.d
}

SETUPSENTRY() {
    if [ ! -f "$INSTALLPATH"/data/sentry/sentry.env ]
        then
# @TODO
            GENERATE_PASSWORD="$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev)"

            echo "Setup Sentry env in $INSTALLPATH/data/sentry/sentry.env"
            echo "after firsh start need run command for for run migration and setup admin user\passwd"
            echo "cd $INSTALLPATH && docker-compose exec sentry sentry upgrade"
            { echo SENTRY_POSTGRES_HOST=sentry-postgres
              echo SENTRY_DB_NAME=sentry
              echo SENTRY_DB_USER=sentry
              echo SENTRY_DB_PASSWORD="$GENERATE_PASSWORD"
              echo SENTRY_SECRET_KEY="$(dd 'if=/dev/random' 'bs=1' 'count=32' 2>/dev/null | base64)"
              echo SENTRY_REDIS_HOST=sentry-redis
              echo SENTRY_METRICS_SAMPLE_RATE=0.9
              echo POSTGRES_USER=sentry
              echo POSTGRES_DBNAME=sentry
              echo POSTGRES_PASSWORD="$GENERATE_PASSWORD"
              echo "#Important!!! POSTGRES_PASSWORD == SENTRY_DB_PASSWORD"
            } >> "$INSTALLPATH"/data/sentry/sentry.env
    fi
}

SETUPNOCCONF() {
    if [ ! -f "$INSTALLPATH"/data/noc/etc/noc.conf ]
        then
            echo "Copy " "$INSTALLPATH"/data/noc/etc/noc.conf.example " to " "$INSTALLPATH"/data/noc/etc/noc.conf
            # shellcheck disable=SC2086
            cp $INSTALLPATH/data/noc/etc/noc.conf.example $INSTALLPATH/data/noc/etc/noc.conf
    fi
}

# @TODO
# need check $INSTALLPATH == $COMPOSEPATH and make warning if not
SETUPENV() {
    if [ ! -f "$INSTALLPATH"/.env ]
        then
            echo "Setup COMPOSEPATH=$INSTALLPATH in $INSTALLPATH/.env"
            echo "COMPOSEPATH=$INSTALLPATH" > "$INSTALLPATH"/.env
    fi
}

# @TODO   ./pre.sh -p all -d /opt/noc -t latest


# @TODO set tag for docker container from https://code.getnoc.com/noc/noc/container_registry
while [ -n "$1" ]
do
    case "$1" in
        -t) PARAM_T="$2"
            echo "Found the -t option, with parameter value $PARAM_T"
            shift ;;
        -p) PARAM_P="$2"
            echo "Found the -p option, with parameter value $PARAM_P"
            shift ;;
        -d) PARAM_D="$2"
            echo "Found the -d option, with parameter value $PARAM_D"
            shift ;;
        -h) echo "Example: ./pre.sh -p all -d /opt/noc -t latest"
            shift ;;
        --) shift
            break ;;
        *) echo "Example: ./pre.sh -p all -d /opt/noc -t latest";;
    esac
    shift
done

#-a Вывести все объекты.
#-c Произвести подсчёт.
#-d Указать директорию.
#-e Развернуть объект.
#-f Указать файл, из которого нужно прочитать данные.
#-h Вывести справку по команде.
#-i Игнорировать регистр символов.
#-l Выполнить полноформатный вывод данных.
#-n Использовать неинтерактивный (пакетный) режим.
#-o Позволяет указать файл, в который нужно перенаправить вывод.
#-q Выполнить скрипт в quiet-режиме.
#-r Обрабатывать папки и файлы рекурсивно.
#-s Выполнить скрипт в silent-режиме.
#-v Выполнить многословный вывод.
#- x Исключить объект.
# -y Ответить «yes» на все вопросы.
