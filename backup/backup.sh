#!/bin/bash

# Script backup persistent ./data  and docker images for noc
# Stop NOC before start backup. Use: docker-compose -f docker-compose.yml down
# 

INSTALLPATH=/opt/noc-dc

function BACKUPDATA {
    # backup ./data
    FILES="$INSTALLPATH/docker-compose.yml	$INSTALLPATH/docker-compose-infra.yml"
    for file in ${FILES};
    do
        if docker-compose -f "$file" ps | grep Up ; 
        then
    	    echo "Stop NOC-DC and/or NOC-DC-INFA container"
    	    echo "docker-compose -f ""$file"" stop"
            exit
        fi 
    
    done
    tar -cvpzf "$INSTALLPATH"/backup/data-"$(date +%Y%m%d-%H-%M)".tar.gz --one-file-system -C "$INSTALLPATH"/data/ ./
}

function BACKUPIMAGES {

FILES="$INSTALLPATH/docker-compose.yml	$INSTALLPATH/docker-compose-infra.yml"

for file in ${FILES};
do
  IMAGES=$(grep image "$file" | awk -e '{print $2}' | sort | uniq  )
    for image in ${IMAGES};
       do
           NAMEIMAGE=$( echo "$image" | sed 's/[:\/]/_/g' )
           docker save "$image" | gzip > $INSTALLPATH"/backup/image-""$NAMEIMAGE"".tar.gz"
       done
done

}

if [ -n "$1" ]
    then
        if [ "$1" = "all" ]
            then
                BACKUPDATA
                BACKUPIMAGES
        elif [ "$1" = "data" ]
            then
                BACKUPDATA
        elif [ "$1" = "images" ]
            then
                BACKUPIMAGES
        else
            echo "Unknown parameter.  Use: all, data, images"
        fi
else
    echo "No restore parameters found. Use: all, data, images" 
fi
