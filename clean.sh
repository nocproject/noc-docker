#!/bin/sh

# Clean custom files genetated ./pre.sh

CLEANENV() {
  echo "clean .env file"
  echo "---"
  rm -f "$INSTALLPATH"/.env
  rm -f "$INSTALLPATH"/.env.proxy
  rm -f "$INSTALLPATH"/.env.infra
}

CLEANSENTRY() {
  echo "clean sentry.env file"
  echo "---"
  rm -f "$INSTALLPATH"/data/sentry/sentry.env
}

CLEANNOC() {
  echo "clean noc.conf file"
  echo "---"
  rm -f "$INSTALLPATH"/data/noc/noc.conf
}

CLEANDB() {
  echo "Remove DB files"
  echo "---"
  echo "You must delete the files yourself!!!"
  echo "Stop container NOC-DC and do:"
  echo "rm -rf $INSTALLPATH/data/mongo/*"
  echo "rm -rf $INSTALLPATH/data/postgres/*"
  sleep 10
}

CLEANGRAFANA() {
    echo "Remove Grafana provision"
    echo "----"
    rm -rf "$INSTALLPATH"/data/promgrafana/etc/dashboards
    rm -rf "$INSTALLPATH"/data/promgrafana/etc/provisioning
}

while [ -n "$1" ]
do
    case "$1" in
        -p) PARAM_P="$2"
            #echo "Found the -t option, with parameter value $PARAM_TAG"
            shift ;;
        -d) INSTALLPATH="$2"
            shift ;;
        -h) echo "Example: ./pre.sh -p <all|env|noc|sentry|grafana|db>"
            break
            shift ;;
        --) shift
            break ;;
        *) echo "Example: ./pre.sh -p <all|env|noc|sentry|grafana|db>";;
    esac
    shift
done

if [ -z "$INSTALLPATH" ]
    then
        INSTALLPATH=$PWD
        echo "Use NOC-DC installpath: $INSTALLPATH"
        echo "---"
fi

if [ -n "$PARAM_P" ]
    then
        if [ "$PARAM_P" = "all" ]
            then
                CLEANENV
                CLEANSENTRY
                CLEANNOC
                CLEANGRAFANA
                CLEANDB
        elif [ "$PARAM_P" = "sentry" ]
            then
                CLEANSENTRY
        elif [ "$PARAM_P" = "grafana" ]
            then
                CLEANGRAFANA
        elif [ "$PARAM_P" = "env" ]
            then
                CLEANENV
        elif [ "$PARAM_P" = "noc" ]
            then
                CLEANNOC
        elif [ "$PARAM_P" = "db" ]
            then
                CLEANDB
        else
            echo "Unknown parameter for -p"
            echo "Use one of: all,env,noc,sentry,db"
        fi
else
    echo "No -p parameters found."
    echo "Use one of: all,env,noc,sentry,db"
fi
