
DOCKER_REPO		:= klutchell/unbound
ARCH			:= amd64    # amd64 | armv7hf
BUMP            := patch    # patch | minor | major

DOCKERFILE_PATH := Dockerfile.${ARCH}
IMAGE_NAME      := ${DOCKER_REPO}:${ARCH}
NEXT_VERSION    := $$(docker run --rm treeder/bump --input "$$(git describe --tags)" ${BUMP})

.DEFAULT_GOAL	:= build

tag:
	@git tag -a ${NEXT_VERSION} -m "version ${NEXT_VERSION}"
	@git push --tags

build:
	IMAGE_NAME=${IMAGE_NAME} DOCKERFILE_PATH=${DOCKERFILE_PATH} ./hooks/build

build-nc:
	IMAGE_NAME=${IMAGE_NAME} DOCKERFILE_PATH=${DOCKERFILE_PATH} ./hooks/build --no-cache

push:
	@docker push ${IMAGE_NAME}

release:	build push

