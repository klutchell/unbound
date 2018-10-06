
DOCKER_REPO		:= klutchell/unbound
BUILD_VERSION	:= $$(git describe --tags --long --dirty --always)
BUILD_DATE		:= $$(date -u +"%Y-%m-%dT%H:%M:%SZ")

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

tag:	tag-patch

build:
	BUILD_VERSION=${BUILD_VERSION} BUILD_DATE=${BUILD_DATE} IMAGE_NAME=${DOCKER_REPO}:${BUILD_VERSION} DOCKERFILE_PATH=Dockerfile ./hooks/build
	@docker tag ${DOCKER_REPO}:${BUILD_VERSION} ${DOCKER_REPO}:latest

build-nc:
	BUILD_VERSION=${BUILD_VERSION} BUILD_DATE=${BUILD_DATE} IMAGE_NAME=${DOCKER_REPO}:${BUILD_VERSION} DOCKERFILE_PATH=Dockerfile ./hooks/build --no-cache
	@docker tag ${DOCKER_REPO}:${BUILD_VERSION} ${DOCKER_REPO}:latest

build-armhf:
	BUILD_VERSION=${BUILD_VERSION} BUILD_DATE=${BUILD_DATE} IMAGE_NAME=${DOCKER_REPO}:armhf-${BUILD_VERSION} DOCKERFILE_PATH=Dockerfile.armhf ./hooks/build
	@docker tag ${DOCKER_REPO}:armhf-${BUILD_VERSION} ${DOCKER_REPO}:armhf-latest

build-armhf-nc:
	BUILD_VERSION=${BUILD_VERSION} BUILD_DATE=${BUILD_DATE} IMAGE_NAME=${DOCKER_REPO}:armhf-${BUILD_VERSION} DOCKERFILE_PATH=Dockerfile.armhf ./hooks/build --no-cache
	@docker tag ${DOCKER_REPO}:armhf-${BUILD_VERSION} ${DOCKER_REPO}:armhf-latest

push:
	@docker push ${DOCKER_REPO}:${BUILD_VERSION}

push-armhf:
	@docker push ${DOCKER_REPO}:armhf-${BUILD_VERSION}

release:		build push

release-armhf:	build-armhf push-armhf

armhf:			build-armhf

