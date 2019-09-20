#!/bin/sh

mkdir /opt/unbound/etc/unbound/dev 2>/dev/null
cp -a /dev/random /dev/urandom /opt/unbound/etc/unbound/dev/

mkdir -m 700 /opt/unbound/etc/unbound/var 2>/dev/null
chown _unbound:_unbound /opt/unbound/etc/unbound/var

# update the root trust anchor for DNSSEC validation
/opt/unbound/sbin/unbound-anchor -a /opt/unbound/etc/unbound/var/root.key

exec /opt/unbound/sbin/unbound -d -c /opt/unbound/etc/unbound/unbound.conf
