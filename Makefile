# override these values at runtime as desired
# eg. make build ARCH=armhf BUILD_OPTIONS=--no-cache
ARCH := amd64
BUILD_OPTIONS +=

# static arch-to-goarch mapping
# supported ARCH values can be found here: https://hub.docker.com/r/multiarch/alpine/tags
# supported GOARCH values can be found here: https://golang.org/doc/install/source#environment
amd64_GOARCH = amd64
armhf_GOARCH = arm
arm64_GOARCH = arm64

# travis-ci will override the BUILD_VERSION but everything else should be left as-is
IMAGE_TAG := 1.9.0-${${ARCH}_GOARCH}
BUILD_VERSION := 1.9.0-dev
BUILD_DATE := $(strip $(shell docker run --rm busybox date -u +'%Y-%m-%dT%H:%M:%SZ'))
VCS_REF := $(strip $(shell git rev-parse --short HEAD))

# export these vars via COMPOSE_OPTIONS in case docker-compose is executed in a container
# https://docs.docker.com/compose/reference/envvars/
COMPOSE_PROJECT_NAME := ci
COMPOSE_FILE += docker-compose.ci.yml
COMPOSE_OPTIONS += -e ARCH -e IMAGE_TAG -e BUILD_VERSION -e BUILD_DATE -e VCS_REF -e COMPOSE_PROJECT_NAME -e COMPOSE_FILE

.DEFAULT_GOAL := build

.EXPORT_ALL_VARIABLES:

.PHONY: qemu-user-static
qemu-user-static:
	@docker run --rm --privileged multiarch/qemu-user-static:register --reset

.PHONY: build
build: qemu-user-static
	@docker-compose build ${BUILD_OPTIONS}

.PHONY: test
test: qemu-user-static
	@docker-compose up --build --abort-on-container-exit

.PHONY: push
push:
	@docker-compose push unbound

.PHONY: lint
lint:
	@docker-compose config -q
	@travis lint

.PHONY: manifest
manifest:
	@manifest-tool push from-spec manifest.yml

.PHONY: release
release: build test push
