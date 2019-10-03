#!/bin/sh

mkdir -p /opt/unbound/etc/unbound/dev 2>/dev/null
cp -a /dev/random /dev/urandom /opt/unbound/etc/unbound/dev/

mkdir -p -m 700 /opt/unbound/etc/unbound/var 2>/dev/null
chown _unbound:_unbound /opt/unbound/etc/unbound/var

# update the root trust anchor for DNSSEC validation
unbound-anchor -a /opt/unbound/etc/unbound/var/root.key

# restore the default config files if unbound.conf does not exist
if [ ! -f /opt/unbound/etc/unbound/unbound.conf ]
then
    cp -av /unbound.conf /a-records.conf /example.conf /opt/unbound/etc/unbound/
fi

if [ "$1" = "test" ]
then
    exec unbound -d -c /opt/unbound/etc/unbound/unbound.conf &
    sleep 10 && drill -p 5053 cloudflare.com @127.0.0.1 || exit 1
else
    echo "unbound -d -c /opt/unbound/etc/unbound/unbound.conf $@"
    exec unbound -d -c /opt/unbound/etc/unbound/unbound.conf $@
fi