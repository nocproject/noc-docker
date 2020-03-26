Develop
----
If you need FULL develop environment    

```shell script
./pre.sh -p all -c dev
```
Code from https://code.getnoc.com/noc/noc.git copy to
`./data/noc/code` and connected to '/opt/noc' in container.


Restore database from dump
----
If you need restore database - put file in directory
```shell script
./data/mongorestore
./data/postgresrestore
```
and run
```shell script
docker-compose up -d mongodb-repl-set-init
docker-compose up -d mongo 
docker-compose up -d postgres
docker-compose -f docker-compose-restoredb.yml up 
docker-compose up -d
```

Create database dump
----

```shell script
docker-compose up -d mongo 
docker-compose up -d postgres
docker-compose -f docker-compose-dumpdb.yml up 
docker-compose up -d
```

Custom
----
Use ./data/noc/custom if need make:
* adapter for new hardware. See doc  
  https://kb.nocproject.org/pages/viewpage.action?pageId=22971074
* handler
* commands
* etc
