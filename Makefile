
DOCKER_REPO		:= klutchell/unbound
ARCH			:= amd64

DOCKERFILE_PATH	:= Dockerfile.${ARCH}

BUILD_DATE		:= $(shell docker run --rm alpine date -u +'%Y-%m-%dT%H:%M:%SZ')
BUILD_VERSION	:= $(shell git describe --tags --abbrev=0)
VCS_REF			:= $(shell git describe --tags --long --dirty --always)

DOCKER_TAG		:= ${ARCH}-${BUILD_VERSION}
IMAGE_NAME		:= ${DOCKER_REPO}:${DOCKER_TAG}

UNBOUND_VERSION	:= $(shell sed -r -n 's/ENV UNBOUND_VERSION="(.+)"/\1/p' ${DOCKERFILE_PATH})

.DEFAULT_GOAL	:= build

tag:
	$(eval LOOKUP_TAG := $(shell git describe --match ${UNBOUND_VERSION}-[0-9] --abbrev=0))
ifeq (${LOOKUP_TAG},)
	$(eval GIT_TAG := ${UNBOUND_VERSION}-1)
else
	$(eval OLD_REV := $(shell echo ${LOOKUP_TAG} | sed -r 's/.+-([0-9]+)/\1/'))
	$(eval NEW_REV := $(shell docker run --rm alpine echo (( ${OLD_REV} + 1 )) ))
	$(eval GIT_TAG := ${NEW_REV}-1)
endif
	@echo ${GIT_TAG}
	@git tag -a ${GIT_TAG} -m "tagging release ${GIT_TAG}"

build:
	@docker build \
	--build-arg BUILD_DATE=${BUILD_DATE} \
	--build-arg BUILD_VERSION=${BUILD_VERSION} \
	--build-arg VCS_REF=${VCS_REF} \
	--file ${DOCKERFILE_PATH} \
	--tag ${IMAGE_NAME} \
	.
	docker tag ${IMAGE_NAME} ${DOCKER_REPO}:${ARCH}
	docker tag ${IMAGE_NAME} ${DOCKER_REPO}:${ARCH}-${UNBOUND_VERSION}

build-nc:
	@docker build --no-cache \
	--build-arg BUILD_DATE=${BUILD_DATE} \
	--build-arg BUILD_VERSION=${BUILD_VERSION} \
	--build-arg VCS_REF=${VCS_REF} \
	--file ${DOCKERFILE_PATH} \
	--tag ${IMAGE_NAME} \
	.
	@docker tag ${IMAGE_NAME} ${DOCKER_REPO}:${ARCH}
	@docker tag ${IMAGE_NAME} ${DOCKER_REPO}:${ARCH}-${UNBOUND_VERSION}

test:
	@docker-compose -f docker-compose.test.yml -p ci up --build --abort-on-container-exit

push:
	@docker push ${IMAGE_NAME}
	@docker push ${DOCKER_REPO}:${ARCH}
	@docker push ${DOCKER_REPO}:${ARCH}-${UNBOUND_VERSION}

release:	build push