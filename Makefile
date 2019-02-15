# variables are exported for all subprocesses
# override variables at runtime as needed
# eg. make build ARCH=arm BUILD_OPTIONS=--no-cache

.EXPORT_ALL_VARIABLES:

# used by all targets
ARCH := amd64

# used by build target only
BUILD_LABEL := $(strip $(shell git describe --dirty --always))
BUILD_DATE := $(strip $(shell busybox date -u +'%Y-%m-%dT%H:%M:%SZ'))
VCS_REF := $(strip $(shell git rev-parse --short HEAD))

# set these vars in compose_options in case docker-compose is executed in a container
COMPOSE_OPTIONS += -e ARCH -e BUILD_DATE -e BUILD_LABEL -e VCS_REF
BUILD_OPTIONS +=

.DEFAULT_GOAL := build

# create dockerfile.arch by substituting the FROM multiarch image
# supported FROM images can be found here: https://hub.docker.com/r/multiarch/alpine/tags
# supported ARCH labels be found here: https://golang.org/doc/install/source#environment

MULTIARCH_amd64 := multiarch/alpine:amd64-v3.9
MULTIARCH_arm := multiarch/alpine:armhf-v3.9
MULTIARCH_arm64 := multiarch/alpine:aarch64-v3.9

.PHONY: Dockerfile.${ARCH}
Dockerfile.${ARCH}: Dockerfile
	sed -r "s|FROM .+|FROM ${MULTIARCH_${ARCH}}|g" Dockerfile > Dockerfile.${ARCH}

.PHONY: qemu-user-static
qemu-user-static:
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

.PHONY: build
build: Dockerfile.${ARCH} qemu-user-static
	docker-compose -f docker-compose.ci.yml -p ci build ${BUILD_OPTIONS} unbound

.PHONY: test
test: Dockerfile.${ARCH} qemu-user-static
	docker-compose -f docker-compose.ci.yml -p ci up --build --abort-on-container-exit

.PHONY: push
push: Dockerfile.${ARCH} qemu-user-static
	docker-compose -f docker-compose.ci.yml -p ci push unbound

.PHONY: manifest
manifest:
	manifest-tool push from-spec manifest.yml

.PHONY: lint
lint:
	docker-compose -f docker-compose.ci.yml -p ci config
	travis lint .travis.yml

.PHONY: release
release: build test push
