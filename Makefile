# override these values at runtime as desired
# eg. make build ARCH=arm32v6 BUILD_OPTIONS=--no-cache
# ARCH can be amd64, arm32v6, arm32v7, or arm64v8
ARCH := amd64
DOCKER_REPO := klutchell/unbound
BUILD_OPTIONS +=

BUILD_DATE := $(strip $(shell docker run --rm busybox date -u +'%Y-%m-%dT%H:%M:%SZ'))
# BUILD_VERSION := $(strip $(shell git describe --tags --always --dirty))
BUILD_VERSION := 1.9.3
VCS_REF := $(strip $(shell git rev-parse --short HEAD))
# VCS_TAG := $(strip $(shell git describe --abbrev=0 --tags))
VCS_TAG := 1.9.3

IMAGE := ${DOCKER_REPO}:${VCS_TAG}

ifeq "${ARCH}" "amd64"
QEMU_BINARY := qemu-x86_64-static
endif

ifeq "${ARCH}" "arm32v6"
QEMU_BINARY := qemu-arm-static
endif

ifeq "${ARCH}" "arm32v7"
QEMU_BINARY := qemu-arm-static
endif

ifeq "${ARCH}" "arm64v8"
QEMU_BINARY := qemu-aarch64-static
endif

.EXPORT_ALL_VARIABLES:

.DEFAULT_GOAL := all

.PHONY: all release build test clean push manifest help

all: build test ## Build and test image

build: qemu-user-static ## Build and tag image
	docker build ${BUILD_OPTIONS} \
		--build-arg ARCH=${ARCH} \
		--build-arg QEMU_BINARY=${QEMU_BINARY} \
		--build-arg BUILD_VERSION \
		--build-arg BUILD_DATE \
		--build-arg VCS_REF \
		--tag ${DOCKER_REPO}:${ARCH}-${VCS_TAG} .
	docker tag ${DOCKER_REPO}:${ARCH}-${VCS_TAG} ${DOCKER_REPO}:${ARCH}-latest

test: qemu-user-static ## Test existing image
	docker run --rm ${DOCKER_REPO}:${ARCH}-${VCS_TAG} /test.sh

clean: ## Remove existing image
	-docker image rm ${DOCKER_REPO}:${ARCH}-${VCS_TAG}
	-docker image rm ${DOCKER_REPO}:${ARCH}-latest

push: ## Push existing image to docker repo
	docker push ${DOCKER_REPO}:${ARCH}-${VCS_TAG}
	docker push ${DOCKER_REPO}:${ARCH}-latest

pull: ## Pull existing image from docker repo
	docker pull ${DOCKER_REPO}:${ARCH}-${VCS_TAG}
	docker pull ${DOCKER_REPO}:${ARCH}-latest

release: clean build test push ## Clean, build, test, and push image

manifest: ## Create and push multi-arch manifest to docker repo
	docker manifest create ${DOCKER_REPO}:${VCS_TAG} \
		${DOCKER_REPO}:amd64-${VCS_TAG} \
		${DOCKER_REPO}:arm32v6-${VCS_TAG} \
		${DOCKER_REPO}:arm32v7-${VCS_TAG} \
		${DOCKER_REPO}:arm64v8-${VCS_TAG}
	docker manifest annotate ${DOCKER_REPO}:${VCS_TAG} ${DOCKER_REPO}:arm32v6-${VCS_TAG} --os linux --arch arm --variant v6
	docker manifest annotate ${DOCKER_REPO}:${VCS_TAG} ${DOCKER_REPO}:arm32v7-${VCS_TAG} --os linux --arch arm --variant v7
	docker manifest annotate ${DOCKER_REPO}:${VCS_TAG} ${DOCKER_REPO}:arm64v8-${VCS_TAG} --os linux --arch arm64 --variant v8
	docker manifest push --purge ${DOCKER_REPO}:${VCS_TAG}
	docker manifest create ${DOCKER_REPO}:latest \
		${DOCKER_REPO}:amd64-latest \
		${DOCKER_REPO}:arm32v6-latest \
		${DOCKER_REPO}:arm32v7-latest \
		${DOCKER_REPO}:arm64v8-latest
	docker manifest annotate ${DOCKER_REPO}:latest ${DOCKER_REPO}:arm32v6-latest --os linux --arch arm --variant v6
	docker manifest annotate ${DOCKER_REPO}:latest ${DOCKER_REPO}:arm32v7-latest --os linux --arch arm --variant v7
	docker manifest annotate ${DOCKER_REPO}:latest ${DOCKER_REPO}:arm64v8-latest --os linux --arch arm64 --variant v8
	docker manifest push --purge ${DOCKER_REPO}:latest

qemu-user-static:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

help: ## Display available commands
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
