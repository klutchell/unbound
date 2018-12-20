#!/bin/sh

# set timezone with TZ
# eg. TZ=America/Toronto
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# enable dnssec
# http://dnssec.vs.uni-due.de/
# https://nlnetlabs.nl/documentation/unbound/howto-anchor/
unbound-anchor

# Optional: Download the list of primary root servers (serving the domain .).
# Unbound ships its own list but we can also download the most recent list and
# update it whenever we think it is a good idea. Note: there is no point in
# doing it more often then every 6 months.
curl https://www.internic.net/domain/named.root -o /var/lib/unbound/root.hints

# start unbound daemon
/usr/sbin/unbound -d -c /etc/unbound/unbound.conf.d/default.conf