#!/bin/sh

# for use with alpine linux only

# 1. install git
# 2. extract {appversion} from dockerfile
# 3. search for latest tag matching {appversion}-*
# 4. if matching tag was found and the last blob is a number: increase revision by one
# 5. else if matching tag was not found or the last blob is not a number: set the revision to one
# 6. return {appversion}-{revision}

apk add --no-cache git >/dev/null

DOCKERFILE_PATH=${1:-"Dockerfile.amd64"}
APP_VERSION=$(sed -r -n 's/ENV UNBOUND_VERSION="(.+)"/\1/p' "${DOCKERFILE_PATH}")
LAST_TAG=$(git describe --match "${APP_VERSION}-*" --abbrev=0)

case ${LAST_TAG##*-} in
	''|*[!0-9]*) REVISION=1 ;;
	*) REVISION=$(( ${LAST_TAG##*-} + 1 )) ;;
esac

echo "${APP_VERSION}-${REVISION}"
