
DOCKER_REPO		:= klutchell/unbound
ARCH			:= amd64

BUILD_VERSION	:= $$(git describe --tags --long --dirty --always)
BUILD_DATE		:= $$(date -u +"%Y-%m-%dT%H:%M:%SZ")

IMAGE_NAME      := ${DOCKER_REPO}:${ARCH}-${BUILD_VERSION}
LATEST_NAME     := ${DOCKER_REPO}:${ARCH}-latest
DOCKERFILE_PATH := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/Dockerfile.${ARCH}

.DEFAULT_GOAL	:= build

tag-major: VERSION	:= $$(docker run --rm treeder/bump --input "$$(git describe --tags)" major)
tag-major:
	@git tag -a ${VERSION} -m "version ${VERSION}"
	@git push --tags

tag-minor: VERSION	:= $$(docker run --rm treeder/bump --input "$$(git describe --tags)" minor)
tag-minor:
	@git tag -a ${VERSION} -m "version ${VERSION}"
	@git push --tags

tag-patch: VERSION	:= $$(docker run --rm treeder/bump --input "$$(git describe --tags)" patch)
tag-patch:
	@git tag -a ${VERSION} -m "version ${VERSION}"
	@git push --tags

build:
	BUILD_VERSION=${BUILD_VERSION} BUILD_DATE=${BUILD_DATE} IMAGE_NAME=${IMAGE_NAME} DOCKERFILE_PATH=${DOCKERFILE_PATH} ./hooks/build
	@docker tag ${IMAGE_NAME} ${LATEST_NAME}

build-nc:
	BUILD_VERSION=${BUILD_VERSION} BUILD_DATE=${BUILD_DATE} IMAGE_NAME=${IMAGE_NAME} DOCKERFILE_PATH=${DOCKERFILE_PATH} ./hooks/build --no-cache
	@docker tag ${IMAGE_NAME} ${LATEST_NAME}

push:
	@docker push ${IMAGE_NAME}

tag:		tag-patch

release:	build push

