FROM debian:10 as builder

ARG UNBOUND_VERSION="1.9.4"
ARG UNBOUND_SHA="364724dc2fe73cb7b45feeabdbfdff02271c5df7"
ARG UNBOUND_URL="https://www.unbound.net/downloads/unbound-${UNBOUND_VERSION}.tar.gz"

WORKDIR /tmp/src

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -qq --no-install-recommends \
	build-essential=12.6 \
	ca-certificates=20190110 \
	curl=7.64.0-4 \
	libexpat1-dev=2.2.6-2+deb10u1 \
	libevent-dev=2.1.8-stable-4 \
	libssl-dev=1.1.1d-0+deb10u2 \
	&& c_rehash \
	&& curl -fsSL "${UNBOUND_URL}" -o /tmp/unbound.tar.gz \
	&& echo "${UNBOUND_SHA}  /tmp/unbound.tar.gz" | sha1sum -c - \
	&& tar xzf /tmp/unbound.tar.gz --strip 1 \
	&& ./configure --with-pthreads --with-libevent --enable-event-api --disable-flto --disable-static --with-run-dir=/usr/local/run --with-username= --with-chroot-dir= \
	&& make install \
	&& ldconfig -p | awk '{ print $4 }' | grep -e "libexpat.so.1" -e "libevent-2.1.so.6" -e "libssl.so.1.1" | xargs cp -Lvt /usr/local/lib/ \
	&& mv /usr/local/etc/unbound/unbound.conf /usr/local/etc/unbound/example.conf \
	&& mkdir /usr/local/run

# ----------------------------------------------------------------------------

FROM gcr.io/distroless/base-debian10:nonroot

ARG BUILD_DATE
ARG BUILD_VERSION
ARG VCS_REF

LABEL maintainer="Kyle Harding <https://klutchell.dev>"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="klutchell/unbound"
LABEL org.label-schema.description="Unbound is a validating, recursive, caching DNS resolver"
LABEL org.label-schema.url="https://unbound.net/"
LABEL org.label-schema.vcs-url="https://github.com/klutchell/unbound"
LABEL org.label-schema.docker.cmd="docker run --rm klutchell/unbound -h"
LABEL org.label-schema.build-date="${BUILD_DATE}"
LABEL org.label-schema.version="${BUILD_VERSION}"
LABEL org.label-schema.vcs-ref="${VCS_REF}"

COPY --from=builder /usr/local/etc /usr/local/etc
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/sbin /usr/local/sbin
COPY --from=builder --chown=nonroot /usr/local/run /usr/local/run

COPY a-records.conf unbound.conf /usr/local/etc/unbound/

WORKDIR /usr/local/run

ENV LD_LIBRARY_PATH=/usr/local/lib

ENTRYPOINT ["unbound", "-d"]
