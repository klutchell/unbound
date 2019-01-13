# unbound-docker

[unbound](https://unbound.net) docker images

## Build

```bash
# build for platform
make ARCH=amd64
make ARCH=armv7hf
```

## Deploy

```bash
docker run --name unbound \
    -p 53:53/tcp \
    -p 53:53/udp \
    klutchell/unbound:amd64
```

## Environment

|Name|Description|Example|
|---|---|---|
|`TZ`|(optional) container timezone|`America/Toronto`|

## Usage

Set your DNS servers to `<docker-host-ip>:53` on your other devices.

You can test DNSSEC validation using
```bash
dig sigfail.verteiltesysteme.net @127.0.0.1 -p 53
dig sigok.verteiltesysteme.net @127.0.0.1 -p 53
```

## Contributing

```bash
# bump git version tag
make tag BUMP=patch
make tag BUMP=minor
make tag BUMP=major

# deploy to docker hub
make push ARCH=amd64
make push ARCH=armv7hf

# build and deploy to docker hub
make release ARCH=amd64
make release ARCH=armv7hf
```

## Author

Kyle Harding <kylemharding@gmail.com>

## Acknowledgments

This image wouldn't be possible without the hard work of the unbound
core team and the references included below!

## References

* https://www.nlnetlabs.nl/svn/unbound/trunk/doc/example.conf.in
* https://docs.pi-hole.net/guides/unbound/
* https://github.com/folhabranca/docker-unbound
* https://github.com/MatthewVance/unbound-docker
* http://dnssec.vs.uni-due.de/
* https://nlnetlabs.nl/documentation/unbound/howto-anchor/

## License

[MIT License](./LICENSE)