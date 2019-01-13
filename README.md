# unbound-docker

[Unbound](https://unbound.net) is a validating, recursive, caching DNS resolver.

[![](https://img.shields.io/github/tag-date/klutchell/unbound-docker.svg?style=for-the-badge)](https://github.com/klutchell/unbound-docker/tags)
[![](https://img.shields.io/microbadger/image-size/klutchell/unbound.svg?style=for-the-badge)](https://microbadger.com/images/klutchell/unbound)
[![](https://img.shields.io/microbadger/layers/klutchell/unbound.svg?style=for-the-badge)](https://microbadger.com/images/klutchell/unbound)
[![](https://img.shields.io/docker/pulls/klutchell/unbound.svg?style=for-the-badge)](https://cloud.docker.com/repository/docker/klutchell/unbound)
[![](https://img.shields.io/docker/stars/klutchell/unbound.svg?style=for-the-badge)](https://cloud.docker.com/repository/docker/klutchell/unbound)

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

## License

[MIT License](./LICENSE)