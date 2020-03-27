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
docker-compose -f docker-compose-storedb.yml up 
docker-compose up -d
```

Use database from other installation
----
Create PG dump:
```shell script
pg_dump -Fc noc > pg-`date +%Y%m%d-%H-%M`.dump
```
Put file in `.data/postgresrestore`
```shell script
ls -1 ./data/postgresrestore
pg-20200327-14-06.dump
pg-20200327-14-07.dump
pg-20200327-14-14.dump
pg-20200327-15-00.dump
pg-20200327-15-04.dump
```
**Load newest file**

Create MONGO dump:
```shell script
mongodump -d noc --archive=mongodb-`date +%Y%m%d-%H-%M`.archive
```
Put file in `.data/mongorestore`
```shell script
ls -1 ./data/mongorestore
mongodb-20200327-13-50.archive
mongodb-20200327-14-07.archive
mongodb-20200327-14-14.archive
```
**Load newest file**

Then run 
```shell script
docker-compose up -d mongodb-repl-set-init
docker-compose up -d mongo 
docker-compose up -d postgres
docker-compose -f docker-compose-restoredb.yml up 
```

Custom
----
Use ./data/noc/custom if need make:
* adapter for new hardware. See doc  
  https://kb.nocproject.org/pages/viewpage.action?pageId=22971074
* handler
* commands
* etc
