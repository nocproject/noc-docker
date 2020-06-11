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

Be aware that command will run lots of noc daemons and intended
to be pretty slow.  
On my laptops it took at about 2 minutes to get everything started

If you have IDE HDD or notebook use `slowstart.sh`. see `Readme.faq.md`
```shell script
./slowstart.sh
```

If you have SSD blockdevice: 
```
docker-compose up -d 
```

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

Read `data/vmagent/etc/Readme.md` and setup export metrics from docker host

Run compose file `docker-compose-infra.yml`
```
docker-compose -f docker-compose-infra.yml up -d
```
Open URL:
*  Grafana: http://0.0.0.0:3000
*  Sentry: https://0.0.0.0:9000

More info about monitoring noc: 
https://kb.nocproject.org/pages/viewpage.action?pageId=29982977

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
