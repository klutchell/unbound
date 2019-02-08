#!/bin/sh -xe

# sleep to allow unbound to start
sleep 5

# test unbound dns response to sigfail.verteiltesysteme.net
# fail if response does not include SERVFAIL
dig "sigfail.verteiltesysteme.net" @unbound -p 53 | grep -q "SERVFAIL" || exit 1

# test unbound dns response to sigok.verteiltesysteme.net
# fail if response does not include NOERROR
dig "sigok.verteiltesysteme.net" @unbound -p 53 | grep -q "NOERROR" || exit 1

exit 0