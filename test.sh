#!/bin/sh

nohup sh -c '/start.sh' &

sleep 5

drill @127.0.0.1 cloudflare.com || exit 1