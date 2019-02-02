#!/bin/sh

apk add git >/dev/null

DOCKERFILE_PATH=${1:-"Dockerfile.amd64"}
UNBOUND_VERSION=$(sed -r -n 's/ENV UNBOUND_VERSION="(.+)"/\1/p' ${DOCKERFILE_PATH})
LAST_TAG=$(git describe --match "${UNBOUND_VERSION}-*" --abbrev=0)

if [ -n "${LAST_TAG}" ]
then
	NEW_TAG=${UNBOUND_VERSION}-$(( ${LAST_TAG##*-} + 1 ))
else
	NEW_TAG=${UNBOUND_VERSION}-1
fi

echo "${NEW_TAG}"
