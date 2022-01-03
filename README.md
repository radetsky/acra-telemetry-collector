# acra-telemetry-collector
Acra Telemetry collector was created to get a convenient and simple tool for tracking Acra Server operation.

# Using 

## Install and run 

```
git clone git@github.com:radetsky/acra-telemetry-collector.git
docker-compose up 
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
