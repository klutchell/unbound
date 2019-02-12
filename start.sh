#!/bin/sh -xe

# set timezone with TZ (eg. TZ=America/Toronto)
if [ -n "${TZ}" ]
then
	ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime && echo "${TZ}" > /etc/timezone
fi

# download the list of primary root servers.
# unbound ships its own list but we can also download the most recent list and
# update it whenever we think it is a good idea.
# note: there is no point in doing it more often then every 6 months.
curl -fsSL https://www.internic.net/domain/named.root -o "/opt/unbound/etc/unbound/root.hints"

# update the root trust anchor for DNSSEC validation
/opt/unbound/sbin/unbound-anchor -a "/opt/unbound/etc/unbound/root.key"

# take ownership of the working directory
chown -R unbound:unbound "/opt/unbound/etc/unbound"

exec /opt/unbound/sbin/unbound -d -c "/opt/unbound/etc/unbound/unbound.conf"