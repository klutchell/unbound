# variables are exported for all subprocesses
# override variables at runtime as needed
# eg. make build ARCH=arm BUILD_OPTS=--no-cache

# used by all targets
DOCKER_REPO := klutchell/unbound
VERSION := 1.9.0
ARCH := amd64

# used by build target only
BUILD_OPTS :=
BUILD_DATE := $(strip $(shell docker run --rm alpine date -u +'%Y-%m-%dT%H:%M:%SZ'))
BUILD_VERSION := ${VERSION}-$(strip $(shell git describe --all --long --dirty --always))
VCS_REF := $(strip $(shell git rev-parse --short HEAD))

.DEFAULT_GOAL := build

.EXPORT_ALL_VARIABLES:

.PHONY: build
build:
	docker-compose -p ci build ${BUILD_OPTS}

.PHONY: test
test: qemu-user-static
	docker-compose -p ci run test sh -c 'dig sigfail.verteiltesysteme.net @unbound -p 53 | grep -q SERVFAIL'
	docker-compose -p ci run test sh -c 'dig sigok.verteiltesysteme.net @unbound -p 53 | grep -q NOERROR'

.PHONY: push
push:
	docker-compose -p ci push unbound

.PHONY: release
release:	build test push

.PHONY: manifest
manifest: manifest-tool
	manifest-tool push from-args \
    --platforms linux/amd64,linux/arm,linux/arm64 \
    --template ${DOCKER_REPO}:ARCH-${VERSION} \
    --target ${DOCKER_REPO}:${VERSION}
	manifest-tool push from-args \
    --platforms linux/amd64,linux/arm,linux/arm64 \
    --template ${DOCKER_REPO}:ARCH-${VERSION} \
    --target ${DOCKER_REPO}:latest

.PHONY: manifest-tool
manifest-tool:
ifeq (, $(shell which manifest-tool))
	go get -v github.com/estesp/manifest-tool
endif

.PHONY: qemu-user-static
qemu-user-static:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

.PHONY: lint
lint:
	docker-compose -p ci config -q
	docker run -v $(CURDIR):/project --rm skandyla/travis-cli lint .travis.yml
