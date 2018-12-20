FROM debian

ARG BUILD_DATE
ARG BUILD_VERSION

LABEL build_version="${BUILD_VERSION}"
LABEL build_date="${BUILD_DATE}"
LABEL maintainer="kylemharding@gmail.com"

# set frontend
ENV DEBIAN_FRONTEND noninteractive

# install updates and common utilities
RUN apt-get update && apt-get install -yq --no-install-recommends \
	ca-certificates \
	curl \
	dnsutils \
	unbound \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# copy default config file
COPY default.conf /etc/unbound/unbound.conf.d/

# copy start script
COPY start.sh /

# run start script on boot
CMD ["/bin/sh", "/start.sh"]

