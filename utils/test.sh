#!/bin/sh

sleep 5

apk add --no-cache bind-tools

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