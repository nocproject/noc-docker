#!/bin/sh

# Clean custom files genetated ./pre.sh

CLEANENV() {
  echo "clean env"
  rm -f $INSTALLPATH/.env
}

CLEANSENTRY() {
  echo "clean sentry"
  rm -f $INSTALLPATH/data/sentry/sentry.env
}

CLEANNOC() {
  echo "clean noc.conf"
  rm -f $INSTALLPATH/data/noc/noc.conf
}

CLEANDB() {
  echo "Remove DB files"
}

while [ -n "$1" ]
do
    case "$1" in
        -p) PARAM_P="$2"
            #echo "Found the -t option, with parameter value $PARAM_TAG"
            shift ;;
        -d) INSTALLPATH="$2"
            shift ;;
        -h) echo "Example: ./pre.sh -p <all|env|noc|sentry>"
            break
            shift ;;
        --) shift
            break ;;
        *) echo "Example: ./pre.sh -p <all|env|noc|sentry>";;
    esac
    shift
done

if [ -z "$INSTALLPATH" ]
    then
        INSTALLPATH=$PWD
        echo "Used NOC-DC installpath: $INSTALLPATH"
        echo "---"
fi

if [ -n "$PARAM_P" ]
    then
        if [ "$PARAM_P" = "all" ]
            then
                CLEANENV
                CLEANSENTRY
                CLEANNOC
        elif [ "$PARAM_P" = "sentry" ]
            then
                CLEANSENTRY
        elif [ "$PARAM_P" = "env" ]
            then
                CLEANENV
        elif [ "$PARAM_P" = "noc" ]
            then
                CLEANNOC
        else
            echo "Unknown parameter for -p"
            echo "Use one of: all,env,noc,sentry"
        fi
else
    echo "No -p parameters found."
    echo "Use one of: all,env,noc,sentry"
fi
