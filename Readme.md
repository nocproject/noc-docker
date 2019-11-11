NOC Project installation via docker
==================================

Install
-------

Fork that git repo to your namespace and clone it to your favorite location
```
git clone https://code.getnoc.com/noc/noc-dc.git /opt/noc-dc

cd /opt/noc-dc
```
Check *$INSTALLPATH* and run *pre.sh* script for make dirs\permissions\config
```
pre.sh
```
Check *data/noc/etc/noc.conf* and edit config if needed

Preparing to launch containers:
```
export DOCKER_CLIENT_TIMEOUT=120
export COMPOSE_HTTP_TIMEOUT=120
docker-compose up --no-start
```

Run initial db init and migrations
```
docker-compose up migrate
```
Wait for process to finish and than run noc itself

```
export DOCKER_CLIENT_TIMEOUT=120 COMPOSE_HTTP_TIMEOUT=120 && docker-compose up -d 
```
Be aware that command will run lots of noc daemons and intended to be pretty slow. 
On my laptops it took at about 2 minutes to get everything started

Go to https://0.0.0.0 default credentials

```
Username: admin
Password: admin
```

# Limitations

* Only single node. No way to scale noc daemons to multihost.
* Databases in docker. That is known to be not the best option
* Only single pool. No way to add equipment from different vrfs.
* need 10G+ free space on block device

FAQ:
----

Q: What it looks like default output of docker-compose ps when all works as intended 

A:

```
% docker-compose ps   
              Name                            Command                  State                                        Ports                                  
-----------------------------------------------------------------------------------------------------------------------------------------------------------
noc-dc_activator-default_1         /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_bi_1                        /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_card_1                      /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_chwriter_1                  /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_classifier-default_1        /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_clickhouse_1                /entrypoint.sh                   Up             8123/tcp, 9000/tcp, 9009/tcp                                            
noc-dc_consul_1                    consul agent -server -boot ...   Up             8300/tcp, 8301/tcp, 8301/udp, 8302/tcp, 8302/udp,                       
                                                                                   0.0.0.0:8500->8500/tcp, 8600/tcp, 8600/udp                              
noc-dc_correlator-default_1        /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_datasource_1                /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_datastream_1                /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_discovery-default_1         /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_escalator_1                 /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_grafanads_1                 /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_login_1                     /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_mailsender_1                /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_mib_1                       /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_migrate_1                   sh -c set -xe && /usr/bin/ ...   Exit 0                                                                
noc-dc_mongo_1                     docker-entrypoint.sh --wir ...   Up             27017/tcp                                                               
noc-dc_mongodb-repl-set-init_1     sh /rs-init.sh                   Exit 0                                                                                 
noc-dc_mrt_1                       /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_nbi_1                       /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_nginx_1                     nginx -g daemon off;             Up             0.0.0.0:8443->443/tcp, 80/tcp                                           
noc-dc_nginx_openssl_1             sh -c set -xe; if [ ! -f / ...   Exit 0                                                                                 
noc-dc_nsqd_1                      /nsqd --lookupd-tcp-addres ...   Up             4150/tcp, 4151/tcp, 4160/tcp, 4161/tcp, 4170/tcp, 4171/tcp              
noc-dc_nsqlookupd_1                /nsqlookupd                      Up             4150/tcp, 4151/tcp, 4160/tcp, 4161/tcp, 4170/tcp, 4171/tcp              
noc-dc_ping-default_1              /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_postgres_1                  docker-entrypoint.sh postgres    Up (healthy)   5432/tcp                                                                
noc-dc_redis_1                     docker-entrypoint.sh redis ...   Up             6379/tcp                                                                
noc-dc_sae_1                       /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_scheduler_1                 /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_selfmon_1                   /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_syslogcollector-default_1   /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_tgsender_1                  /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_traefik_1                   /traefik - traefik - --web ...   Up             0.0.0.0:1200->1200/tcp, 80/tcp, 0.0.0.0:8080->8080/tcp                  
noc-dc_trapcollector-default_1     /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                                                
noc-dc_web_1                       /usr/bin/python /opt/noc/s ...   Up             1200/tcp                                      
```

Q: Can i setup my ssl certificate?

A: Yes you can. you have to put it in data/nginx/ssl and name it noc.crt and noc.key

Q: Can i use my own databases instead of new ? 

A: Glad you asked. Of course you can. Ensure that dockerized noc is not started
```
docker-compose down
``` 
Take a backup or shutdown your current noc and copy 
```
/var/lib/postgres -> data/postgres
/var/lib/clickhouse -> data/clickhouse
/var/lib/mongo -> data/mongo
```
update passwords in `noc.conf` and start noc with 
```
docker-compose up -d 
```
Thats it. Be aware that your copy will be doing same jobs. And that can lead to a extreme server load. But here is a tric.
You can run 
```
docker-compose run migrate python commands/deactivate.py
```
It will unschedule all discovery jobs so you can run your copy without worries 

Q: Can i change files in that NOC install ?

A: Yes. Just add them as a volumes. For example you want to change script sa/profiles/MikroTik/RouterOS/get_version.py 
You have to open with text editor file `docker-compose.yaml` and find `activator-default` section it will looks like
```yaml
  activator-default:
    image: registry.getnoc.com/noc/noc/code:19.2-dev
    restart: "always"
    command: /usr/bin/python /opt/noc/services/activator/service.py
    mem_limit: 150m
    environment:
      NOC_POOL: default
    env_file:
      - noc.conf
    labels:
      traefik.enable: false
``` 
Copy existing script from container to custom/ with 
```
docker cp noc-dc_activator-default_1:/opt/noc/sa/profiles/MikroTik/RouterOS/get_version.py custom/
```
Change it with text editor and add to docker-compose file like that
```yaml
  activator-default:
    image: registry.getnoc.com/noc/noc/code:19.2-dev
    restart: "always"
    command: /usr/bin/python /opt/noc/services/activator/service.py
    mem_limit: 150m
    environment:
      NOC_POOL: default
    env_file:
      - noc.conf
    volumes:
      - $PWD/custom/get_version.py:/opt/noc/sa/profiles/MikroTik/RouterOS/get_version.py
    labels:
      traefik.enable: false
```
and restart noc with 
```
docker-compose up -d 
```
Thats it. Be aware of if you need to add new script it has to be added to several services. Also you need discovery, sae and web.

Q: How to make \ restore a backup.

A: Use *backup.sh* and *restore.sh* scripts from ./backup directory. Read ./backup/Readme.md first!


