
DOCKER_REPO		:= klutchell/unbound
ARCH			:= amd64	# amd64 | armv7hf

DOCKERFILE_PATH	:= Dockerfile.${ARCH}

BUILD_VERSION	:= $$(git describe --tags --long --dirty --always)
UNBOUND_VERSION	:= $$(sed -r -n -e 's/ENV UNBOUND_VERSION="(.+)"/\1/p' ${DOCKERFILE_PATH})
REVISION		:= $$(git rev-list ${UNBOUND_VERSION}.. --count)

DOCKER_TAG		:= ${ARCH}-${UNBOUND_VERSION}-${REVISION}
IMAGE_NAME		:= ${DOCKER_REPO}:${DOCKER_TAG}

.DEFAULT_GOAL	:= build

tag:
	@git tag -a ${DOCKER_TAG} -m "tagging version ${DOCKER_TAG}"
	@git push --tags

build:
	IMAGE_NAME=${IMAGE_NAME} DOCKERFILE_PATH=${DOCKERFILE_PATH} ./hooks/build

build-nc:
	IMAGE_NAME=${IMAGE_NAME} DOCKERFILE_PATH=${DOCKERFILE_PATH} ./hooks/build --no-cache

test:
	@docker-compose -f docker-compose.test.yml -p ci up --build --abort-on-container-exit

push:
	@docker push ${IMAGE_NAME}
	IMAGE_NAME=${IMAGE_NAME} DOCKER_REPO=${DOCKER_REPO} DOCKER_TAG=${DOCKER_TAG} ./hooks/post_push

release:	build push