#!/bin/sh

sleep 5

echo "Testing sigfail.verteiltesysteme.net..."
if dig "sigfail.verteiltesysteme.net" @unbound -p 53 | grep -q "SERVFAIL"
then
	echo "Test Passed"
else
	echo "Test Failed"
	exit 1
fi

echo "Testing sigok.verteiltesysteme.net..."
if dig "sigok.verteiltesysteme.net" @unbound -p 53 | grep -q "NOERROR"
then
	echo "Test Passed"
else
	echo "Test Failed"
	exit 1
fi

exit 0