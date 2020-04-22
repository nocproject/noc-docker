FAQ:
----

Q: What it looks like default output of `docker-compose ps`
 when all works as intended 

A:
```
% docker ps --format "{{.Names}}: {{.Status}}\t{{.Ports}}"
noc-dc_nginx_1:                 Up 2 minutes	80/tcp, 0.0.0.0:443->443/tcp
noc-dc_traefik_1:               Up 2 minutes	0.0.0.0:1200->1200/tcp, 80/tcp,
                                    0.0.0.0:8080->8080/tcp
noc-dc_ping-default_1:          Up 2 minutes	1200/tcp
noc-dc_trapcollector-default_1: Up 2 minutes	0.0.0.0:162->162/udp, 1200/tcp
noc-dc_syslogcollector-default_1: Up 2 minutes	0.0.0.0:514->514/udp, 1200/tcp
noc-dc_web_1:                   Up 2 minutes	1200/tcp
noc-dc_card_1:                  Up 2 minutes	1200/tcp
noc-dc_nbi_1:                   Up 2 minutes	1200/tcp
noc-dc_chwriter_1:              Up 3 minutes	1200/tcp
noc-dc_escalator_1:             Up 3 minutes	1200/tcp
noc-dc_classifier-default_1:    Up 3 minutes	1200/tcp
noc-dc_selfmon_1:               Up 3 minutes	1200/tcp
noc-dc_correlator-default_1:    Up 3 minutes	1200/tcp
noc-dc_nsqd_1:                  Up 4 minutes	4150-4151/tcp, 
                                                4160-4161/tcp, 4170-4171/tcp
noc-dc_bi_1:                    Up 3 minutes	1200/tcp
noc-dc_mailsender_1:            Up 3 minutes	1200/tcp
noc-dc_tgsender_1:              Up 3 minutes	1200/tcp
noc-dc_sae_1:                   Up 3 minutes	1200/tcp
noc-dc_datastream_1:            Up 3 minutes	1200/tcp
noc-dc_datasource_1:            Up 3 minutes	1200/tcp
noc-dc_login_1:                 Up 3 minutes	1200/tcp
noc-dc_mib_1:                   Up 3 minutes	1200/tcp
noc-dc_mrt_1:                   Up 3 minutes	1200/tcp
noc-dc_scheduler_1:             Up 3 minutes	1200/tcp
noc-dc_grafanads_1:             Up 3 minutes	1200/tcp
noc-dc_discovery-default_1:     Up 3 minutes	1200/tcp
noc-dc_nsqlookupd_1:            Up 4 minutes	4150-4151/tcp, 4160-4161/tcp,
                                                4170-4171/tcp
noc-dc_clickhouse_1:            Up 4 minutes	8123/tcp, 9000/tcp, 9009/tcp
noc-dc_grafana_1:               Up 4 minutes	3000/tcp
noc-dc_activator-default_1:     Up 4 minutes	1200/tcp
noc-dc_consul_1:                Up 4 minutes	8300-8302/tcp, 8301-8302/udp,
                                                8600/tcp, 8600/udp, 
                                                0.0.0.0:8500->8500/tcp
noc-dc_mongo_1:                 Up 4 minutes	27017/tcp
noc-dc_postgres_1:              Up 4 minutes (healthy)	5432/tcp
noc-dc_redis_1:                 Up 4 minutes	6379/tcp                        
```

Q: Can i setup my ssl certificate?

A: Yes you can. you have to put it in data/nginx/ssl
   and name it `noc.crt` and `noc.key`

Q: I need add my hosts.

A: Read `data/noc/import/Readme.md` file

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
fix permission
```shell script
./pre.sh -p perm
```

update passwords in `noc.conf` and start noc with 
```
docker-compose up -d 
```
Thats it. Be aware that your copy will be doing same jobs.
And that can lead to a extreme server load. But here is a tric.
You can run 
```
docker-compose run migrate python commands/deactivate.py
```
It will unschedule all discovery jobs so you can run your copy without worries 

Q: Can i change files in that NOC install ?

A: Yes. See Readme.develop.md

Q: How to make \ restore a backup.

A: Use `backup.sh` and `restore.sh` scripts from `./backup` directory.
   Read `./backup/Readme.md` first!

Q: Sentry not work after first run. 

A: You need run 
   ```
   docker exec -ti noc-dc_sentry_1 sentry upgrade
   ```
   Setup admin user and password.

   Go to https://0.0.0.0:9000 to login in Sentry

Q: I connect to the Internet through a proxy server.
   How do I configure the installation of all system components.

A: You need to set the environment variable 
   HTTPS_PROXY (necessarily in UPPER CASE) 
   and the script `./pre.sh` uses this variable to configure containers.
   You can check the current settings by running the command
   ```shell script
   env | grep -i proxy
    HTTPS_PROXY=http://<proxyIP>:<proxyPORT>
   ```
   If your proxy server address has changed - edit the file `.env.proxy`
   
Q: I want use RU language in interface

A: Edit `./data/noc/ent/noc.conf`
   ```
   NOC_LANGUAGE=ru
   NOC_LANGUAGE_CODE=ru
   ```