Readme
----
You need setup IP or DomainName in URL  

```shell script
    url: https://<node_IP_or_DomainName>/api/grafanads
```
After change you need restart `grafana` container
```shell script
docker-compose restart grafana
``` 

Example
---
```shell script
    url: https://192.168.0.1/api/grafanads
```
```shell script
    url: https://example.com/api/grafanads
```
