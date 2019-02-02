
DOCKER_REPO		:= klutchell/unbound
ARCH			:= amd64
BUILD_OPTS		:=

# eg. make ARCH=armv7hf BUILD_OPTS=--no-cache

DOCKERFILE_PATH	:= Dockerfile.${ARCH}

BUILD_DATE		:= $(shell docker run --rm alpine date -u +'%Y-%m-%dT%H:%M:%SZ')
BUILD_VERSION	:= $(shell docker run --rm -w /app -v ${CURDIR}:/app alpine /app/utils/bump.sh ${DOCKERFILE_PATH})
APP_VERSION		:= $(shell echo ${BUILD_VERSION} | sed -r "s/(.+)-[0-9]+/\1/")
VCS_REF			:= $(shell git describe --tags --long --dirty --always)

DOCKER_TAG		:= ${ARCH}-${BUILD_VERSION}
IMAGE_NAME		:= ${DOCKER_REPO}:${DOCKER_TAG}

.DEFAULT_GOAL	:= build

tag:
	git fetch --tags
	git tag -a "${BUILD_VERSION}" -m "tagging release ${BUILD_VERSION}"
	git push --tags

build:
	docker build ${BUILD_OPTS} \
	--build-arg BUILD_DATE=${BUILD_DATE} \
	--build-arg BUILD_VERSION=${BUILD_VERSION} \
	--build-arg VCS_REF=${VCS_REF} \
	--file ${DOCKERFILE_PATH} \
	--tag ${IMAGE_NAME} \
	.
	docker tag ${IMAGE_NAME} ${DOCKER_REPO}:${ARCH}
	docker tag ${IMAGE_NAME} ${DOCKER_REPO}:${ARCH}-${APP_VERSION}

test:
	docker-compose -f docker-compose.test.yml -p ci up --build --abort-on-container-exit

push:
	docker push ${IMAGE_NAME}
	docker push ${DOCKER_REPO}:${ARCH}
	docker push ${DOCKER_REPO}:${ARCH}-${APP_VERSION}
ifeq "${ARCH}" "amd64"
	docker push ${DOCKER_REPO}:latest
endif

release:	build push