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
Edit prometheus/prometheus.yml and replace targets to host and port where your Acra Server exposes metrics. 

## Run 
```
docker-compose up
```

## Play 

Use 'admin:test' credentials and 'http://your-server-url:3000' to enter to grafana. Open side menu item 'Dashboards->Browse' and try to use any of built-in dashboards. 






