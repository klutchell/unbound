FROM alpine:3.10 as builder

ARG UNBOUND_VERSION="1.9.4"
ARG UNBOUND_SHA="364724dc2fe73cb7b45feeabdbfdff02271c5df7"

WORKDIR /tmp/src

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache build-base=0.5-r1 curl=7.66.0-r0 expat=2.2.8-r0 expat-dev=2.2.8-r0 libevent=2.1.10-r0 libevent-dev=2.1.10-r0 linux-headers=4.19.36-r0 openssl=1.1.1d-r0 openssl-dev=1.1.1d-r0 \
	&& curl -fsSL https://www.unbound.net/downloads/unbound-${UNBOUND_VERSION}.tar.gz -o /tmp/unbound.tar.gz \
	&& echo "${UNBOUND_SHA}  /tmp/unbound.tar.gz" | sha1sum -c - && tar xzf /tmp/unbound.tar.gz --strip 1 \
	&& ./configure --prefix=/app --with-pthreads  --with-libevent --enable-event-api --disable-flto --disable-static --with-run-dir=/app/var \
	&& make install && mv /app/etc/unbound/unbound.conf /app/etc/unbound/example.conf && rm -rf /app/share /app/include

RUN ./configure --help

# ----------------------------------------------------------------------------

FROM alpine:3.10

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

COPY --from=builder /app /app

COPY a-records.conf unbound.conf /app/etc/unbound/

WORKDIR /app/var

RUN apk add --no-cache ca-certificates=20190108-r0 drill=1.7.0-r2 expat=2.2.8-r0 libevent=2.1.10-r0 openssl=1.1.1d-r0 tzdata=2019c-r0 \
	&& addgroup unbound && adduser -D -H -s /etc -h /dev/null -G unbound unbound

ENV PATH /app/sbin:"$PATH"

ENTRYPOINT ["unbound"]

CMD ["-d"]