#!/bin/sh

TMPPATH=$(mktemp -d -p /tmp)
TMPPATH1=$(mktemp -d -p /tmp)
TMPPATH2=$(mktemp -d -p /tmp)

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
    mkdir -p "$INSTALLPATH"/data/mongorestore
    mkdir -p "$INSTALLPATH"/data/postgresrestore
    mkdir -p "$INSTALLPATH"/data/noc/custom
    mkdir -p "$INSTALLPATH"/data/noc/etc
    mkdir -p "$INSTALLPATH"/data/noc/code
    mkdir -p "$INSTALLPATH"/data/noc/beef
    mkdir -p "$INSTALLPATH"/data/postgres
    mkdir -p "$INSTALLPATH"/data/nginx/ssl
    mkdir -p "$INSTALLPATH"/data/grafana/plugins
    mkdir -p "$INSTALLPATH"/data/sentry/redis
    mkdir -p "$INSTALLPATH"/data/sentry/pg
}

SETPERMISSION() {
    chown 101   -R "$INSTALLPATH"/data/clickhouse/data
    chown 999   -R "$INSTALLPATH"/data/postgres
    chown 999   -R "$INSTALLPATH"/data/mongo
    chown 472   -R "$INSTALLPATH"/data/grafana
    chown 65534 -R "$INSTALLPATH"/data/prometheus/metrics
    chown 472   -R "$INSTALLPATH"/data/promgrafana
    chown 999   -R "$INSTALLPATH"/data/sentry/redis
    chown 70    -R "$INSTALLPATH"/data/sentry/pg
}

SETUPPROMGRAFANA() {
    echo "GRAFANA dashboards download from code.getnoc.com/noc/grafana-selfmon-dashboards"
    echo "---"
    cd "$TMPPATH" && git clone -q https://code.getnoc.com/noc/grafana-selfmon-dashboards.git .
    cp -f -r "$TMPPATH"/dashboards/* "$INSTALLPATH"/data/promgrafana/etc/dashboards
    cp -f -r "$TMPPATH"/provisioning/* "$INSTALLPATH"/data/promgrafana/etc/provisioning
}

SETUPPROMRULES() {
    echo "PROMETHEUS alert rules download from code.getnoc.com/noc/noc-prometheus-alerts.git"
    echo "---"
    cd "$TMPPATH1" && git clone -q https://code.getnoc.com/noc/noc-prometheus-alerts.git .
    cp -f "$TMPPATH1"/*.yml "$INSTALLPATH"/data/prometheus/etc/rules.d
}

SETUPSENTRY() {
    if [ ! -f "$INSTALLPATH"/data/sentry/sentry.env ]
        then
# @TODO
            GENERATE_PASSWORD="$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev)"

            echo "Sentry env write in $INSTALLPATH/data/sentry/sentry.env"
            echo "after first start container need run command to make migration by setting up admin user passwd"
            echo "cd $INSTALLPATH && docker-compose -f docker-compose-infra.yml exec sentry sentry upgrade"
            echo "---"
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

# @TODO
# need check $INSTALLPATH == $COMPOSEPATH and make warning if not
SETUPENV() {
    GENERATED_PG_PASSWORD="$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev)"
    # TODO
    # need fix created mongo container with NOC_MONGO_PASSWORD instean "noc"
    # GENERATED_MONGO_PASSWORD="$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev)"
    GENERATED_MONGO_PASSWORD=noc

    if [ ! -f "$INSTALLPATH"/.env ]
        then
            echo "Writed COMPOSEPATH=$INSTALLPATH in $INSTALLPATH/.env"
            echo "You can change the parameters OC_PG_PASSWORD\NOC_MONGO_PASSWORD if you want"
            echo "---"
            { echo "COMPOSEPATH=$INSTALLPATH"
              echo "COMPOSE_HTTP_TIMEOUT=300"
              echo "# logging driver: json-file, local, journald"
              echo "COMPOSE_LOG_DRIVER=json-file"
              echo "COMPOSE_LOG_MAX_SIZE=10m"
              echo "COMPOSE_LOG_MAX_FILE=1"
              echo "### NOC env ###"
              echo "NOC_VERSION_TAG=$PARAM_TAG"
              echo "# NOC_CODE_PATH '/home' for PROD or '/opt/noc' for DEV"
              echo "NOC_CODE_PATH=$NOC_CODE_PATH"
              echo "# Important!!! NOC_PG_PASSWORD must by similar in .data/noc/etc/noc.conf file"
              echo "NOC_PG_PASSWORD=$GENERATED_PG_PASSWORD"
              echo "PGPASSWORD=$GENERATED_PG_PASSWORD"
              echo "# Important!!! NOC_MONGO_PASSWORD must by similar in .data/noc/etc/noc.conf file"
              echo "NOC_MONGO_PASSWORD=$GENERATED_MONGO_PASSWORD"
            } >> "$INSTALLPATH"/.env
    fi

    # make noc.conf
   if [ ! -f "$INSTALLPATH"/data/noc/etc/noc.conf ]
      then
          echo "Write $INSTALLPATH/data/noc/etc/noc.conf"
          echo "You can change the parameters NOC_PG_PASSWORD\NOC_MONGO_PASSWORD if you want"
          echo "---"
          { echo "NOC_CONFIG=env:///NOC"
            echo "NOC_MONGO_ADDRESSES=mongo:27017"
            echo "NOC_PG_ADDRESSES=postgres:5432"
            echo "NOC_CLICKHOUSE_RW_ADDRESSES=clickhouse:8123"
            echo "NOC_CLICKHOUSE_RO_ADDRESSES=clickhouse:8123"
            echo "NOC_CUSTOMIZATION_CUSTOM_PATH=/opt/noc_custom"
            echo "NOC_FEATURES_CONSUL_HEALTHCHECKS=true"
            echo "NOC_FEATURES_SERVICE_REGISTRATION=true"
            echo "NOC_INSTALLATION_NAME=NOC-DC"
            echo "NOC_PG_DB=noc"
            echo "# Important!!! NOC_PG_PASSWORD must by similar in .env file"
            echo "NOC_PG_PASSWORD=$GENERATED_PG_PASSWORD"
            echo "NOC_PG_USER=noc"
            echo "NOC_POOL=default"
            echo "NOC_MONGO_USER=noc"
            echo "# Important!!! NOC_MONGO_PASSWORD must by similar in .env file"
            echo "NOC_MONGO_PASSWORD=$GENERATED_MONGO_PASSWORD"
            echo "NOC_NSQD_ADDRESSES=nsqd:4150"
            echo "NOC_NSQD_HTTP_ADDRESSES=nsqd:4151"
            echo "NOC_NSQLOOKUPD_ADDRESSES=nsqlookupd:4160"
            echo "NOC_NSQLOOKUPD_HTTP_ADDRESSES=nsqlookupd:4161"
            echo "NOC_SELFMON_ENABLE_FM=true"
            echo "NOC_SELFMON_ENABLE_INVENTORY=true"
            echo "NOC_SELFMON_ENABLE_TASK=true"
            echo "NOC_FEATURES_SENTRY=false"
            echo "# setup Sentry DSN (Deprecated) http://<ip<:9000/settings/sentry/projects/<NAMEPROJECT>/keys/"
            echo "# NOC_SENTRY_URL=http://6ab3d0b0702d44d0acee73298a5bb40f:43d1cb7adc1946488ac9bba1d5e0dc58@sentry:9000/2"
            echo "TZ=Europe/Moscow"
            echo "LC_LANG=en_US.UTF-8"
          } >> "$INSTALLPATH"/data/noc/etc/noc.conf
   fi
}

while [ -n "$1" ]
do
    case "$1" in
        -t) PARAM_TAG="$2"
            #echo "Found the -t option, with parameter value $PARAM_TAG"
            shift ;;
        -p) PARAM_P="$2"
            #echo "Found the -p option, with parameter value $PARAM_P"
            shift ;;
        -d) INSTALLPATH="$2"
            #echo "Found the -d option, with parameter value $INSTALLPATH"
            shift ;;
        -c) NOC_CODE_PATH="$2"
            shift ;;
        -h) echo "Example: ./pre.sh -p all -d /opt/noc-dc -t stable"
            break
            shift ;;
        --) shift
            break ;;
        *) echo "Example: ./pre.sh -p all -d /opt/noc-dc -t stable";;
    esac
    shift
done

if [ -z "$INSTALLPATH" ]
    then
        INSTALLPATH=$PWD
        echo "NOC-DC install in: $INSTALLPATH"
        echo "---"
fi

if [ -z "$PARAM_TAG" ]
    then
        PARAM_TAG="stable"
        echo "Docker use image with tag: $PARAM_TAG"
        echo "See all tags in https://code.getnoc.com/noc/noc/container_registry"
        echo "---"
fi

# Generate DEV or PROD env
if [ "$NOC_CODE_PATH" = "dev" ]
    then
        NOC_CODE_PATH=/opt/noc
        # checkout NOC code to ./data/noc/code
        echo "NOC code download from code.getnoc.com/noc/noc.git"
        echo "---"
        cd "$TMPPATH2" && git clone -q https://code.getnoc.com/noc/noc.git .
        cp -rf "$TMPPATH2"/. "$INSTALLPATH"/data/noc/code
    else
        NOC_CODE_PATH=/home
fi

if [ -n "$PARAM_P" ]
    then
        if [ "$PARAM_P" = "all" ]
            then
                CREATEDIR
                SETUPENV
                SETUPPROMGRAFANA
                SETUPPROMRULES
                SETUPSENTRY
                SETPERMISSION
        elif [ "$PARAM_P" = "perm" ]
            then
                CREATEDIR
                SETPERMISSION
        elif [ "$PARAM_P" = "grafana" ]
            then
                CREATEDIR
                SETUPPROMGRAFANA
        elif [ "$PARAM_P" = "promrules" ]
            then
                CREATEDIR
                SETUPPROMRULES
        elif [ "$PARAM_P" = "sentry" ]
            then
                SETUPSENTRY
        elif [ "$PARAM_P" = "env" ]
            then
                CREATEDIR
                SETUPENV
                SETPERMISSION
        else
            echo "Unknown parameter for -p"
            echo "Use one of: all,env,perm,grafana,promrules,sentry"
        fi
else
    echo "No -p parameters found."
    echo "Use one of: all,env,perm,grafana,promrules,sentry"
fi

