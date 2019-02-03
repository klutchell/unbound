#!/bin/sh

# for use with alpine linux only

# 1. install dig via bind-tools
# 2. test unbound dns response to sigfail.verteiltesysteme.net
# 3. fail if response does not include SERVFAIL
# 4. test unbound dns response to sigok.verteiltesysteme.net
# 5. fail if response does not include NOERROR

sleep 5

echo "Testing sigfail.verteiltesysteme.net..."
if dig "sigfail.verteiltesysteme.net" @unbound -p 53 | grep -q "SERVFAIL"
then
	echo "Test 1/2 Passed"
else
	echo "Test 1/2 Failed"
	exit 1
fi

echo "Testing sigok.verteiltesysteme.net..."
if dig "sigok.verteiltesysteme.net" @unbound -p 53 | grep -q "NOERROR"
then
	echo "Test 2/2 Passed"
else
	echo "Test 2/2 Failed"
	exit 1
fi

exit 0