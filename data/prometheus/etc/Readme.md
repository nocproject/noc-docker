1. Install end configure Telegraf on localhost



See https://github.com/influxdata/telegraf

2. Enable export Docker daemon metrics to Prometheus

Edit */etc/docker/daemon.json*
```
{
  "metrics-addr" : "127.0.0.1:9323",
  "experimental" : true
}
```
end reload Docker service

See https://docs.docker.com/config/thirdparty/prometheus/
