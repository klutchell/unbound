# unbound-docker

[Unbound](https://unbound.net) is a validating, recursive, caching DNS resolver.

[![](https://images.microbadger.com/badges/version/klutchell/unbound:amd64.svg)](https://microbadger.com/images/klutchell/unbound:amd64 "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/klutchell/unbound:amd64.svg)](https://microbadger.com/images/klutchell/unbound:amd64 "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/klutchell/unbound:amd64.svg)](https://microbadger.com/images/klutchell/unbound:amd64 "Get your own image badge on microbadger.com")

[![](https://images.microbadger.com/badges/version/klutchell/unbound:armv7hf.svg)](https://microbadger.com/images/klutchell/unbound:armv7hf "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/klutchell/unbound:armv7hf.svg)](https://microbadger.com/images/klutchell/unbound:armv7hf "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/klutchell/unbound:armv7hf.svg)](https://microbadger.com/images/klutchell/unbound:armv7hf "Get your own image badge on microbadger.com")

## Build

```bash
# build for amd64
make ARCH=amd64

# build for armv7hf
make ARCH=armv7hf
```

## Deploy

```bash
# deploy on amd64
docker run -p 5353:53/tcp -p 5353:53/udp -d klutchell/unbound:amd64

# deploy on armv7hf
docker run -p 5353:53/tcp -p 5353:53/udp -d klutchell/unbound:armv7hf
```

## Environment

|Name|Description|Example|
|---|---|---|
|`TZ`|(optional) container timezone|`America/Toronto`|

## Usage

Set your DNS servers to `<docker-host-ip>:5353` on your other devices.

## Testing

Start your local recursive server and test that it's operational:
```bash
dig pi-hole.net @127.0.0.1 -p 5353
```
The first query may be quite slow, but subsequent queries, also to other domains under the same TLD, should be fairly quick.

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

* [nlnetlabs.nl](https://nlnetlabs.nl/projects/unbound/about/)
* [balena.io](https://www.balena.io/docs/reference/base-images/base-images/)
* [pi-hole.net](https://docs.pi-hole.net/guides/unbound/)

## References

* https://www.balena.io/docs/reference/base-images/base-images/
* https://www.nlnetlabs.nl/svn/unbound/trunk/doc/example.conf.in
* https://docs.pi-hole.net/guides/unbound/
* https://github.com/folhabranca/docker-unbound
* https://github.com/MatthewVance/unbound-docker
* http://dnssec.vs.uni-due.de/
* https://nlnetlabs.nl/documentation/unbound/howto-anchor/
* http://www.linuxfromscratch.org/blfs/view/svn/server/unbound.html

## License

[MIT License](./LICENSE)