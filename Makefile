
DOCKER_REPO := klutchell/unbound
ARCH := amd64
VERSION := dev
BUILD_OPTS :=

ifeq "${VERSION}" "latest"
IMAGE_NAME := ${DOCKER_REPO}:${ARCH}
else
IMAGE_NAME := ${DOCKER_REPO}:${ARCH}-${VERSION}
endif

BUILD_DATE := $(strip $(shell docker run --rm alpine date -u +'%Y-%m-%dT%H:%M:%SZ'))
BUILD_VERSION := $(strip $(shell git describe --all --long --dirty --always))
VCS_REF := $(strip $(shell git rev-parse --short HEAD))

.DEFAULT_GOAL := build

.EXPORT_ALL_VARIABLES:

.PHONY: build
build: ${ARCH}
	sed "s/amd64/${ARCH}/g" Dockerfile > ${ARCH}/Dockerfile
	docker run --rm --privileged multiarch/qemu-user-static:register --reset
	docker-compose -p ci build ${BUILD_OPTS}

.PHONY: test
test: ${ARCH}
	sed "s/amd64/${ARCH}/g" Dockerfile > ${ARCH}/Dockerfile
	docker run --rm --privileged multiarch/qemu-user-static:register --reset
	docker-compose -p ci run sigfail
	docker-compose -p ci run sigok

.PHONY: lint
lint:
	docker-compose -p ci config -q
	docker run -v $(CURDIR):/project --rm skandyla/travis-cli lint .travis.yml

.PHONY: push
push:
	docker push ${IMAGE_NAME}

.PHONY: release
release:	build test push

${ARCH}:
	mkdir ${ARCH}