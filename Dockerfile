FROM buildpack-deps:buster-curl as build

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -qq --no-install-recommends build-essential=12.6 file=1:5.35-4 \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& adduser --system nonroot

WORKDIR /tmp/libevent

ARG LIBEVENT_VERSION=release-2.1.11-stable/libevent-2.1.11-stable
ARG LIBEVENT_SOURCE=https://github.com/libevent/libevent/releases/download/

RUN curl -L "${LIBEVENT_SOURCE}${LIBEVENT_VERSION}.tar.gz" -o /tmp/libevent.tar.gz \
	&& tar xzf /tmp/libevent.tar.gz --strip 1 \
	&& ./configure --prefix=/usr/local --disable-static \
	&& make \
	&& make install

WORKDIR /tmp/libexpat

ARG LIBEXPAT_VERSION=R_2_2_9/expat-2.2.9
ARG LIBEXPAT_SOURCE=https://github.com/libexpat/libexpat/releases/download/

RUN curl -L "${LIBEXPAT_SOURCE}${LIBEXPAT_VERSION}.tar.gz" -o /tmp/libexpat.tar.gz \
	&& tar xzf /tmp/libexpat.tar.gz --strip 1 \
	&& ./configure --prefix=/usr/local --disable-static \
	&& make \
	&& make install

WORKDIR /tmp/ssl

ARG SSL_VERSION=openssl-1.1.1d
ARG SSL_SOURCE=https://www.openssl.org/source/
ARG SSL_SHA1=056057782325134b76d1931c48f2c7e6595d7ef4

RUN curl -L "${SSL_SOURCE}${SSL_VERSION}.tar.gz" -o /tmp/ssl.tar.gz \
	&& echo "${SSL_SHA1}  /tmp/ssl.tar.gz" | sha1sum -c - \
	&& tar xzf /tmp/ssl.tar.gz --strip 1 \
	&& ./config --prefix=/usr/local --openssldir=/usr/local no-weak-ssl-ciphers no-ssl3 no-heartbeats -fstack-protector-strong \
	&& make \
	&& make install_sw

WORKDIR /tmp/unbound

ARG UNBOUND_VERSION=unbound-1.9.4
ARG UNBOUND_SOURCE=https://www.nlnetlabs.nl/downloads/unbound/
ARG UNBOUND_SHA1=364724dc2fe73cb7b45feeabdbfdff02271c5df7

RUN curl -L "${UNBOUND_SOURCE}${UNBOUND_VERSION}.tar.gz" -o /tmp/unbound.tar.gz \
	&& echo "${UNBOUND_SHA1}  /tmp/unbound.tar.gz" | sha1sum -c - \
	&& tar xzf /tmp/unbound.tar.gz --strip 1 \
	&& ./configure --with-pthreads --with-libevent=/usr/local --with-libexpat=/usr/local --with-ssl=/usr/local --prefix=/usr/local --with-run-dir=/home/nonroot --with-username= --with-chroot-dir= --enable-fully-static --enable-event-api --disable-flto --disable-dependency-tracking \
	&& make install \
	&& mv /usr/local/etc/unbound/unbound.conf /usr/local/etc/unbound/example.conf

WORKDIR /tmp/ldns

ARG LDNS_VERSION=ldns-1.7.1
ARG LDNS_SOURCE=https://www.nlnetlabs.nl/downloads/ldns/
ARG LDNS_SHA1=d075a08972c0f573101fb4a6250471daaa53cb3e

RUN curl -L "${LDNS_SOURCE}${LDNS_VERSION}.tar.gz" -o /tmp/ldns.tar.gz \
	&& echo "${LDNS_SHA1}  /tmp/ldns.tar.gz" | sha1sum -c - \
	&& tar xzf /tmp/ldns.tar.gz --strip 1 \
	&& ./configure --prefix=/usr/local --disable-static --with-drill --with-ssl=/usr/local \
	&& make \
	&& make install

# ----------------------------------------------------------------------------

FROM scratch

ARG BUILD_DATE
ARG BUILD_VERSION
ARG VCS_REF

LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.authors="Kyle Harding <https://klutchell.dev>"
LABEL org.opencontainers.image.url="https://klutchell.dev/unbound"
LABEL org.opencontainers.image.documentation="https://klutchell.dev/unbound"
LABEL org.opencontainers.image.source="https://klutchell.dev/unbound"
LABEL org.opencontainers.image.version="${BUILD_VERSION}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
# LABEL org.opencontainers.image.vendor=""
# LABEL org.opencontainers.image.licenses=""
# LABEL org.opencontainers.image.ref.name=""
LABEL org.opencontainers.image.title="klutchell/unbound"
LABEL org.opencontainers.image.description="Unbound is a validating, recursive, caching DNS resolver"

COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/etc /usr/local/etc
COPY --from=build /usr/local/lib /usr/local/lib
COPY --from=build /usr/local/sbin /usr/local/sbin
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY a-records.conf unbound.conf /usr/local/etc/unbound/

USER nonroot

WORKDIR /usr/local

ENTRYPOINT ["unbound", "-d"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
	CMD [ "drill", "-Q", "-p", "5053", "nlnetlabs.nl", "@localhost" ]

RUN ["unbound", "-V"]
