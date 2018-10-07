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

# Highlights:
# - Listen only for queries from the local Pi-hole installation (on port 5353)
# - Listen for both UDP and TCP requests
# - Verify DNSSEC signatures, discarding BOGUS domains
# - Apply a few security and privacy tricks
WORKDIR /etc/unbound/unbound.conf.d
COPY default.conf ./

# Optional: Download the list of primary root servers (serving the domain .).
# Unbound ships its own list but we can also download the most recent list and
# update it whenever we think it is a good idea. Note: there is no point in
# doing it more often then every 6 months.
WORKDIR /var/lib/unbound
RUN curl https://www.internic.net/domain/named.root -o root.hints

# copy start script
COPY start.sh /

# run start script on boot
CMD ["/bin/sh", "/start.sh"]

