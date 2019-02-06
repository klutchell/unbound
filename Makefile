
DOCKER_REPO := klutchell/unbound
ARCH := amd64
BUILD_OPTS :=
VERSION := 1.9.0

BUILD_NUMBER := $(strip $(shell git describe --all --long --dirty --always))
BUILD_DATE := $(strip $(shell docker run --rm alpine date -u +'%Y-%m-%dT%H:%M:%SZ'))
VCS_REF := $(strip $(shell git rev-parse --short HEAD))

IMAGE_NAME := ${DOCKER_REPO}:${ARCH}-${VERSION}
BUILD_VERSION := ${VERSION}-${BUILD_NUMBER}


.DEFAULT_GOAL := build

.EXPORT_ALL_VARIABLES:

.PHONY: build
build:
	docker-compose -p ci build ${BUILD_OPTS}

.PHONY: test
test:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset
	docker-compose -p ci run test sh -c 'dig sigfail.verteiltesysteme.net @unbound -p 53 | grep -q SERVFAIL'
	docker-compose -p ci run test sh -c 'dig sigok.verteiltesysteme.net @unbound -p 53 | grep -q NOERROR'

.PHONY: push
push:
	docker push ${IMAGE_NAME}
	docker tag ${IMAGE_NAME} ${DOCKER_REPO}:${ARCH}
	docker push ${DOCKER_REPO}:${ARCH}

.PHONY: release
release:	build test push

.PHONY: manifest
manifest:
	sed "s/{VERSION}/${VERSION}/g" manifest.yml > tmp.yml
	manifest-tool push from-spec tmp.yml
	rm tmp.yml

.PHONY: all
all:
	make release ARCH=amd64
	make release ARCH=arm32v6
	make release ARCH=arm64v8

.PHONY: lint
lint:
	docker-compose -p ci config -q
	docker run -v $(CURDIR):/project --rm skandyla/travis-cli lint .travis.yml

${ARCH}:
	mkdir ${ARCH}