
ARG ARCH=amd64

# ----------------------------------------------------------------------------

FROM ${ARCH}/alpine:3.10.2 as unbound

WORKDIR /tmp/src

ENV UNBOUND_VERSION="1.9.3"
ENV UNBOUND_SHA="cc3081c042511468177e36897f0c7f0a155493fa"

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache build-base=0.5-r1 curl=7.66.0-r0 expat=2.2.8-r0 expat-dev=2.2.8-r0 libevent=2.1.10-r0 libevent-dev=2.1.10-r0 libressl=2.7.5-r0 libressl-dev=2.7.5-r0 linux-headers=4.19.36-r0 \
	&& curl -fsSL https://www.unbound.net/downloads/unbound-${UNBOUND_VERSION}.tar.gz -o unbound.tar.gz \
	&& echo "${UNBOUND_SHA}  ./unbound.tar.gz" | sha1sum -c - \
	&& tar xzf unbound.tar.gz

WORKDIR /tmp/src/unbound-${UNBOUND_VERSION}

RUN addgroup _unbound && adduser -D -H -s /etc -h /dev/null -G _unbound _unbound \
	&& ./configure --prefix=/opt/unbound --with-pthreads --with-username=_unbound --with-libevent --enable-event-api --disable-flto \
	&& make install \
	&& rm -rf /opt/unbound/share /opt/unbound/include

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
LABEL org.label-schema.docker.cmd="docker run -p 53:5053/udp klutchell/unbound"
LABEL org.label-schema.build-date="${BUILD_DATE}"
LABEL org.label-schema.version="${BUILD_VERSION}"
LABEL org.label-schema.vcs-ref="${VCS_REF}"

COPY --from=unbound /opt/ /opt/

COPY start.sh a-records.conf unbound.conf /

WORKDIR /opt/unbound/etc/unbound

RUN apk add --no-cache bind-tools=9.14.3-r0 expat=2.2.8-r0 curl=7.66.0-r0 libressl=2.7.5-r0 libevent=2.1.10-r0 \
	&& addgroup _unbound && adduser -D -H -s /etc -h /dev/null -G _unbound _unbound \
	&& mv unbound.conf /example.conf \
	&& chmod +x /start.sh \
	&& chmod -x /a-records.conf /unbound.conf

ENV PATH /opt/unbound/sbin:"$PATH"

EXPOSE 5053/udp

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s \
	CMD dig +short @127.0.0.1 -p 5053 cloudflare.com A || exit 1

CMD ["/start.sh"]