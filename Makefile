
DOCKER_REPO		:= klutchell/unbound
ARCH			:= amd64	# amd64 | armv7hf

DOCKERFILE_PATH	:= Dockerfile.${ARCH}
BUILD_VERSION	:= $$(git describe --tags --long --dirty --always)
IMAGE_NAME		:= ${DOCKER_REPO}:${ARCH}-${BUILD_VERSION}

.DEFAULT_GOAL	:= build

tag:
	@git tag -a ${BUILD_VERSION} -m "build version ${BUILD_VERSION}"
	@git push --tags

build:
	IMAGE_NAME=${IMAGE_NAME} DOCKERFILE_PATH=${DOCKERFILE_PATH} ./hooks/build
	@docker tag "${IMAGE_NAME}" "${DOCKER_REPO}:${ARCH}"

build-nc:
	IMAGE_NAME=${IMAGE_NAME} DOCKERFILE_PATH=${DOCKERFILE_PATH} ./hooks/build --no-cache
	@docker tag "${IMAGE_NAME}" "${DOCKER_REPO}:${ARCH}"

test:
	@docker-compose -f docker-compose.test.yml -p ci up --build --abort-on-container-exit

push:
	@docker push ${IMAGE_NAME}
	IMAGE_NAME=${IMAGE_NAME} ./hooks/post_push

release:	build push