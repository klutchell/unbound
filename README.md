# unbound-docker

[Unbound](https://unbound.net) is a validating, recursive, caching DNS resolver.

![](https://img.shields.io/github/last-commit/klutchell/unbound-docker.svg?style=for-the-badge)
![](https://img.shields.io/github/tag-date/klutchell/unbound-docker.svg?style=for-the-badge)
![](https://img.shields.io/microbadger/image-size/klutchell/unbound.svg?style=for-the-badge)
![](https://img.shields.io/microbadger/layers/klutchell/unbound.svg?style=for-the-badge)
![](https://img.shields.io/docker/pulls/klutchell/unbound.svg?style=for-the-badge)
![](https://img.shields.io/docker/stars/klutchell/unbound.svg?style=for-the-badge)

## Build

```bash
# build for platform
make ARCH=amd64
make ARCH=armv7hf
```

## Deploy

```bash
docker run --name unbound \
    -p 5353:53/tcp \
    -p 5353:53/udp \
    klutchell/unbound:amd64
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

## License

[MIT License](./LICENSE)