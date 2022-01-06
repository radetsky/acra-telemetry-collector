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

Please add next options to your docker-compose file or docker run options.
Replace $loki-container-address with address of your server where you run acra-telemetry-collector 

```
logging:
    driver: loki
    options:
        loki-url: "http://$loki-container-address:3100/loki/api/v1/push"
        loki-batch-size: "400"
        loki-retries: "5"
 ```       
or run docker with these options:
```
docker run --log-driver=loki \
    --log-opt loki-url="http://$loki-container-address/loki/api/v1/push" \
    --log-opt loki-retries=5 \
    --log-opt loki-batch-size=400 \
    $your_acra_server
```

These changes will help you start sending logs to the specified server.

## Setup metrics collection 

Find --incoming_connection_prometheus_metrics_string parameter in options to check where exactly your Acra Server metrics is available. 

Use PROMETHEUS_TARGETS environment variable to declare where your Acra Server exposes metrics when you build project. 
```
make PROMETHEUS_TARGETS='localhost:9399' docker-build
```
This command will rebuild prometheus docker image with new target. 
Next make docker-run will use fresh image to run container with the right target. 


## Run 
```
make docker-run
```
or 
```
make RUN_JAEGER=1 docker-run 
```
if you need to run Jaeger tracing app 

## Play with Grafana 

Use 'admin:test' credentials and 'http://your-server-url:3000' to enter to grafana. Open side menu item 'Dashboards->Browse' and try to use any of built-in dashboards. 
We have three built-in dashboards in general folder: 
    - AcraServer 
    - AcraServer Log View 
    - AcraServer Logging Dashboard 



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




