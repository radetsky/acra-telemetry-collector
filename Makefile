docker.DEFAULT_GOAL := all

.PHONY: all help docker-build docker-clean
#===== Variables ===============================================================

#----- Application -------------------------------------------------------------
APP_NAME := acra-telemetry-collector 
BUILD_DATE := $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
BUILD_DIR := build

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

DOCKER_REGISTRY_HOST ?= localhost
DOCKER_REGISTRY_PATH ?= cossacklabs

DOCKER_IMAGE_NAME := $(DOCKER_REGISTRY_HOST)/$(DOCKER_REGISTRY_PATH)/$(APP_NAME)
DOCKER_IMAGE_NAME_LOCAL := $(DOCKER_REGISTRY_PATH)/$(APP_NAME)
DOCKER_DOCKERFILE := ./docker/$(APP_NAME).Dockerfile
DOCKER_IMAGE_CONTEXT := .

DOCKER_BUILD_TAGS ?= rad
DOCKER_PUSH_TAGS ?= rad

#----- Makefile ----------------------------------------------------------------

COLOR_DEFAULT=\033[0m
COLOR_MENU=\033[93m
COLOR_ENVVAR=\033[1m

#===== Targets =================================================================

#----- Help --------------------------------------------------------------------

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[93m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "\n  Allowed for overriding next properties:\n\n\
	    ${COLOR_ENVVAR}DOCKER_REGISTRY_HOST${COLOR_DEFAULT} - Registry host\n\
	                           ('$(DOCKER_REGISTRY_HOST)' by default)\n\
	    ${COLOR_ENVVAR}DOCKER_REGISTRY_PATH${COLOR_DEFAULT} - Registry path\n\
	                           (usually - company name, '$(DOCKER_REGISTRY_PATH)' by default)\n\
	    ${COLOR_ENVVAR}DOCKER_BUILD_TAGS${COLOR_DEFAULT}    - Tags list for building\n\
	                           (delimiter - single space, '$(DOCKER_BUILD_TAGS)' by default)\n\
	    ${COLOR_ENVVAR}DOCKER_PUSH_TAGS${COLOR_DEFAULT}     - Tags list for  pushing into remote registry\n\
	                           (delimiter - single space, '$(DOCKER_PUSH_TAGS)' by default)\n\
	  Usage example:\n\
	    make DOCKER_BUILD_TAGS='latest master' DOCKER_PUSH_TAGS='latest 1.2.3 test-tag' docker-push"

docker-build: ## Docker : build and pull images to localhost 
	docker-compose pull 
	docker-compose build 

docker-run: ## Run acra-telemetry-collector as docker-compose service
	docker-compose -p acra-telemetry-collector -f ./docker-compose.yml up -d 

docker-top: ## Show running services  
	docker-compose top 

docker-stop: ## Terminate acra-telemetry-collector 
	docker-compose -p acra-telemetry-collector -f ./docker-compose.yml stop 

docker-clean: ## Docker : remove stopped containers and dangling images
	$(DOCKER_BIN) container prune -f --filter "label=com.docker.compose.project=acra-telemetry-collector"
	$(DOCKER_BIN) images --format "{{.Repository}}:{{.Tag}}:{{.ID}}" | grep "prom/prometheus:v2.32.1" | cut -f 3 -d ":" | xargs docker rmi 
	$(DOCKER_BIN) images --format "{{.Repository}}:{{.Tag}}:{{.ID}}" | grep "grafana/grafana:8.3.3" | cut -f 3 -d ":" | xargs docker rmi 
	$(DOCKER_BIN) images --format "{{.Repository}}:{{.Tag}}:{{.ID}}" | grep "jaegertracing/all-in-one:1.29" | cut -f 3 -d ":" | xargs docker rmi 
	$(DOCKER_BIN) images --format "{{.Repository}}:{{.Tag}}:{{.ID}}" | grep "grafana/loki:master" | cut -f 3 -d ":" | xargs docker rmi 
