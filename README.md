# unofficial unbound multiarch docker image

[![Docker Pulls](https://img.shields.io/docker/pulls/klutchell/unbound.svg?style=flat-square)](https://hub.docker.com/r/klutchell/unbound/)
[![Docker Stars](https://img.shields.io/docker/stars/klutchell/unbound.svg?style=flat-square)](https://hub.docker.com/r/klutchell/unbound/)

[Unbound](https://unbound.net/) is a validating, recursive, and caching DNS resolver.

## Tags

These tags including rolling updates, so occasionally the associated image may change to include fixes.

- `1.9.4`, `latest`
- `1.9.3`
- `1.9.0`

## Architectures

The architectures supported by this image are:

- `linux/amd64`
- `linux/arm64`
- `linux/ppc64le`
- `linux/s390x`
- `linux/arm/v7`
- `linux/arm/v6`

Simply pulling `klutchell/unbound` should retrieve the correct image for your arch.

## Building

```bash
# display available commands
make help

# clean dangling images, containers, and build instances
make clean

# build and test on the host architecture
make build test

# cross-build for other architectures
make build test EXTRA_OPTS=--platform=linux/arm/v7
```

## Usage

NLnet Labs documentation: <https://nlnetlabs.nl/documentation/unbound/>

```bash
# print general usage
docker run --rm klutchell/unbound -h

# run a recursive dns server on host port 53
docker run -p 53:5053/tcp -p 53:5053/udp klutchell/unbound

# copy the example configuration files from the image to a host directory
docker run --name unbound -d --rm klutchell/unbound
docker cp unbound:/opt/unbound/etc/unbound /path/to/config
docker stop unbound

# run unbound server with configuration mounted from a host directory
docker run --name unbound -p 53:5053/udp -v /path/to/config:/opt/unbound/etc/unbound klutchell/unbound

# generate a root trust anchor for DNSSEC validation
# assumes your existing container is named 'unbound' as in the example above
docker exec unbound unbound-anchor -v
```

Please note the following if you are using a custom configuration file:

- `chroot:` is not required (and will not work) as the container is running as nonroot
- `username:` is not required as the container is running as nonroot
- `auto-trust-anchor-file:` is not required as the default value is `/var/run/unbound/root.key`
- any additional paths should be provided as absolute or relative to `/var/run/unbound`

## Author

Kyle Harding: <https://klutchell.dev>

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.

## Acknowledgments

Original software is by NLnet Labs: <https://github.com/NLnetLabs/unbound>

## Licenses

- klutchell/unbound: [MIT License](./LICENSE)
- unbound: [BSD 3-Clause "New" or "Revised" License](https://github.com/NLnetLabs/unbound/blob/master/LICENSE)
- ldns: [BSD 3-Clause "New" or "Revised" License](https://github.com/NLnetLabs/ldns/blob/develop/LICENSE)
- openssl: [OpenSSL License & Original SSLeay License](https://www.openssl.org/source/license-openssl-ssleay.txt)
- libevent: [BSD License](https://libevent.org/LICENSE.txt)
- libexpat: [MIT License](https://github.com/libexpat/libexpat/blob/master/expat/COPYING)
