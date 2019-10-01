#!/bin/bash

# Script restore persistent ./data  and docker images for noc
# Stop NOC before start restore


INSTALLPATH=/opt/noc-dc


function RESTOREDATA {
    # restore ./data
    if ! [ -f "$INSTALLPATH"/backup/data.tar.gz ]
    then
        echo "Restore file: $INSTALLPATH/backup/data.tar.gz not found"
        echo "Rename data-YYYYMMDD-HH-MM.tar.gz to data.tar.gz"
        exit
    fi
    tar -xvpzf $INSTALLPATH/backup/data.tar.gz -C "$INSTALLPATH"/data
}

function RESTOREIMAGES {
    # restore docker image
    
    FILES=$(find "$INSTALLPATH""/backup" -name "image-*.tar.gz" -type f -printf "%f\t" )
    for f in ${FILES};
    do
	# load docker image from path
	docker load < $INSTALLPATH"/backup/""$f"
    done

}

if [ -n "$1" ]
   then
      if [ "$1" = "all" ]
         then
             RESTOREDATA
             RESTOREIMAGES
      elif [ "$1" = "data" ]
         then
             RESTOREDATA
      elif [ "$1" = "images" ]
         then
             RESTOREIMAGES
      else
         echo "Unknown parameter.  Use: all, data, images"
      fi
else
   echo "No restore parameters found. Use: all, data, images"
fi
