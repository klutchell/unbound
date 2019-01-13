
DOCKER_REPO		:= klutchell/unbound
ARCH			:= amd64
BUMP            := patch

BUILD_VERSION	:= $$(git describe --tags --long --dirty --always)
BUILD_DATE		:= $$(date -u +"%Y-%m-%dT%H:%M:%SZ")
NEXT_VERSION    := $$(docker run --rm treeder/bump --input "$$(git describe --tags)" ${BUMP})

IMAGE_NAME      := ${DOCKER_REPO}:${ARCH}-${BUILD_VERSION}
LATEST_NAME     := ${DOCKER_REPO}:${ARCH}-latest
DOCKERFILE_PATH := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/Dockerfile.${ARCH}

.DEFAULT_GOAL	:= build

tag:
	@git tag -a ${NEXT_VERSION} -m "version ${NEXT_VERSION}"
	@git push --tags

build:
	BUILD_VERSION=${BUILD_VERSION} BUILD_DATE=${BUILD_DATE} IMAGE_NAME=${IMAGE_NAME} DOCKERFILE_PATH=${DOCKERFILE_PATH} ./hooks/build
	@docker tag ${IMAGE_NAME} ${LATEST_NAME}

build-nc:
	BUILD_VERSION=${BUILD_VERSION} BUILD_DATE=${BUILD_DATE} IMAGE_NAME=${IMAGE_NAME} DOCKERFILE_PATH=${DOCKERFILE_PATH} ./hooks/build --no-cache
	@docker tag ${IMAGE_NAME} ${LATEST_NAME}

push:
	@docker push ${IMAGE_NAME}

release:	build push

