
DOCKER_REPO := klutchell/unbound
ARCH := amd64
VERSION := 1.9.0
BUILD := dev
BUILD_OPTS :=

IMAGE_NAME := ${DOCKER_REPO}:${ARCH}-${VERSION}

BUILD_DATE := $(strip $(shell docker run --rm alpine date -u +'%Y-%m-%dT%H:%M:%SZ'))
VCS_REF := $(strip $(shell git rev-parse --short HEAD))

ifeq "${BUILD}" "dev"
BUILD_VERSION := $(strip $(shell git describe --all --long --dirty --always))
else
BUILD_VERSION := ${VERSION}-${BUILD}
endif


.DEFAULT_GOAL := build

.EXPORT_ALL_VARIABLES:

.PHONY: build
build:
	docker-compose -p ci build ${BUILD_OPTS}

.PHONY: test
test:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset
	docker-compose -p ci run sigfail
	docker-compose -p ci run sigok

.PHONY: push
push:
	docker push ${IMAGE_NAME}

.PHONY: release
release:	build test push

.PHONY: lint
lint:
	docker-compose -p ci config -q
	docker run -v $(CURDIR):/project --rm skandyla/travis-cli lint .travis.yml

${ARCH}:
	mkdir ${ARCH}