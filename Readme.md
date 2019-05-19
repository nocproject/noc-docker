NOC Project installation via docker
==================================

Install
-------

Fork that git repo to your namespace and clone it to your favorite location
```
git clone https://code.getnoc.com/noc/noc-dc.git /opt/noc-dc

cd /opt/noc-dc
```

Run initial db init and migrations
```
docker-compose up migrate
```
Wait for process to finish and than run noc itself

```
docker-compose up -d 
```
Be aware that command will run lots of noc daemons and intended to be pretty slow. On my laptops it took at about 2 minutes to get everything started

Go to https://0.0.0.0:8443 default credentials

```
Username: admin
Password: admin
```


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

A: Yes you can. you have to put it in data/nginx/ssl and call in the same way. 


