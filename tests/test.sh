#!/bin/sh

set -xe

# sleep to allow unbound to start
sleep 5

# test unbound dns response to sigfail.verteiltesysteme.net
# fail if response does not include SERVFAIL
drill -D @unbound "sigfail.verteiltesysteme.net" | grep SERVFAIL || exit 1

# test unbound dns response to sigok.verteiltesysteme.net
# fail if response does not include NOERROR
drill -D @unbound "sigok.verteiltesysteme.net" | grep NOERROR || exit 1

exit 0