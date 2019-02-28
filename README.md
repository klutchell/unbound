# unofficial unbound docker image

[![Build Status](https://travis-ci.com/klutchell/unbound.svg?branch=master)](https://travis-ci.com/klutchell/unbound)
[![Docker Pulls](https://img.shields.io/docker/pulls/klutchell/unbound.svg?style=flat)](https://hub.docker.com/r/klutchell/unbound/)

[Unbound](https://unbound.net/) is a validating, recursive, and caching DNS resolver.

## Tags

|tag|unbound|libressl|image|
|---|---|---|---|
|`latest`|[`1.9.0`](https://nlnetlabs.nl/downloads/unbound/)|[`2.8.3`](https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/)|[`manifest-v2-2`](https://docs.docker.com/registry/spec/manifest-v2-2/#manifest-list)|
|`1.9.0`|[`1.9.0`](https://nlnetlabs.nl/downloads/unbound/)|[`2.8.3`](https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/)|[`manifest-v2-2`](https://docs.docker.com/registry/spec/manifest-v2-2/#manifest-list)|
|`1.9.0-amd64`|[`1.9.0`](https://nlnetlabs.nl/downloads/unbound/)|[`2.8.3`](https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/)|[![](https://images.microbadger.com/badges/image/klutchell/unbound:1.9.0-amd64.svg)](https://microbadger.com/images/klutchell/unbound:1.9.0-amd64)|
|`1.9.0-arm`|[`1.9.0`](https://nlnetlabs.nl/downloads/unbound/)|[`2.8.3`](https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/)|[![](https://images.microbadger.com/badges/image/klutchell/unbound:1.9.0-arm.svg)](https://microbadger.com/images/klutchell/unbound:1.9.0-arm)|
|`1.9.0-arm64`|[`1.9.0`](https://nlnetlabs.nl/downloads/unbound/)|[`2.8.3`](https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/)|[![](https://images.microbadger.com/badges/image/klutchell/unbound:1.9.0-arm64.svg)](https://microbadger.com/images/klutchell/unbound:1.9.0-arm64)|

## Deployment

```bash
docker run -p 53:53/tcp -p 53:53/udp klutchell/unbound
```

## Parameters

* `-p 53:53/tcp` - expose tcp port 53 on the container to tcp port 53 on the host
* `-p 53:53/udp` - expose udp port 53 on the container to udp port 53 on the host
* `-v /path/to/config:/opt/unbound/etc/unbound` - (optional) mount a custom configuration directory

## Building

```bash
make help
make build ARCH=arm32v6
```

## Testing

```bash
make help
make test ARCH=arm32v6
```

## Usage

Check out the following guide for usage with Pi-hole

* https://docs.pi-hole.net/guides/unbound/

Also check out MatthewVance's README for more detail since this image is based on his work

* https://github.com/MatthewVance/unbound-docker

## Author

Kyle Harding <kylemharding@gmail.com>

## Contributing

Feel free to send an email or submit a pull request with any features, fixes, or changes!

## Acknowledgments

* https://github.com/MatthewVance/unbound-docker
* https://github.com/folhabranca/docker-unbound
* https://docs.pi-hole.net/guides/unbound/
* https://nlnetlabs.nl/documentation/unbound/howto-anchor/
* https://nlnetlabs.nl/documentation/unbound/howto-setup/

## License

* klutchell/unbound: [MIT License](./LICENSE)
* LibreSSL: [dual-licensed](https://raw.githubusercontent.com/libressl/libressl/master/src/LICENSE)
* Unbound: [BSD License](https://nlnetlabs.nl/svn/unbound/trunk/LICENSE)