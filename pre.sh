#!/bin/bash

# setup permissions
# setup promgrafana dashboards\sources

INSTALLPATH=/opt/noc-dc

function SETPERMISSION {
    echo "1"
    chmod 777 -R $INSTALLPATH/data/clickhouse/data
    chmod 777 -R $INSTALLPATH/data/grafana/plugins
    chmod 777 -R $INSTALLPATH/data/prometheus/metrics
    chmod 777 -R $INSTALLPATH/data/promgrafana/plugins
    chmod 777 -R $INSTALLPATH/data/promgrafana/db
}

function SETUPPROMGRAFANA {
    echo "2"
}

if [ -n "$1" ]
    then
        if [ "$1" = "all" ]
            then
                SETPERMISSION
                SETUPPROMGRAFANA
        elif [ "$1" = "perm" ]
            then
                SETPERMISSION
        elif [ "$1" = "grafana" ]
            then
                SETUPPROMGRAFANA
        else
            echo "Unknown parameter.  Use: all, perm, grafana"
        fi
else
    echo "No  parameters found. Use: all, perm, grafana" 
fi
