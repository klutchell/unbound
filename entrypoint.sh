#!/bin/sh

set -x

# link to the old config location for compatibility
[ -d /opt/unbound/etc ] && ln -s /opt/unbound/etc /app/etc

# running in chroot requires /dev/random and /dev/urandom
mkdir -p /app/etc/unbound/dev 2>/dev/null
cp -a /dev/random /dev/urandom /app/etc/unbound/dev/

# create and take ownership of chroot var
mkdir -p -m 700 /app/etc/unbound/var 2>/dev/null
chown _unbound:_unbound /app/etc/unbound/var

# update the root trust anchor for DNSSEC validation
unbound-anchor -a /app/etc/unbound/var/root.key

# restore the default config files if unbound.conf does not exist
[ -f /app/etc/unbound/unbound.conf ] || cp -a /unbound.conf /a-records.conf /example.conf /app/etc/unbound/

exec unbound -d -c /app/etc/unbound/unbound.conf $@
