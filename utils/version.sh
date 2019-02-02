#!/bin/sh

apk add --no-cache git >/dev/null

DOCKERFILE_PATH=${1:-"Dockerfile.amd64"}
UNBOUND_VERSION=$(sed -r -n 's/ENV UNBOUND_VERSION="(.+)"/\1/p' "${DOCKERFILE_PATH}")
LAST_TAG=$(git describe --match "${UNBOUND_VERSION}-*" --abbrev=0)

case ${LAST_TAG##*-} in
	''|*[!0-9]*) NEW_TAG=${UNBOUND_VERSION}-1 ;;
	*) NEW_TAG=${UNBOUND_VERSION}-$(( ${LAST_TAG##*-} + 1 )) ;;
esac

echo "${NEW_TAG}"
