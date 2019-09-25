# override these variables at runtime as desired
# eg. make build ARCH=arm32v6 BUILD_OPTIONS=--no-cache TAG=latest

# ARCH can be amd64, arm32v6, arm32v7, arm64v8, i386, ppc64le, s390x
# https://hub.docker.com/r/amd64/alpine/
# https://hub.docker.com/r/arm32v6/alpine/
# https://hub.docker.com/r/arm32v7/alpine/
# https://hub.docker.com/r/arm64v8/alpine/
# https://hub.docker.com/r/i386/alpine/
# https://hub.docker.com/r/ppc64le/alpine/
# https://hub.docker.com/r/s390x/alpine/

DOCKER_REPO := klutchell/unbound
ARCH := amd64
TAG := 1.9.3
BUILD_OPTIONS +=

BUILD_DATE := $(strip $(shell docker run --rm busybox date -u +'%Y-%m-%dT%H:%M:%SZ'))
BUILD_VERSION := $(strip $(shell git describe --tags --always --dirty))
VCS_REF := $(strip $(shell git rev-parse HEAD))

.EXPORT_ALL_VARIABLES:

.DEFAULT_GOAL := test

.PHONY: build test push clean all build-all test-all push-all clean-all manifest help

build: qemu-user-static ## Build an image with the provided ARCH and TAG
	docker build ${BUILD_OPTIONS} \
		--build-arg ARCH \
		--build-arg BUILD_VERSION \
		--build-arg BUILD_DATE \
		--build-arg VCS_REF \
		--tag ${DOCKER_REPO}:${ARCH}-${TAG} .

test: build ## Build and test an image with the provided ARCH and TAG
	docker run --rm ${DOCKER_REPO}:${ARCH}-${TAG} /test.sh

push: test ## Build, test, and push an image with the provided ARCH and TAG (requires docker login)
	docker push ${DOCKER_REPO}:${ARCH}-${TAG}

clean: ## Remove cached images with the provided ARCH and TAG
	-docker image rm ${DOCKER_REPO}:${ARCH}-${TAG}

all: test-all

build-all: ## Build images for all supported architectures
	make build ARCH=amd64
	make build ARCH=arm32v6
	make build ARCH=arm32v7
	make build ARCH=arm64v8
	make build ARCH=i386
	make build ARCH=ppc64le
	make build ARCH=s390x

test-all: ## Build and test images for all supported architectures
	make test ARCH=amd64
	make test ARCH=arm32v6
	make test ARCH=arm32v7
	make test ARCH=arm64v8
	make test ARCH=i386
	make test ARCH=ppc64le
	make test ARCH=s390x

push-all: ## Build, test, and push images for all supported architectures (requires docker login)
	make push ARCH=amd64
	make push ARCH=arm32v6
	make push ARCH=arm32v7
	make push ARCH=arm64v8
	make push ARCH=i386
	make push ARCH=ppc64le
	make push ARCH=s390x

clean-all: ## Clean images for all supported architectures
	make clean ARCH=amd64
	make clean ARCH=arm32v6
	make clean ARCH=arm32v7
	make clean ARCH=arm64v8
	make clean ARCH=i386
	make clean ARCH=ppc64le
	make clean ARCH=s390x

manifest: ## Create and push a multiarch manifest to the docker repo (requires docker login)
	-docker manifest push --purge ${DOCKER_REPO}:${TAG}
	docker manifest create ${DOCKER_REPO}:${TAG} \
		${DOCKER_REPO}:amd64-${TAG} \
		${DOCKER_REPO}:arm32v6-${TAG} \
		${DOCKER_REPO}:arm32v7-${TAG} \
		${DOCKER_REPO}:arm64v8-${TAG} \
		${DOCKER_REPO}:i386-${TAG} \
		${DOCKER_REPO}:ppc64le-${TAG} \
		${DOCKER_REPO}:s390x-${TAG}
	docker manifest annotate ${DOCKER_REPO}:${TAG} ${DOCKER_REPO}:amd64-${TAG} --os linux --arch amd64
	docker manifest annotate ${DOCKER_REPO}:${TAG} ${DOCKER_REPO}:arm32v6-${TAG} --os linux --arch arm --variant v6
	docker manifest annotate ${DOCKER_REPO}:${TAG} ${DOCKER_REPO}:arm32v7-${TAG} --os linux --arch arm --variant v7
	docker manifest annotate ${DOCKER_REPO}:${TAG} ${DOCKER_REPO}:arm64v8-${TAG} --os linux --arch arm64 --variant v8
	docker manifest annotate ${DOCKER_REPO}:${TAG} ${DOCKER_REPO}:i386-${TAG} --os linux --arch 386
	docker manifest annotate ${DOCKER_REPO}:${TAG} ${DOCKER_REPO}:ppc64le-${TAG} --os linux --arch ppc64le
	docker manifest annotate ${DOCKER_REPO}:${TAG} ${DOCKER_REPO}:s390x-${TAG} --os linux --arch s390x
	docker manifest push --purge ${DOCKER_REPO}:${TAG}

qemu-user-static:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

help: ## Display available commands
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
