FROM alpine:3.10 as build

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk add --no-cache build-base=0.5-r1 ca-certificates=20190108-r0 curl=7.66.0-r0 linux-headers=4.19.36-r0 perl=5.28.2-r1

WORKDIR /tmp/libevent

ARG LIBEVENT_VERSION=release-2.1.11-stable/libevent-2.1.11-stable
ARG LIBEVENT_SOURCE=https://github.com/libevent/libevent/releases/download/

RUN curl -fsSL --retry 3 "${LIBEVENT_SOURCE}${LIBEVENT_VERSION}.tar.gz" -o libevent.tar.gz \
	&& tar xzf libevent.tar.gz --strip 1 \
	&& ./configure --prefix=/opt/libevent --disable-shared \
	&& make -j 4 \
	&& make install

WORKDIR /tmp/libexpat

ARG LIBEXPAT_VERSION=R_2_2_9/expat-2.2.9
ARG LIBEXPAT_SOURCE=https://github.com/libexpat/libexpat/releases/download/

RUN curl -fsSL --retry 3 "${LIBEXPAT_SOURCE}${LIBEXPAT_VERSION}.tar.gz" -o libexpat.tar.gz \
	&& tar xzf libexpat.tar.gz --strip 1 \
	&& ./configure --prefix=/opt/libexpat --disable-shared \
	&& make -j 4 \
	&& make install

WORKDIR /tmp/openssl

ARG OPENSSL_VERSION=openssl-1.1.1d
ARG OPENSSL_SOURCE=https://www.openssl.org/source/
ARG OPENSSL_SHA1=056057782325134b76d1931c48f2c7e6595d7ef4

RUN curl -fsSL --retry 3 "${OPENSSL_SOURCE}${OPENSSL_VERSION}.tar.gz" -o openssl.tar.gz \
	&& echo "${OPENSSL_SHA1}  openssl.tar.gz" | sha1sum -c - \
	&& tar xzf openssl.tar.gz --strip 1 \
	&& ./config --prefix=/opt/openssl --openssldir=/opt/openssl no-weak-ssl-ciphers no-ssl3 no-heartbeats -fstack-protector-strong no-shared \
	&& make -j 4 \
	&& make install_sw

WORKDIR /tmp/unbound

ARG UNBOUND_VERSION=unbound-1.9.6
ARG UNBOUND_SOURCE=https://www.nlnetlabs.nl/downloads/unbound/
ARG UNBOUND_SHA1=b6af3dc87ec3b372f96390c2527140ab8679fc18

RUN curl -fsSL --retry 3 "${UNBOUND_SOURCE}${UNBOUND_VERSION}.tar.gz" -o unbound.tar.gz \
	&& echo "${UNBOUND_SHA1}  unbound.tar.gz" | sha1sum -c - \
	&& tar xzf unbound.tar.gz --strip 1 \
	&& sed -e 's/@LDFLAGS@/@LDFLAGS@ -all-static/' -i Makefile.in \
	&& ./configure --with-pthreads --with-libevent=/opt/libevent --with-libexpat=/opt/libexpat --with-ssl=/opt/openssl --prefix=/opt/unbound --with-run-dir=/var/run/unbound --with-username= --with-chroot-dir= --enable-fully-static --disable-shared --enable-event-api --disable-flto \
	&& make -j 4 install

WORKDIR /tmp/ldns

ARG LDNS_VERSION=ldns-1.7.1
ARG LDNS_SOURCE=https://www.nlnetlabs.nl/downloads/ldns/
ARG LDNS_SHA1=d075a08972c0f573101fb4a6250471daaa53cb3e

RUN curl -fsSL --retry 3 "${LDNS_SOURCE}${LDNS_VERSION}.tar.gz" -o ldns.tar.gz \
	&& echo "${LDNS_SHA1}  ldns.tar.gz" | sha1sum -c - \
	&& tar xzf ldns.tar.gz --strip 1 \
	&& ./configure --prefix=/opt/ldns --with-drill --with-ssl=/opt/openssl --disable-shared \
	&& make -j 4 \
	&& make install

WORKDIR /var/run/unbound

RUN mv /opt/unbound/etc/unbound/unbound.conf /opt/unbound/etc/unbound/example.conf \
	&& rm -rf /tmp/* /opt/*/include /opt/*/man /opt/*/share \
	&& strip /opt/unbound/sbin/unbound \
	&& strip /opt/ldns/bin/drill

# ----------------------------------------------------------------------------

FROM scratch

COPY --from=build /etc/passwd /etc/group /etc/
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /lib/ld-musl-*.so.1 /lib/

COPY --from=build /opt/ldns /opt/ldns
COPY --from=build /opt/unbound /opt/unbound
COPY --from=build --chown=nobody:nogroup /var/run/unbound /var/run/unbound

COPY a-records.conf unbound.conf /opt/unbound/etc/unbound/

USER nobody

ENV PATH /opt/unbound/sbin:/opt/ldns/bin:${PATH}

ENTRYPOINT ["unbound", "-d"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
	CMD [ "drill", "-p", "5053", "nlnetlabs.nl", "@127.0.0.1" ]

RUN ["unbound", "-V"]

RUN ["drill", "-v"]
