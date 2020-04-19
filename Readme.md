NOC Project installation via docker
==================================

# NOC Project
![logo_180px](https://cdn.getnoc.com/logo/logo_180px.png)

[![Documentation](https://img.shields.io/badge/documentation-yes-brightgreen.svg)](https://docs.getnoc.com)
[![License: BSD 3-Clause License](https://img.shields.io/badge/License-BSD-brightgreen.svg)](https://choosealicense.com/licenses/bsd-3-clause/)


> NOC project is an Operation Support System (OSS) for telecom companies, service providers, and enterprise Network Operation Centers (NOC)

### [Homepage](https://getnoc.com/)

Features
----
+ Fault Management
  + Root Cause Analysis, topology correlation, escalation.
    Active probing and passive alarm condition detection
    in syslog and SNMP traps.
+ Performance Management
  + Flexible metrics collection via SNMP and CLI. Long-term metrics storage.
     Automatic configuration of dashboards. 
     Complex threshold control with window functions.
+ Inventory
  + Centralized database of physical and logical resources.
    Tracks physical assets like chassis and modules.
    Tracks logical resources (IP, VLAN, Phone Numbers) usage as well.
    IP address planning via IPAM.
+ Discovery
  + Sophisticated multi-protocol network topology discovery. 
    Configuration and resource usage discovery.
+ Vendor-agnostic
  + Breaking the vendor locks with 80+ of supported vendors.
    Adding new vendors and platforms on daily routine basis.
+ LargeScale
  + Starting from simple single-node installation and up to clusters controlling
    world’s largest networks with 300k+ of objects.
+ Integration
  + ETL interface allows to import data from existing systems.
    DataStream API and NBI interfaces provide services to other system.
+ Big Data
  + Introduces Big Data analysis to the Network Management. 
    Builtin analytics database and provided BI tools allows to access magic

Install
-------
Disable SELINUX. See distro docs.

Fork that git repo to your namespace and clone it to your favorite location
```
git clone https://code.getnoc.com/noc/noc-dc.git /opt/noc-dc

cd /opt/noc-dc
```
Run *pre.sh* script for make dirs\permissions\config
```
./pre.sh -p all
```
If you need change default install path to other or
 other image run `pre.sh` with parameter `-d` or `-t`
```bash
./pre.sh -p all -d /opt/noc-dc -t stable
```
All tags for -t parameter:
https://code.getnoc.com/noc/noc/container_registry

Check `./data/noc/etc/noc.conf` and edit config if needed

Install *docker-compose*:

see URL: https://docs.docker.com/compose/install/

Check "docker" daemon is running

Preparing to launch containers:
```
export DOCKER_CLIENT_TIMEOUT=200
docker-compose up --no-start
```

Run initial db init and migrations
```
docker-compose up migrate
```
Wait for process to finish and than run noc itself

```
docker-compose up -d 
```
Be aware that command will run lots of noc daemons and intended
to be pretty slow.  
On my laptops it took at about 2 minutes to get everything started

Go to https://0.0.0.0 default credentials

```
Username: admin
Password: admin
```

# Limitations

* Only single node. No way to scale noc daemons to multihost.
* Databases outside container in `./data/...` . 
* Only single pool "default". No way to add equipment from different vrfs.
* need 10G+ free space on block device
* SSD block device highly recommended. Start more that 2 minutes.

Install monitoring
-------

Read `data/prometheus/etc/Readme.md` and setup export metrics from docker host

Run compose file `docker-compose-infra.yml`
```
docker-compose -f docker-compose-infra.yml up -d
```
Open URL:
*  Prometheus: http://0.0.0.0:9090
*  Grafana: http://0.0.0.0:3000
*  Sentry: https://0.0.0.0:9000

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


Contributing
----
Contributions, issues and feature requests are welcome!

Feel free to check 
[issues page](https://code.getnoc.com/noc/noc/issues/).

Feel free to check Docker specific 
[issues page](https://code.getnoc.com/noc/noc-dc/issues/).

Contact us:
----
* Telegram group:  https://t.me/nocproject
* Official site: https://getnoc.com

License
----
This project is
[BSD 3-Clause License](https://choosealicense.com/licenses/bsd-3-clause/) 
licensed.
