#!/bin/sh

cp -a /dev/random /dev/urandom /opt/unbound/etc/unbound/dev/

# copy the example file if unbound.conf does not exist
if [ ! -f /opt/unbound/etc/unbound/unbound.conf ]
then
    cp -av /unbound.conf /opt/unbound/etc/unbound/
fi

# copy the default files if the conf.d dir does not contain any .conf files
if [ $(find /opt/unbound/etc/unbound/conf.d/ -type f -name *.conf | wc -l) -lt 1 ]
then
    cp -av /a-records.conf /default.conf /opt/unbound/etc/unbound/conf.d/
fi

# update the root trust anchor for DNSSEC validation
/opt/unbound/sbin/unbound-anchor -a /opt/unbound/etc/unbound/var/root.key

exec /opt/unbound/sbin/unbound -d -c /opt/unbound/etc/unbound/unbound.conf
