Readme
----
This container is used to scan the ip range and add equipment that 
is not present in the database to the list of monitoring objects.

You need copy example files first
```shell script
cp nets.conf.example nets.conf
cp excludenets.conf.example excludenets.conf
```
Then add host or networks for scan.

Run container
```shell script
docker-compose -f docker-compose-addhosts.yml run --rm networkscan-default
```

Files
----
```shell script
nets.conf               # list IP for scan
excludenets.conf        # list IP who need exlude from scan
```
