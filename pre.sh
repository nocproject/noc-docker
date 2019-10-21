#!/bin/bash

# setup permissions
# setup promgrafana dashboards\sources

INSTALLPATH=/opt/noc-dc
TMPPATH=/tmp/$(date +%s)

function CREATEDIR {
    mkdir -p $INSTALLPATH/data/promgrafana/etc/provisioning/datasources
    mkdir -p $INSTALLPATH/data/promgrafana/etc/provisioning/notifiers
    mkdir -p $INSTALLPATH/data/promgrafana/etc/provisioning/dashboards
    mkdir -p $INSTALLPATH/data/promgrafana/etc/dashboards
    mkdir -p $INSTALLPATH/data/promgrafana/plugins
    mkdir -p $INSTALLPATH/data/promgrafana/db
    mkdir -p $INSTALLPATH/data/promvm
    mkdir -p $INSTALLPATH/data/prometheus/metrics
    mkdir -p $INSTALLPATH/data/consul
    mkdir -p $INSTALLPATH/data/clickhouse/data
    mkdir -p $INSTALLPATH/data/nsq
    mkdir -p $INSTALLPATH/data/mongo
    mkdir -p $INSTALLPATH/data/postgres
    mkdir -p $INSTALLPATH/data/nginx/ssl
    mkdir -p $INSTALLPATH/data/grafana/plugins
    mkdir -p $INSTALLPATH/data/sentry/redis
    mkdir -p $INSTALLPATH/data/sentry/pg
}

function SETPERMISSION {
    chown 101 -R $INSTALLPATH/data/clickhouse/data
    chown 999 -R $INSTALLPATH/data/postgres
    chown 999 -R $INSTALLPATH/data/mongo
    chown 472 -R $INSTALLPATH/data/grafana/
    chown 65534 -R $INSTALLPATH/data/prometheus/metrics
    chown 472 -R $INSTALLPATH/data/promgrafana/plugins
    chmod 777 -R $INSTALLPATH/data/sentry/redis
}

function SETUPPROMGRAFANA {
    git clone https://code.getnoc.com/e_zombie/grafana-dashboard-import.git "$TMPPATH"
    cp -f -r "$TMPPATH"/dashboards/* "$INSTALLPATH"/data/promgrafana/etc/dashboards
    cp -f -r "$TMPPATH"/provisioning/* "$INSTALLPATH"/data/promgrafana/etc/provisioning
}

if [ -n "$1" ]
    then
        if [ "$1" = "all" ]
            then
		CREATEDIR
                SETPERMISSION
                SETUPPROMGRAFANA
        elif [ "$1" = "perm" ]
            then
		CREATEDIR
                SETPERMISSION
        elif [ "$1" = "grafana" ]
            then
		CREATEDIR
                SETUPPROMGRAFANA
        else
            echo "Unknown parameter.  Use: all, perm, grafana"
        fi
else
    echo "No  parameters found. Use: all, perm, grafana" 
fi
