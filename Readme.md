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

FAQ:
----

F: 

A:
