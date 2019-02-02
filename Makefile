
DOCKER_REPO		:= klutchell/unbound
ARCH			:= amd64
BUILD_OPTS		:=

DOCKERFILE_PATH	:= Dockerfile.${ARCH}

# run date command in an alpine linux container to remain host-agnostic
BUILD_DATE		:= $(strip $(shell docker run --rm alpine date -u +'%Y-%m-%dT%H:%M:%SZ'))

# run this shell script in an alpine linux container to remain host-agnostic
# automatic docker builds will use the latest git tag but since we are
# running locally we need to increment the revision by one and this script will do just that
BUILD_VERSION	:= $(strip $(shell docker run --rm -w /app -v ${CURDIR}:/app alpine /app/utils/bump.sh ${DOCKERFILE_PATH}))

# remove the build revision to get just the app version
APP_VERSION		:= $(strip $(shell echo ${BUILD_VERSION} | sed -r "s/(.+)-[0-9]+/\1/"))

# remove the app version to get just the build revision
REVISION		:= $(strip $(shell echo ${BUILD_VERSION} | sed -r "s/.+-([0-9]+)/\1/"))

# use the raw git state including tag, commits, hash, and dirty flag
VCS_REF			:= $(strip $(shell git describe --tags --long --dirty --always))

# create multiple docker tags per image
DOCKER_TAG_1	:= ${DOCKER_REPO}:${ARCH}-${APP_VERSION}-$(REVISION)
DOCKER_TAG_2	:= ${DOCKER_REPO}:${ARCH}-${APP_VERSION}
DOCKER_TAG_3	:= ${DOCKER_REPO}:${ARCH}

.DEFAULT_GOAL	:= help

## -- Usage --

## Display this help message
##
.PHONY: help
help:	# https://gist.github.com/prwhite/8168133
	@awk '{ \
			if ($$0 ~ /^.PHONY: [a-zA-Z\-\_0-9]+$$/) { \
				helpCommand = substr($$0, index($$0, ":") + 2); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^[a-zA-Z\-\_0-9.]+:/) { \
				helpCommand = substr($$0, 0, index($$0, ":")); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^##/) { \
				if (helpMessage) { \
					helpMessage = helpMessage"\n                     "substr($$0, 3); \
				} else { \
					helpMessage = substr($$0, 3); \
				} \
			} else { \
				if (helpMessage) { \
					print "\n                     "helpMessage"\n" \
				} \
				helpMessage = ""; \
			} \
		}' \
		$(MAKEFILE_LIST)

## Description:
##     - build image locally from source and create multiple docker tags
## Usage:
##     - make build [ARCH=] [BUILD_OPTS=]
## Commands:
##     - docker build
##     - docker tag
## Examples:
##     - make build
##     - make build ARCH=armv7hf
##     - make build BUILD_OPTS=--no-cache
## Tags:
##     - {repo}:{arch}
##     - {repo}:{arch}-{appversion}
##     - {repo}:{arch}-{appversion}-{revision}
##
.PHONY: build
build:
	docker build ${BUILD_OPTS} \
	--build-arg BUILD_DATE=${BUILD_DATE} \
	--build-arg BUILD_VERSION=${BUILD_VERSION} \
	--build-arg VCS_REF=${VCS_REF} \
	--file ${DOCKERFILE_PATH} \
	--tag ${DOCKER_TAG_1} \
	.
	docker tag ${DOCKER_TAG_1} ${DOCKER_TAG_2}
	docker tag ${DOCKER_TAG_1} ${DOCKER_TAG_3}

## Description:
##     - push existing tagged images to docker repo
##       (requires "make build" and "docker login" prior to running)
## Usage:
##     - make push [ARCH=]
## Commands:
##     - docker push
## Examples:
##     - make push
##     - make push ARCH=armv7hf
## Tags:
##     - {repo}:{arch}
##     - {repo}:{arch}-{appversion}
##     - {repo}:{arch}-{appversion}-{revision}
##
.PHONY: push
push:
	docker push ${DOCKER_TAG_1}
	docker push ${DOCKER_TAG_2}
	docker push ${DOCKER_TAG_3}
ifeq "${ARCH}" "amd64"
	docker push ${DOCKER_REPO}:latest
endif

## Description:
##     - run unit and integration tests to validate DNSSEC
##       (amd64 only for now)
## Usage:
##     - make test
## Commands:
##     - docker-compose
## Examples:
##     - make test
##
.PHONY: test
test:
	docker-compose -f docker-compose.test.yml -p ci up --build --abort-on-container-exit

## Description:
##     - add and push new git tag with app version and new build revision
## Usage:
##     - make tag [ARCH=]
## Commands:
##     - git fetch
##     - git tag
##     - git push
## Examples:
##     - make tag
##     - make tag ARCH=armv7hf
## Tags:
##     - {appversion}-{revision + 1}
##
.PHONY: tag
tag:
	git fetch --tags
	git tag -a "${BUILD_VERSION}" -m "tagging release ${BUILD_VERSION}"
	git push --tags

## Description:
##     - build image locally and push to docker repo in one step
## Usage:
##     - make release [ARCH=] [BUILD_OPTS=]
## Commands:
##     - make build
##     - make push
## Examples:
##     - make release
##     - make release ARCH=armv7hf
##     - make release BUILD_OPTS=--no-cache
##
.PHONY: release
release:	build push