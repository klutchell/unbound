# override these values at runtime as desired
# eg. make build ARCH=arm32v6 BUILD_OPTIONS=--squash PUSH=y

ARCH := amd64
DOCKER_REPO := klutchell/unbound
BUILD_OPTIONS +=

# ARCH can be amd64, arm32v6, arm32v7, arm64v8, i386, ppc64le, s390x
# https://github.com/docker-library/official-images#architectures-other-than-amd64
# https://hub.docker.com/r/amd64/alpine/
# https://hub.docker.com/r/arm32v6/alpine/
# https://hub.docker.com/r/arm32v7/alpine/
# https://hub.docker.com/r/arm64v8/alpine/
# https://hub.docker.com/r/i386/alpine/
# https://hub.docker.com/r/ppc64le/alpine/
# https://hub.docker.com/r/s390x/alpine/

BUILD_DATE := $(strip $(shell docker run --rm busybox date -u +'%Y-%m-%dT%H:%M:%SZ'))
# BUILD_VERSION := $(strip $(shell git describe --tags --always --dirty))
BUILD_VERSION := 1.9.3
VCS_REF := $(strip $(shell git rev-parse --short HEAD))
# VCS_TAG := $(strip $(shell git describe --abbrev=0 --tags))
VCS_TAG := 1.9.3

IMAGE := ${DOCKER_REPO}:${VCS_TAG}

.EXPORT_ALL_VARIABLES:

.DEFAULT_GOAL := build

.PHONY: all build test release push clean manifest help

all: ## Build release images and manifests for all platforms
	make release ARCH=amd64
	make release ARCH=arm32v6
	make release ARCH=arm32v7
	make release ARCH=arm64v8
	make release ARCH=i386
	make release ARCH=ppc64le
	make release ARCH=s390x

build: qemu-user-static ## Build a development image for testing
	docker build ${BUILD_OPTIONS} \
		--build-arg ARCH \
		--build-arg BUILD_VERSION \
		--build-arg BUILD_DATE \
		--build-arg VCS_REF \
		--build-arg RM_QEMU=n \
		--tag ${DOCKER_REPO}:${ARCH}

test: build ## Run tests on a development image
	docker run --rm ${DOCKER_REPO}:${ARCH} /test.sh

release: test ## Build a release image for the docker repo
	docker build ${BUILD_OPTIONS} \
		--build-arg ARCH \
		--build-arg BUILD_VERSION \
		--build-arg BUILD_DATE \
		--build-arg VCS_REF \
		--build-arg RM_QEMU=y \
		--tag ${DOCKER_REPO}:${ARCH}-${VCS_TAG} .

push: ## Push a release image to the docker repo (requires docker login)
	docker push ${DOCKER_REPO}:${ARCH}-${VCS_TAG}

clean: ## Remove cached release and development images
	-docker image rm ${DOCKER_REPO}:${ARCH}-${VCS_TAG}
	-docker image rm ${DOCKER_REPO}:${ARCH}

manifest: ## Create multiarch manifests on the docker repo (requires docker login)
	-docker manifest push --purge ${DOCKER_REPO}:${VCS_TAG}
	docker manifest create ${DOCKER_REPO}:${VCS_TAG} \
		${DOCKER_REPO}:amd64-${VCS_TAG} \
		${DOCKER_REPO}:arm32v6-${VCS_TAG} \
		${DOCKER_REPO}:arm32v7-${VCS_TAG} \
		${DOCKER_REPO}:arm64v8-${VCS_TAG} \
		${DOCKER_REPO}:i386-${VCS_TAG} \
		${DOCKER_REPO}:ppc64le-${VCS_TAG} \
		${DOCKER_REPO}:s390x-${VCS_TAG}
	docker manifest annotate ${DOCKER_REPO}:${VCS_TAG} ${DOCKER_REPO}:arm32v6-${VCS_TAG} --os linux --arch arm --variant v6
	docker manifest annotate ${DOCKER_REPO}:${VCS_TAG} ${DOCKER_REPO}:arm32v7-${VCS_TAG} --os linux --arch arm --variant v7
	docker manifest annotate ${DOCKER_REPO}:${VCS_TAG} ${DOCKER_REPO}:arm64v8-${VCS_TAG} --os linux --arch arm64 --variant v8
	docker manifest push --purge ${DOCKER_REPO}:${VCS_TAG}
	-docker manifest push --purge ${DOCKER_REPO}:latest
	docker manifest create ${DOCKER_REPO}:latest \
		${DOCKER_REPO}:amd64-${VCS_TAG} \
		${DOCKER_REPO}:arm32v6-${VCS_TAG} \
		${DOCKER_REPO}:arm32v7-${VCS_TAG} \
		${DOCKER_REPO}:arm64v8-${VCS_TAG} \
		${DOCKER_REPO}:i386-${VCS_TAG} \
		${DOCKER_REPO}:ppc64le-${VCS_TAG} \
		${DOCKER_REPO}:s390x-${VCS_TAG}
	docker manifest annotate ${DOCKER_REPO}:latest ${DOCKER_REPO}:arm32v6-${VCS_TAG} --os linux --arch arm --variant v6
	docker manifest annotate ${DOCKER_REPO}:latest ${DOCKER_REPO}:arm32v7-${VCS_TAG} --os linux --arch arm --variant v7
	docker manifest annotate ${DOCKER_REPO}:latest ${DOCKER_REPO}:arm64v8-${VCS_TAG} --os linux --arch arm64 --variant v8
	docker manifest push --purge ${DOCKER_REPO}:latest

qemu-user-static:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

help: ## Display available commands
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
