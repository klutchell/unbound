#!/bin/sh

set -xe

# test unbound dns response to sigfail.verteiltesysteme.net
# fail if response does not include SERVFAIL
drill -D @${1} "sigfail.verteiltesysteme.net" | grep SERVFAIL || exit 1

# test unbound dns response to sigok.verteiltesysteme.net
# fail if response does not include NOERROR
drill -D @${1} "sigok.verteiltesysteme.net" | grep NOERROR || exit 1

exit 0