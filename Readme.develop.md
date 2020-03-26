Develop
----
If you need FULL develop environment    

```shell script
./pre.sh -p all -c dev
```
Code from https://code.getnoc.com/noc/noc.git copy to
`./data/noc/code` and connected to '/opt/noc' in container.

Database restore
----
If you need restore database - put file in directory
```shell script
./data/mongorestore
./data/postgresrestore
```
and run
```shell script
docker-compose -f docker-compose-dev.yml up
```



Custom
----
Use ./data/noc/custom if need make:
* adapter for new hardware. See doc  
  https://kb.nocproject.org/pages/viewpage.action?pageId=22971074
* handler
* commands
* etc
