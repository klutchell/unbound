
DOCKER_REPO		:= klutchell/unbound
ARCH			:= amd64

DOCKERFILE_PATH	:= Dockerfile.${ARCH}

APP_VERSION		:= $$(sed -r -n -e 's/ENV UNBOUND_VERSION="(.+)"/\1/p' ${DOCKERFILE_PATH})
VCS_REF			:= $$(git rev-parse --short HEAD)

DOCKER_TAG		:= ${ARCH}-${UNBOUND_VERSION}-${VCS_REF}
IMAGE_NAME		:= ${DOCKER_REPO}:${DOCKER_TAG}

.DEFAULT_GOAL	:= build

tag:
	@git tag -a ${DOCKER_TAG} -m "tagging release ${DOCKER_TAG}"
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