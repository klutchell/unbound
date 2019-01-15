#!/bin/sh

# set timezone with TZ
# eg. TZ=America/Toronto
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# update the root anchor for dnssec
/opt/unbound/sbin/unbound-anchor -a "/opt/unbound/etc/unbound/root.key"

# Download the list of primary root servers.
# Unbound ships its own list but we can also download the most recent list and
# update it whenever we think it is a good idea. Note: there is no point in
# doing it more often then every 6 months.
curl https://www.internic.net/domain/named.root -o "/opt/unbound/etc/unbound/root.hints"

# take full ownership of unbound lib dir since the unbound process needs
# write access to the root.key parent dir
# chown -R unbound:unbound "/var/lib/unbound"

# start unbound daemon
/opt/unbound/sbin/unbound -d -c "/opt/unbound/etc/unbound/unbound.conf"