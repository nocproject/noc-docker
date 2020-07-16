Develop
----
If you need FULL develop environment    

```shell script
./pre.sh -p all -c dev
```
Code from https://code.getnoc.com/noc/noc.git copy to
`./data/noc/code` and connected to '/opt/noc' in container.

See '.env' file for volume mount path:
```shell script
# NOC_CODE_PATH '/home' for PROD or '/opt/noc' for DEV
NOC_CODE_PATH=/home
```  
For full develop environment:
```shell script
# NOC_CODE_PATH '/home' for PROD or '/opt/noc' for DEV
NOC_CODE_PATH=/opt/noc
```  
Generate 'cythonize' file
----
After `./pre.sh -p all -c dev` run:
```shell script
docker-compose up noc-code-cythonize
``` 

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
Use ./data/noc/custom if need make custom:
* adapter for new hardware. See doc  
  https://kb.nocproject.org/pages/viewpage.action?pageId=22971074
* handler
* commands
* etc

FAQ
----
Q: I want to use default MongoDB cache. What i need do?

A: You need edit './data/noc/etc/noc.conf'
   ```comment string
   # NOC_CACHE_CACHE_CLASS=noc.core.cache.redis.RedisCache 
   ```

Q: I want fix script `/opt/noc/sa/profiles/MikroTik/RouterOS/get_version.py`.
 
A: Use `./data/noc/custom` directory. This directory is used for priority 
   file load for activator service. Create directory and `__init__.py` files
   ```shell script
   cd ./data/noc/custom
   mkdir -p ./sa/profiles/MikroTik/RouterOS/
   touch __init__.py
   touch ./sa/__init__.py
   touch ./sa/profiles/__init__.py
   touch ./sa/profiles/MikroTik/__init__.py
   touch ./sa/profiles/MikroTik/RouterOS/__init__.py
   ```
   Put you version `get_version.py` and restart `activator-default` container
   ```shell script
   docker-compose restart activator-default
   ```
Q: I need access to code that not worked in `custom` 

A: Run:
   ```shell script
   ./pre.sh -p all -c dev
   ```
   It download noc code in `./data/noc/code` 
   Edit `.env` file 
   ```shell script
   # NOC_CODE_PATH '/home' for PROD or '/opt/noc' for DEV
   NOC_CODE_PATH=/opt/noc
   ```
   and restart noc-dc
   ```shell script
   docker-compose down
   docker-compose up -d
   ```
   Code from `./data/noc/code` mount in `/opt/noc/` into all docker container.
   Edit and restart container.

Q: I want add new HW support in NOC

A: 
   * add new vendor
   * add new object_profile
   * add new dir in sa/profiles
   * read https://kb.nocproject.org/pages/viewpage.action?pageId=22971074
   * use 'Q: I want fix script'

Thats it. Be aware of if you need to add new script it has to be added
to several services. Also you need discovery, sae and web.
