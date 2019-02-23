# static arch-to-goarch mapping (don't change these)
# supported ARCH values can be found here: https://hub.docker.com/r/multiarch/alpine/tags
# supported GOARCH values can be found here: https://golang.org/doc/install/source#environment
amd64_GOARCH = amd64
armhf_GOARCH = arm
arm64_GOARCH = arm64

# override these values at runtime as desired
# eg. make build ARCH=armhf BUILD_OPTIONS=--no-cache
ARCH := amd64
BUILD_OPTIONS +=
DOCKER_REPO := klutchell/unbound
APP_VERSION := 1.9.0

# these are used for labels in the container at build time
# travis-ci will override the BUILD_VERSION but everything else should be left as-is for consistency
IMAGE_TAG := ${APP_VERSION}-${${ARCH}_GOARCH}
BUILD_VERSION := ${APP_VERSION}-$(strip $(shell git describe --always --dirty))
BUILD_DATE := $(strip $(shell docker run --rm busybox date -u +'%Y-%m-%dT%H:%M:%SZ'))
VCS_REF := $(strip $(shell git rev-parse --short HEAD))

.DEFAULT_GOAL := build

.EXPORT_ALL_VARIABLES:

.PHONY: qemu-user-static
qemu-user-static:
	@docker run --rm --privileged multiarch/qemu-user-static:register --reset

.PHONY: build
build: qemu-user-static
	@docker build ${BUILD_OPTIONS} --build-arg ARCH --build-arg BUILD_VERSION --build-arg BUILD_DATE --build-arg VCS_REF -t ${DOCKER_REPO}:${IMAGE_TAG} .

.PHONY: test
test: qemu-user-static
	@docker run --rm ${DOCKER_REPO}:${IMAGE_TAG} /bin/sh -xec "/startup.sh & sleep 5 && /healthcheck.sh"

.PHONY: push
push:
	@docker push ${DOCKER_REPO}:${IMAGE_TAG}

.PHONY: manifest
manifest:
	@manifest-tool push from-spec manifest.yml

.PHONY: release
release: build test push
