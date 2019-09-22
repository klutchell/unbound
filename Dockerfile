ARG ARCH=amd64

FROM multiarch/qemu-user-static:4.1.0-1 as qemu

# ----------------------------------------------------------------------------

FROM ${ARCH}/alpine:3.10.2 as unbound

COPY --from=qemu /usr/bin/qemu-* /usr/bin/

WORKDIR /tmp/src

ENV UNBOUND_VERSION="1.9.3"
ENV UNBOUND_SHA="cc3081c042511468177e36897f0c7f0a155493fa"

# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache build-base=0.5-r1 curl=7.66.0-r0 linux-headers=4.19.36-r0 libevent=2.1.10-r0 libevent-dev=2.1.10-r0 expat=2.2.8-r0 expat-dev=2.2.8-r0 openssl=1.1.1d-r0 openssl-dev=1.1.1d-r0 \
	&& curl -fsSL https://www.unbound.net/downloads/unbound-${UNBOUND_VERSION}.tar.gz -o unbound.tar.gz \
	&& echo "${UNBOUND_SHA}  ./unbound.tar.gz" | sha1sum -c - \
	&& tar xzf unbound.tar.gz && cd unbound-${UNBOUND_VERSION} \
	&& addgroup _unbound && adduser -D -H -s /etc -h /dev/null -G _unbound _unbound \
	&& ./configure --prefix=/opt/unbound --with-pthreads --with-username=_unbound --with-libevent --enable-event-api --disable-flto \
    && make install -j$(getconf _NPROCESSORS_ONLN) \
	&& rm -rf /opt/unbound/share && rm -rf /tmp/* && rm /usr/bin/qemu-*

# ----------------------------------------------------------------------------

FROM ${ARCH}/alpine:3.10.2

ARG BUILD_DATE
ARG BUILD_VERSION
ARG VCS_REF
ARG RM_QEMU=y

LABEL maintainer="Kyle Harding <https://klutchell.dev>"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="klutchell/unbound"
LABEL org.label-schema.description="Unbound is a validating, recursive, caching DNS resolver"
LABEL org.label-schema.url="https://unbound.net/"
LABEL org.label-schema.vcs-url="https://github.com/klutchell/unbound"
LABEL org.label-schema.docker.cmd="docker run -p 53:53/tcp -p 53:53/udp klutchell/unbound"
LABEL org.label-schema.build-date="${BUILD_DATE}"
LABEL org.label-schema.version="${BUILD_VERSION}"
LABEL org.label-schema.vcs-ref="${VCS_REF}"

WORKDIR /opt/unbound/

COPY --from=qemu /usr/bin/qemu-* /usr/bin/
COPY --from=unbound /opt/ /opt/

COPY start.sh test.sh a-records.conf unbound.conf /

RUN apk add --no-cache libevent=2.1.10-r0 expat=2.2.8-r0 curl=7.66.0-r0 openssl=1.1.1d-r0 drill=1.7.0-r2 \
	&& addgroup _unbound && adduser -D -H -s /etc -h /dev/null -G _unbound _unbound \
	&& mv /opt/unbound/etc/unbound/unbound.conf /example.conf \
	&& chmod +x /start.sh /test.sh \
	&& if [ "${RM_QEMU}" = "y" ]; then rm -v /usr/bin/qemu-*; fi

ENV PATH /opt/unbound/sbin:"$PATH"

EXPOSE 53/tcp 53/udp

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s CMD drill @127.0.0.1 cloudflare.com || exit 1

CMD ["/start.sh"]