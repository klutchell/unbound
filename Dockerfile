ARG ARCH=amd64
ARG QEMU_BINARY=qemu-x86_64-static

FROM multiarch/qemu-user-static:4.1.0-1 as qemu

# ----------------------------------------------------------------------------

FROM ${ARCH}/alpine:3.10.2 as openssl

ENV OPENSSL_VERSION="1.1.1d"
ENV OPENSSL_SHA="056057782325134b76d1931c48f2c7e6595d7ef4"

COPY --from=qemu /usr/bin/${QEMU_BINARY} /usr/bin/

WORKDIR /tmp/src

# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache build-base=0.5-r1 curl=7.66.0-r0 linux-headers=4.19.36-r0 perl=5.28.2-r1 \
	&& curl -fsSL https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz -o openssl.tar.gz \
	&& echo "${OPENSSL_SHA}  ./openssl.tar.gz" | sha1sum -c - \
	&& tar xzf openssl.tar.gz
	
WORKDIR /tmp/src/openssl-${OPENSSL_VERSION}

RUN ./config --prefix=/opt/openssl no-weak-ssl-ciphers no-ssl3 no-shared -DOPENSSL_NO_HEARTBEATS -fstack-protector-strong \
    && make depend -j$(getconf _NPROCESSORS_ONLN) \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install_sw \
	&& rm -rf /tmp/*

# ----------------------------------------------------------------------------

FROM ${ARCH}/alpine:3.10.2 as unbound

ENV UNBOUND_VERSION="1.9.3"
ENV UNBOUND_SHA="cc3081c042511468177e36897f0c7f0a155493fa"

COPY --from=openssl /usr/bin/qemu-* /usr/bin/
COPY --from=openssl /opt/openssl /opt/openssl

WORKDIR /tmp/src

# https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache build-base=0.5-r1 curl=7.66.0-r0 linux-headers=4.19.36-r0 libevent=2.1.10-r0 libevent-dev=2.1.10-r0 expat=2.2.8-r0 expat-dev=2.2.8-r0 \
	&& curl -fsSL https://www.unbound.net/downloads/unbound-${UNBOUND_VERSION}.tar.gz -o unbound.tar.gz \
	&& echo "${UNBOUND_SHA}  ./unbound.tar.gz" | sha1sum -c - \
	&& tar xzf unbound.tar.gz

WORKDIR /tmp/src/unbound-${UNBOUND_VERSION}

RUN addgroup _unbound && adduser -D -H -s /etc -h /dev/null -G _unbound _unbound \
	&& ./configure --prefix=/opt/unbound --with-pthreads --with-username=_unbound --with-ssl=/opt/openssl --with-libevent --enable-event-api --disable-flto \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
	&& rm -rf /opt/unbound/share \
	&& rm -rf /tmp/* \
	&& echo 'include: /opt/unbound/etc/unbound/conf.d/*.conf' >> /opt/unbound/etc/unbound/unbound.conf

# ----------------------------------------------------------------------------

FROM ${ARCH}/alpine:3.10.2

ARG BUILD_DATE
ARG BUILD_VERSION
ARG VCS_REF

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

COPY --from=unbound /usr/bin/qemu-* /usr/bin/
COPY --from=unbound /opt/ /opt/

WORKDIR /opt/unbound/etc/unbound/conf.d/

COPY a-records.conf default.conf ./
COPY start.sh test.sh /

RUN apk add --no-cache libevent=2.1.10-r0 expat=2.2.8-r0 curl=7.66.0-r0 drill=1.7.0-r2 \
	&& addgroup _unbound && adduser -D -H -s /etc -h /dev/null -G _unbound _unbound \
	&& chmod +x /start.sh /test.sh

WORKDIR /opt/unbound/

ENV PATH /opt/unbound/sbin:"$PATH"

EXPOSE 53

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s CMD drill @127.0.0.1 cloudflare.com || exit 1

CMD ["/start.sh"]