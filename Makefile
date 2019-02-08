# variables are exported for all subprocesses
# override variables at runtime as needed
# eg. make build ARCH=arm BUILD_OPTIONS=--no-cache

.EXPORT_ALL_VARIABLES:

# used by all targets
DOCKER_REPO := klutchell/unbound
VERSION := 1.9.0
ARCH := amd64

# used by build target only
BUILD_DATE := $(strip $(shell docker run --rm alpine date -u +'%Y-%m-%dT%H:%M:%SZ'))
BUILD_VERSION := ${VERSION}-$(strip $(shell git describe --all --long --dirty --always))
VCS_REF := $(strip $(shell git rev-parse --short HEAD))

# set these vars in compose_options in case docker-compose is executed in a container
COMPOSE_OPTIONS := -e DOCKER_REPO -e VERSION -e ARCH -e BUILD_DATE -e BUILD_VERSION -e VCS_REF
BUILD_OPTIONS :=

.DEFAULT_GOAL := build

.PHONY: build
build:
	docker-compose -p ci build ${BUILD_OPTIONS} unbound

.PHONY: test
test: qemu-user-static
	docker-compose -p ci build tests
	docker-compose -p ci run --rm tests

.PHONY: push
push:
	docker-compose -p ci push unbound

.PHONY: release
release:	build test push

.PHONY: latest
latest: manifest-tool
	manifest-tool push from-args --platforms linux/amd64,linux/arm,linux/arm64 \
	--template ${DOCKER_REPO}:${VERSION}-ARCH \
	--target ${DOCKER_REPO}:${VERSION}
	manifest-tool push from-args --platforms linux/amd64,linux/arm,linux/arm64 \
	--template ${DOCKER_REPO}:${VERSION}-ARCH \
	--target ${DOCKER_REPO}:latest

.PHONY: lint
lint: travis
	docker-compose -p ci config -q
	travis lint .travis.yml

.PHONY: qemu-user-static
qemu-user-static:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

.PHONY: manifest-tool
manifest-tool:
	@manifest-tool --version

.PHONY: travis
travis:
	@travis --version
