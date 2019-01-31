# unbound-docker

[unbound](https://unbound.net) is a validating, recursive, caching DNS resolver.

[![](https://images.microbadger.com/badges/version/klutchell/unbound:amd64.svg)](https://microbadger.com/images/klutchell/unbound:amd64 "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/klutchell/unbound:amd64.svg)](https://microbadger.com/images/klutchell/unbound:amd64 "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/klutchell/unbound:amd64.svg)](https://microbadger.com/images/klutchell/unbound:amd64 "Get your own image badge on microbadger.com")

[![](https://images.microbadger.com/badges/version/klutchell/unbound:armv7hf.svg)](https://microbadger.com/images/klutchell/unbound:armv7hf "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/klutchell/unbound:armv7hf.svg)](https://microbadger.com/images/klutchell/unbound:armv7hf "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/klutchell/unbound:armv7hf.svg)](https://microbadger.com/images/klutchell/unbound:armv7hf "Get your own image badge on microbadger.com")

## Motivation

* run [unbound](https://unbound.net) upstream of [my pi-hole stack](https://github.com/klutchell/balena-pihole)
* support for x86_64 and raspberry pi 3
* build minimal images
* use the most recent builds of unbound from source

## Building

```bash
# build for amd64
make ARCH=amd64

# build for armv7hf
make ARCH=armv7hf
```

## Deployment

```bash
# deploy on amd64
docker run -p 5353:53/tcp -p 5353:53/udp -d klutchell/unbound:amd64

# deploy on armv7hf
docker run -p 5353:53/tcp -p 5353:53/udp -d klutchell/unbound:armv7hf
```

## Usage

This image supports the following environment variables at runtime.

|Name|Description|Example|
|---|---|---|
|`TZ`|(optional) container timezone|`America/Toronto`|

## Testing

You can test DNSSEC validation using
```bash
dig sigfail.verteiltesysteme.net @127.0.0.1 -p 5353
dig sigok.verteiltesysteme.net @127.0.0.1 -p 5353
```
The first command should give a status report of SERVFAIL and no IP address. The second should give NOERROR plus an IP address.

## Contributing

```bash
# bump patch version
make tag BUMP=patch

# bump minor version
make tag BUMP=minor

# bump major version
make tag BUMP=major

# push amd64 image to docker hub
make push ARCH=amd64

# push armv7hf image to docker hub
make push ARCH=armv7hf
```

## Author

Kyle Harding <kylemharding@gmail.com>

## Acknowledgments

* https://docs.pi-hole.net/guides/unbound/
* https://github.com/folhabranca/docker-unbound
* https://github.com/MatthewVance/unbound-docker
* https://www.balena.io/docs/reference/base-images/base-images/
* https://nlnetlabs.nl/documentation/unbound/howto-anchor/
* https://nlnetlabs.nl/documentation/unbound/howto-setup/
* http://www.linuxfromscratch.org/blfs/view/svn/server/unbound.html

## License

[MIT License](./LICENSE)