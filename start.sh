#!/bin/sh

# set timezone with TZ
# eg. TZ=America/Toronto
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# enable dnssec
# http://dnssec.vs.uni-due.de/
# https://nlnetlabs.nl/documentation/unbound/howto-anchor/
unbound-anchor

# start unbound daemon
/usr/sbin/unbound -d -c /etc/unbound/unbound.conf.d/default.conf