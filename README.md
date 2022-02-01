# acra-telemetry-collector
Acra Telemetry collector was created to get a convenient and simple tool for tracking Acra Server operation.

# Using 

## Install
```
git clone git@github.com:radetsky/acra-telemetry-collector.git
```

## Life cycle of the project 
```
make docker-build
make docker-run
make docker-top
make docker-stop
make docker-clean
```

## Setup Acra Server logging options 

We assume that your Acra Server runs as docker container or docker-compose service. 
Please install loki logging driver for your docker
```
docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
```

Please add next options to your docker-compose file (to Acra docker container and optionally to other containers use use) or docker run options. 

Replace ${loki-container-address-port} with address of your server where you run acra-telemetry-collector 

```
logging:
    driver: loki
    options:
        loki-url: "http://${loki-container-address-port}/loki/api/v1/push"
        loki-batch-size: "400"
        loki-retries: "5"
 ```       
or run docker with these options:
```
docker run --log-driver=loki \
    --log-opt loki-url="http://${loki-container-address-port}/loki/api/v1/push" \
    --log-opt loki-retries=5 \
    --log-opt loki-batch-size=400 \
    ${your-acra-server}
```
where:
  - `loki-container-address-port` in format `{IP|hostname}[:port]`
  - `your-acra-server` - image name and configuration of Acra server you plan to launch

These changes will help you start sending logs to the specified server.

## Setup Acra server tracing options 
If you want to find any Acra Server traces you should export RUN_JAEGER environment variable and setup options to export traces to Jaeger.

We assume that your Acra Server runs as docker container or docker-compose service. 
You can add next option to your acra server parameters:
```
--jaeger_collector_endpoint=http://{jaeger-container-address-port}/api/traces
```
where:
  - `jaeger-container-address-port` in format `{IP|hostname}[:port]`




## Setup and run metrics collection 

Find --incoming_connection_prometheus_metrics_string parameter in options to check where exactly your Acra Server metrics is available. 

Use PROMETHEUS_TARGETS environment variable to declare where your Acra Server exposes metrics when you run project. 
```
make PROMETHEUS_TARGETS='localhost:9399' docker-run
```
or 
```
make RUN_JAEGER=1 docker-run 
```
if you need to run Jaeger tracing app 

## Endpoints description 

### Grafana UI 

http://127.0.0.1:3000 
Credentials: 'admin:test' 

Open side menu item 'Dashboards->Browse' and try to use any of built-in dashboards. 
We have three built-in dashboards in general folder: 
    - AcraServer 
    - AcraServer Log View 
    - AcraServer Logging Dashboard 


### Prometheus UI 

http://127.0.0.1:9090

Open http://127.0.0.1:9090/targets to get list of active targets endpoints which you have defined in PROMETHEUS_TARGETS environment variable. In successful case you will be able to get list of metrics collected from remote. 


### Loki endpoint 

http://127.0.0.1:3100/ 

You already have used Loki endpoint http://${loki-container-address-port}/loki/api/v1/push to collect logs from acra. 
You can't find any interesting UI here. Use Grafana UI to find any collected logs and view it. 

### Jaeger UI 

http://127.0.0.1:16686/

This is Jaeger UI. 




## Troubleshooting 

### Prometheus 
Take a look to http://$your_host:9090/config 
You should see static_configs->targets->your targets value. Check the value.  

### Logs 
Our project exports port 3100 of Loki without any authentication parameters. 
You may probably forgot to export logs to Loki or you have network issues. 
Try to make HTTP request to your fresh Loki installation from server with Acra. 

## Stop and clean 

Do not want to play anymore? You can clear your system. 
```
make docker-stop
make docker-clean
```

You may run 'docker images' to check docker images list to ensure that acra-telemetry-collector has removed from server. 




