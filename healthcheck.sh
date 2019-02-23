#!/bin/sh

# test unbound dns response to sigfail.verteiltesysteme.net
# fail if response does not include SERVFAIL
drill -D @127.0.0.1 "sigfail.verteiltesysteme.net" | tee /dev/stderr | grep -q SERVFAIL || exit 1

# test unbound dns response to sigok.verteiltesysteme.net
# fail if response does not include NOERROR
drill -D @127.0.0.1 "sigok.verteiltesysteme.net" | tee /dev/stderr | grep -q NOERROR || exit 1

exit 0