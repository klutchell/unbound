# unbound-docker

unofficial [Unbound](https://unbound.net) docker image

[![Build Status](https://travis-ci.com/klutchell/unbound.svg?branch=master)](https://travis-ci.com/klutchell/unbound)
[![Docker Pulls](https://img.shields.io/docker/pulls/klutchell/unbound.svg?style=flat)](https://hub.docker.com/r/klutchell/unbound/)

## Tags

|tag|unbound|libressl|base|
|---|---|---|---|
|`latest`|[`1.9.0`](https://nlnetlabs.nl/downloads/unbound/)|[`2.8.3`](https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/)|[`multiarch manifest-v2-2`](https://docs.docker.com/registry/spec/manifest-v2-2/#manifest-list)|
|`1.9.0`|[`1.9.0`](https://nlnetlabs.nl/downloads/unbound/)|[`2.8.3`](https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/)|[`multiarch manifest-v2-2`](https://docs.docker.com/registry/spec/manifest-v2-2/#manifest-list)|
|`1.9.0-amd64`|[`1.9.0`](https://nlnetlabs.nl/downloads/unbound/)|[`2.8.3`](https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/)|[`multiarch/alpine:amd64-v3.8`](https://hub.docker.com/r/multiarch/alpine/)|
|`1.9.0-arm`|[`1.9.0`](https://nlnetlabs.nl/downloads/unbound/)|[`2.8.3`](https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/)|[`multiarch/alpine:armhf-v3.8`](https://hub.docker.com/r/multiarch/alpine/)|
|`1.9.0-arm64`|[`1.9.0`](https://nlnetlabs.nl/downloads/unbound/)|[`2.8.3`](https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/)|[`multiarch/alpine:aarch64-v3.8`](https://hub.docker.com/r/multiarch/alpine/)|

## Deployment

```bash
docker run -p 5353:53/tcp -p 5353:53/udp -e TZ=America/Toronto klutchell/unbound
```

## Parameters

* `-p 5353:53/tcp` - expose tcp port 53 on the container to tcp port 5353 on the host
* `-p 5353:53/udp` - expose udp port 53 on the container to udp port 5353 on the host
* `-e TZ=America/Toronto` - (optional) provide desired timezone from [this list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

## Building

```bash
# examples
make build
make build ARCH=arm
make build ARCH=arm64 BUILD_OPTIONS=--no-cache
```

## Testing

```bash
# examples
make test
make test ARCH=arm
make test ARCH=arm64
```

## Usage

Check out the following guide for usage with [Pi-hole](https://pi-hole.net/)

* https://docs.pi-hole.net/guides/unbound/

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