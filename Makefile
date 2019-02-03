
DOCKER_REPO := klutchell/unbound
ARCH := amd64
BUILD_OPTS :=

DOCKERFILE_PATH := Dockerfile.${ARCH}
DOCKER_TAG := ${DOCKER_REPO}:${ARCH}-dev

BUILD_DATE := $(strip $(shell docker run --rm alpine date -u +'%Y-%m-%dT%H:%M:%SZ'))
VCS_REF := $(strip $(shell git describe --all --long --dirty --always))

.DEFAULT_GOAL := build

.PHONY: build
build:
	docker build ${BUILD_OPTS} --build-arg BUILD_DATE=${BUILD_DATE} --build-arg VCS_REF=${VCS_REF} -f ${DOCKERFILE_PATH} -t ${DOCKER_TAG} .

.PHONY: test
test:
	docker-compose -f docker-compose.test.yml -p ci up --build --abort-on-container-exit

.PHONY: push
push:
	docker push ${DOCKER_TAG}

.PHONY: release
release:	build test push