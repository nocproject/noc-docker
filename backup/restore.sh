#!/bin/bash

# Script restore persistent ./data  and docker images for noc
# Stop NOC before start restore
# -p - restore images or data
# -f - install dir
# -d - file with data archive

INSTALLPATH=/opt/noc-dc


RESTOREDATA() {
    # check NOC is not running
    FILES="$INSTALLPATH/../docker-compose.yml	$BACKUPPATH/../docker-compose-infra.yml"
    for file in ${FILES};
    do
        if docker-compose -f "$file" --project-directory=.. ps | grep Up ;
        then
    	    echo "---"
    	    echo "You need stop NOC-DC and/or NOC-DC-INFA container"
    	    echo "cd .. && docker-compose -f ""$file"" stop"
            exit
        fi
    done
    # restore ./data
    if ! [ -f "$INSTALLPATH"/backup/data.tar.gz ]
    then
        echo "Restore file: $INSTALLPATH/backup/$PARAM_D not found"
        exit
    fi
    tar -xvpzf $INSTALLPATH/backup/$PARAM_D -C "$INSTALLPATH"/data
}

RESTOREIMAGES() {
    # restore docker image
    echo "Restore NOC-DC data to: $INSTALLPATH"
    echo "---"
    FILES=$(find "$INSTALLPATH""/backup" -name "image-*.tar.gz" -type f -printf "%f\t" )
    for f in ${FILES};
    do
	# load docker image from path
	docker load < $INSTALLPATH"/backup/""$f"
    done

}

while [ -n "$1" ]
do
    case "$1" in
        -p) PARAM_P="$2"
            #echo "Found the -p option, with parameter value $PARAM_P"
            shift ;;
        -f) PARAM_F="$2"
            #echo "Found the -d option, with parameter value $BACKUPPATH"
            shift ;;
        -d) PARAM_D="$2"
            shift ;;
        -h) echo "Example: ./restore.sh -p images"
            echo "Example: ./restore.sh -p data -f /opt/noc-dc -d data-yyyymmdd-hh-mm.tar.gz"
            shift ;;
        --) shift
            break ;;
        *)  echo "Example: ./restore.sh -p data -f /opt/noc-dc -d data-yyyymmdd-hh-mm.tar.gz"
            echo "Example: ./restore.sh -p images";;
    esac
    shift
done

if [ -z "$PARAM_F" ]
    then
        INSTALLPATH=/opt/noc-dc
        echo "Restore NOC-DC to: ""$INSTALLPATH"
        echo "---"
fi

if [ -n "$PARAM_P" ]
   then
      if [ "$PARAM_P" = "all" ]
         then
             RESTOREDATA
             RESTOREIMAGES
      elif [ "$PARAM_P" = "data" ]
         then
             RESTOREDATA
      elif [ "$PARAM_P" = "images" ]
         then
             RESTOREIMAGES
      else
         echo "Unknown parameter.  Use: ./restore.sh -p images"
         echo "or: ./restore.sh -p data -f /opt/noc-dc -p data-yyyymmdd-hh-mm.tar.gz"
         echo "---"
      fi
else
   echo "No restore parameters found. Use: ./restore.sh -p images"
   echo "or: ./restore.sh -p data -f data-yyyymmdd-hh-mm.tar.gz"
   echo "---"
fi
