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

Shell
----
"./noc shell" is used to perform operations 
on making massive changes to monitoring objects or building reports.

See more: https://kb.nocproject.org/pages/viewpage.action?pageId=22971023

```shell script
docker-compose -f docker-compose-shell.yml run --rm shell

Python 2.7.15 (default, Jan 14 2020, 10:33:49) 
[GCC 6.4.0] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>>
```

Example "Remove all collected IP"
```python
from noc.ip.models.vrf import VRF
from noc.ip.models.prefix import Prefix
from noc.ip.models.address import Address
from noc.core.mongo.connection import connect
connect()
for a in Address.objects.filter():
  a.delete()
```

FAQ
----
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

Q: I need python `shell`

A: Use `docker-compose-shell.yml`
   ```shell script
   docker-compose -f docker-compose-shell.yml run --rm shell
   ``` 
Q: I want to save the results of the script in a file and then print it.

A: The directory `./data/noc/tmp` is connected to the container in
   `/tmp/tmp` and you can see the results of the script in `./data/noc/tmp`

Q: I want add new HW support in NOC

A: 
   * add new vendor
   * add new object_profile
   * add new dir in sa/profiles
   * read https://kb.nocproject.org/pages/viewpage.action?pageId=22971074
   * use 'Q: I want fix script'

Thats it. Be aware of if you need to add new script it has to be added
to several services. Also you need discovery, sae and web.
