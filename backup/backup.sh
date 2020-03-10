#!/bin/sh

# Script backup persistent ./data  and docker images for noc
# Stop NOC before start backup. Use: docker-compose -f docker-compose.yml down
# 

BACKUPDATA() {
    # backup ./data
    FILES="$BACKUPPATH/../docker-compose.yml	$BACKUPPATH/../docker-compose-infra.yml"
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
    echo "Backup rersistent to: ""$BACKUPPATH"/data-"$(date +%Y%m%d-%H-%M)".tar.gz
    echo "---"
    tar -cvpzf "$BACKUPPATH"/backup/data-"$(date +%Y%m%d-%H-%M)".tar.gz --one-file-system -C "$BACKUPPATH"/../data/ ./
}

BACKUPIMAGES() {
    FILES="$BACKUPPATH/../docker-compose.yml	$BACKUPPATH/../docker-compose-infra.yml"
    echo "Backup docker images to: ""$BACKUPPATH"
    echo "---"
    for file in ${FILES};
    do
        IMAGES=$(grep image "$file" | grep -v COMPOSETAG | awk -e '{print $2}' | sort | uniq  )
        for image in ${IMAGES};
            do
                NAMEIMAGE=$( echo "$image" | sed 's/[:\/]/_/g' )
                docker save "$image" | gzip > "$BACKUPPATH""/image-""$NAMEIMAGE"".tar.gz"
            done
    done
    # backup all NOC images
    # todo get $COMPOSETAG from .env file or save all NOC images
    IMAGESNOC=$(docker image ls --format '{{.Repository}}-{{.Tag}}' | grep 'registry.getnoc.com/noc/noc/')
    for imagesnoc in ${IMAGESNOC}
        do
            NAMEIMAGE=$( echo "$imagesnoc" | sed 's/[:\/]/_/g' )
            docker save "$image" | gzip > "$BACKUPPATH""/image-""$NAMEIMAGE"".tar.gz"
        done
}

while [ -n "$1" ]
do
    case "$1" in
        -p) PARAM_P="$2"
            #echo "Found the -p option, with parameter value $PARAM_P"
            shift ;;
        -d) BACKUPPATH="$2"
            #echo "Found the -d option, with parameter value $BACKUPPATH"
            shift ;;
        -h) echo "Example: ./backup.sh -p all -d /opt/noc-dc"
            shift ;;
        --) shift
            break ;;
        *) echo "Example: ./backup.sh -p all -d /opt/noc-dc";;
    esac
    shift
done

if [ -z "$BACKUPPATH" ]
    then
        BACKUPPATH=$PWD
        echo "Backup NOC-DC to: $BACKUPPATH"
        echo "---"
fi

if [ -n "$PARAM_P" ]
    then
        if [ "$PARAM_P" = "all" ]
            then
                BACKUPDATA
                BACKUPIMAGES
        elif [ "$PARAM_P" = "data" ]
            then
                BACKUPDATA
        elif [ "$PARAM_P" = "images" ]
            then
                BACKUPIMAGES
        else
            echo "Unknown parameter. Use: ./backup.sh -p <all|data|images>"
        fi
else
    echo "No -p parameters found. Use: ./backup.sh -p <all|data|images>"
fi
