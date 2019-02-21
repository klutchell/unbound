# variables are exported for all subprocesses
# override variables at runtime as needed
# eg. make build ARCH=armhf BUILD_OPTIONS=--no-cache

.EXPORT_ALL_VARIABLES:

# used by all targets
ARCH := amd64

# used by build target only
BUILD_TAG := dev
BUILD_DATE := $(strip $(shell docker run --rm busybox date -u +'%Y-%m-%dT%H:%M:%SZ'))
VCS_REF := $(strip $(shell git rev-parse --short HEAD))

# static arch-to-goarch mapping
# supported ARCH values can be found here: https://hub.docker.com/r/multiarch/alpine/tags
# supported GOARCH values can be found here: https://golang.org/doc/install/source#environment
amd64_GOARCH = amd64
armhf_GOARCH = arm
arm64_GOARCH = arm64
GOARCH = ${${ARCH}_GOARCH}

# export these vars via COMPOSE_OPTIONS in case docker-compose is executed in a container
# https://docs.docker.com/compose/reference/envvars/
COMPOSE_PROJECT_NAME := ci
COMPOSE_FILE += docker-compose.ci.yml
COMPOSE_OPTIONS += -e ARCH -e GOARCH -e BUILD_DATE -e BUILD_TAG -e VCS_REF -e COMPOSE_PROJECT_NAME -e COMPOSE_FILE

BUILD_OPTIONS +=

.DEFAULT_GOAL := build

.PHONY: qemu-user-static
qemu-user-static:
	@docker run --rm --privileged multiarch/qemu-user-static:register --reset

.PHONY: build
build: qemu-user-static
	docker-compose build ${BUILD_OPTIONS}

.PHONY: test
test:
	docker-compose up --build --abort-on-container-exit

.PHONY: push
push:
	docker-compose push unbound

.PHONY: lint
lint:
	docker-compose config -q
	travis lint

.PHONY: manifest
manifest:
	manifest-tool push from-spec manifest.yml

.PHONY: release
release: build test push
