# variables are exported for all subprocesses
# override variables at runtime as needed
# eg. make build ARCH=arm BUILD_OPTIONS=--no-cache

.EXPORT_ALL_VARIABLES:

# used by all targets
DOCKER_REPO := klutchell/unbound
APP_VERSION := 1.9.0
ARCH := amd64

# used by build target only
BUILD_DATE := $(strip $(shell docker run --rm busybox date -u +'%Y-%m-%dT%H:%M:%SZ'))
BUILD_VERSION := ${APP_VERSION}-$(strip $(shell git describe --all --long --dirty --always))
VCS_REF := $(strip $(shell git rev-parse --short HEAD))

# set these vars in compose_options in case docker-compose is executed in a container
COMPOSE_OPTIONS += -e DOCKER_REPO -e APP_VERSION -e ARCH -e BUILD_DATE -e BUILD_VERSION -e VCS_REF
BUILD_OPTIONS +=

.DEFAULT_GOAL := build

# create dockerfile.arch by substituting the FROM multiarch image tag
# supported FROM tags can be found here: https://hub.docker.com/r/multiarch/alpine/tags
# supported TARGET tags can be found here: https://golang.org/doc/install/source#environment
.PHONY: Dockerfile.amd64
Dockerfile.amd64: Dockerfile ; sed -r "s/:[^-]+-/:amd64-/g" Dockerfile > Dockerfile.amd64
.PHONY: Dockerfile.arm
Dockerfile.arm: Dockerfile ; sed -r "s/:[^-]+-/:armhf-/g" Dockerfile > Dockerfile.arm
.PHONY: Dockerfile.arm64
Dockerfile.arm64: Dockerfile ; sed -r "s/:[^-]+-/:aarch64-/g" Dockerfile > Dockerfile.arm64

.PHONY: build
build: Dockerfile.${ARCH} qemu-user-static
	docker-compose -p ci build ${BUILD_OPTIONS} unbound

.PHONY: test
test: Dockerfile.${ARCH} qemu-user-static
	docker-compose -p ci run --rm tests

.PHONY: push
push: Dockerfile.${ARCH} qemu-user-static
	docker-compose -p ci push unbound

.PHONY: release
release: build test push

.PHONY: manifest
manifest:
	manifest-tool push from-args --platforms linux/amd64,linux/arm,linux/arm64 \
	--template ${DOCKER_REPO}:${APP_VERSION}-ARCH \
	--target ${DOCKER_REPO}:${APP_VERSION}
	manifest-tool push from-args --platforms linux/amd64,linux/arm,linux/arm64 \
	--template ${DOCKER_REPO}:${APP_VERSION}-ARCH \
	--target ${DOCKER_REPO}:latest

.PHONY: lint
lint:
	docker-compose -p ci config -q
	travis lint .travis.yml

.PHONY: qemu-user-static
qemu-user-static:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

