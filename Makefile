
DOCKER_REPO		:= klutchell/unbound
ARCH			:= amd64
BUILD_OPTS		:=

DOCKERFILE_PATH	:= Dockerfile.${ARCH}

# run date command in a linux container to remain host-agnostic
BUILD_DATE		:= $(strip $(shell docker run --rm alpine date -u +'%Y-%m-%dT%H:%M:%SZ'))
VCS_REF			:= $(strip $(shell git describe --all --long --dirty --always))
VCS_BRANCH		:= $(strip $(shell git rev-parse --abbrev-ref HEAD))

# for local builds the docker tag should be {repo}:{version}-{arch}
DOCKER_TAG	:= ${DOCKER_REPO}:${VCS_BRANCH}-${ARCH}

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
##     - build image locally from source
## Usage:
##     - make build [ARCH=] [BUILD_OPTS=]
## Commands:
##     - docker build
## Examples:
##     - make build
##     - make build ARCH=armv7hf
##     - make build BUILD_OPTS=--no-cache
##
.PHONY: build
build:
	docker build ${BUILD_OPTS} \
	--build-arg BUILD_DATE=${BUILD_DATE} \
	--build-arg VCS_REF=${VCS_REF} \
	--file ${DOCKERFILE_PATH} \
	--tag ${DOCKER_TAG} \
	.

## Description:
##     - push local image to docker repo
##       (requires "make build" and "docker login" prior to running)
## Usage:
##     - make push [ARCH=]
## Commands:
##     - docker push
## Examples:
##     - make push
##     - make push ARCH=armv7hf
##
.PHONY: push
push:
ifneq "${VCS_BRANCH}" "dev"
	$(error Push disabled from ${VCS_BRANCH} branch)
endif
	docker push ${DOCKER_TAG}

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