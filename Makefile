docker.DEFAULT_GOAL := help

.PHONY: help docker-build docker-run docker-top docker-stop docker-clean 
#===== Variables ===============================================================

#----- Application -------------------------------------------------------------
APP_NAME := acra-telemetry-collector 
BUILD_DATE := $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
BUILD_DIR := build

PROMETHEUS_TARGETS := 'localhost:9399'
# Enable this variable with arguments to makefile. See make help. 
# RUN_JAEGER := true 
#

#----- Git ---------------------------------------------------------------------

GIT_VERSION := $(shell if [ -d ".git" ]; then git version; fi 2>/dev/null)
ifdef GIT_VERSION
    APP_VERSION := $(shell git describe --tags HEAD 2>/dev/null || echo '0.0.0' | cut -b 1-)
    APP_GIT_HASH := $(shell git rev-parse --verify HEAD)
    VCS_BRANCH := $(shell git branch | grep \* | cut -d ' ' -f2)
else
    APP_VERSION := $(shell date +%s)
    APP_GIT_HASH := '00000000'
    VCS_BRANCH := master
endif

#----- Docker ------------------------------------------------------------------
DOCKER_BIN := $(shell command -v docker 2> /dev/null)

#----- Makefile ----------------------------------------------------------------

COLOR_DEFAULT=\033[0m
COLOR_MENU=\033[93m
COLOR_ENVVAR=\033[1m

#===== Targets =================================================================

#----- Help --------------------------------------------------------------------

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[93m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "\n  Allowed for overriding next properties:\n\n\
	    ${COLOR_ENVVAR}PROMETHEUS_TARGETS${COLOR_DEFAULT} - Prometheus targets ($(PROMETHEUS_TARGETS) by default)\n\
	    ${COLOR_ENVVAR}RUN_JAEGER${COLOR_DEFAULT}         - To run jaeger tracing app (usually - not, undefined by default)\n\
	  Usage example:\n\
        make PROMETHEUS_TARGETS='localhost:9399' docker-run\n\
        make RUN_JAEGER=1 docker-run"

docker-build: ## Docker : build and pull images to localhost 
	docker-compose build 

docker-run: ## Run acra-telemetry-collector as docker-compose service
ifdef RUN_JAEGER
	docker-compose -p acra-telemetry-collector -f ./docker-compose.yml -f ./jaeger/docker-compose.yml up -d 
else
	docker-compose -p acra-telemetry-collector -f ./docker-compose.yml up -d 
endif

docker-top: ## Show running services  
	docker-compose top 

docker-stop: ## Terminate acra-telemetry-collector 
	docker-compose -p acra-telemetry-collector -f ./docker-compose.yml -f ./jaeger/docker-compose.yml  stop 

docker-clean: ## Remove stopped containers and dangling images
	$(DOCKER_BIN) container prune -f --filter "label=com.docker.compose.project=acra-telemetry-collector"
	$(DOCKER_BIN) images --format "{{.Repository}}:{{.Tag}}:{{.ID}}" | grep "acra-telemetry-collector_prometheus:latest" | cut -f 3 -d ":" | xargs docker rmi 
	$(DOCKER_BIN) images --format "{{.Repository}}:{{.Tag}}:{{.ID}}" | grep "grafana/grafana:8.3.3" | cut -f 3 -d ":" | xargs docker rmi 
	$(DOCKER_BIN) images --format "{{.Repository}}:{{.Tag}}:{{.ID}}" | grep "jaegertracing/all-in-one:1.29" | cut -f 3 -d ":" | xargs docker rmi 
	$(DOCKER_BIN) images --format "{{.Repository}}:{{.Tag}}:{{.ID}}" | grep "grafana/loki:master" | cut -f 3 -d ":" | xargs docker rmi 
	$(DOCKER_BIN) image prune -f -a --filter "label=com.cossacklabs.acra-telemetry-collector=prometheus"
