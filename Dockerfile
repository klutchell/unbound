FROM buildpack-deps:buster-curl as builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -qq --no-install-recommends build-essential=12.6 file=1:5.35-4

WORKDIR /tmp/libevent

ARG LIBEVENT_VERSION=release-2.1.11-stable/libevent-2.1.11-stable
ARG LIBEVENT_SOURCE=https://github.com/libevent/libevent/releases/download/

RUN curl -L "${LIBEVENT_SOURCE}${LIBEVENT_VERSION}.tar.gz" -o /tmp/libevent.tar.gz \
	&& tar xzf /tmp/libevent.tar.gz --strip 1 \
	&& ./configure --prefix=/opt/libevent --disable-static \
	&& make \
	&& make install

WORKDIR /tmp/libexpat

ARG LIBEXPAT_VERSION=R_2_2_9/expat-2.2.9
ARG LIBEXPAT_SOURCE=https://github.com/libexpat/libexpat/releases/download/

RUN curl -L "${LIBEXPAT_SOURCE}${LIBEXPAT_VERSION}.tar.gz" -o /tmp/libexpat.tar.gz \
	&& tar xzf /tmp/libexpat.tar.gz --strip 1 \
	&& ./configure --prefix=/opt/libexpat --disable-static \
	&& make \
	&& make install

WORKDIR /tmp/ssl

ARG SSL_VERSION=openssl-1.1.1d
ARG SSL_SOURCE=https://www.openssl.org/source/
ARG SSL_SHA1=056057782325134b76d1931c48f2c7e6595d7ef4

RUN curl -L "${SSL_SOURCE}${SSL_VERSION}.tar.gz" -o /tmp/ssl.tar.gz \
	&& echo "${SSL_SHA1}  /tmp/ssl.tar.gz" | sha1sum -c - \
	&& tar xzf /tmp/ssl.tar.gz --strip 1 \
	&& ./config --prefix=/opt/ssl --openssldir=/opt/ssl no-weak-ssl-ciphers no-ssl3 no-heartbeats enable-ec_nistp_64_gcc_128 -fstack-protector-strong \
	&& make \
	&& make install_sw

WORKDIR /tmp/unbound

ARG UNBOUND_VERSION=unbound-1.9.4
ARG UNBOUND_SOURCE=https://www.nlnetlabs.nl/downloads/unbound/
ARG UNBOUND_SHA1=364724dc2fe73cb7b45feeabdbfdff02271c5df7

RUN curl -L "${UNBOUND_SOURCE}${UNBOUND_VERSION}.tar.gz" -o /tmp/unbound.tar.gz \
	&& echo "${UNBOUND_SHA1}  /tmp/unbound.tar.gz" | sha1sum -c - \
	&& tar xzf /tmp/unbound.tar.gz --strip 1 \
	&& ./configure --with-pthreads --with-libevent=/opt/libevent --with-libexpat=/opt/libexpat --with-ssl=/opt/ssl --enable-event-api --disable-flto --disable-static --prefix=/opt/unbound --with-run-dir=/home/nonroot --with-username= --with-chroot-dir= \
	&& make install \
	&& mv /opt/unbound/etc/unbound/unbound.conf /opt/unbound/etc/unbound/example.conf

WORKDIR /tmp/ldns

ARG LDNS_VERSION=ldns-1.7.1
ARG LDNS_SOURCE=https://www.nlnetlabs.nl/downloads/ldns/
ARG LDNS_SHA1=d075a08972c0f573101fb4a6250471daaa53cb3e

RUN curl -L "${LDNS_SOURCE}${LDNS_VERSION}.tar.gz" -o /tmp/ldns.tar.gz \
	&& echo "${LDNS_SHA1}  /tmp/ldns.tar.gz" | sha1sum -c - \
	&& tar xzf /tmp/ldns.tar.gz --strip 1 \
	&& ./configure --prefix=/opt/ldns --disable-static --with-drill --with-ssl=/opt/ssl \
	&& make \
	&& make install

RUN rm -rf /opt/*/include /opt/*/share /opt/*/man

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

COPY --from=builder /opt /opt

COPY a-records.conf unbound.conf /opt/unbound/etc/unbound/

WORKDIR /opt/unbound

ENV PATH /opt/unbound/sbin:/opt/ldns/bin:${PATH}

ENTRYPOINT ["unbound", "-d"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
	CMD [ "drill", "-Q", "-p", "5053", "nlnetlabs.nl", "@localhost" ]

RUN ["unbound", "-V"]