NOC Project docker install backup\restore scripts
=================================================

Description
-------

The *backup.sh* script is used to create a backup copy. 
To restore from a backup, use the *restore.sh* script.

The backup consists of two parts: 
* images of docker containers - image-<name data image>.tar.gz
* archive file with settings and database files - data-<data and time create backup>.tar.gz

Backup.sh
-------

What Backup.sh does:
* takes list of docker images from docker-compouse.yml and docker-compouse-infra.yml
* then script creates tar.gz files using the "docker save" command
* after that script creates data-<data and time create backup>.tar.gz file in ./data/ directory

1. Check that the NOC-DC service is not working

2. If not, install exec-bit on script: 
```
chmod +x backup.sh
```
3. Run backup.sh script
   
   If you need backup data and images
```
# ./backup.sh all
```

   If you need backup only data
```
# ./backup.sh data
```

   If you need backup only images
```
# ./backup.sh images
```
4. Check result
```
# ls -1
image-alpine_latest.tar.gz
...
image-registry.getnoc.com_noc_noc_static_19.3.1.tar.gz
data-20191001-21-03.tar.gz
```

Restore.sh
-------

What Restore.sh does:
* script restores docker images  using the "docker load" command
* then script restores ./data/ directory from  *data.tar.gz* file


1. Check that the NOC-DC service is not working

2. If not, install exec-bit on script: 
```
chmod +x restore.sh
```
3. Run restore.sh script

Rename data-YYYMMDD-HH-MM.tar.gz to data.tar.gz first!!!

If you need restore data and images use
```
# ./restore.sh all
```
If you need restore only data use
```
# ./restore.sh data
```
If you need restore only images use
```
# ./restore.sh images
```
0. Start NOC-DC


Attention
-------
If you restores a backup on a server with a different IP address from where the backup was made,
then if you wants the Grafana server to work correctly, you'll need to change the url parameter
in *./data/grafana/dashboards/noc.js* file for new IP or DNS address

```
url: "https://<IP>:8443/pm/ddash/?" + $.param(args)
```

