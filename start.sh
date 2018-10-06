#!/bin/sh

# set timezone with TZ
# eg. TZ=America/Toronto
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

if [ "${INITSYSTEM}" != "on" ]
then
	# start unbound daemon
	/usr/bin/unbound
fi