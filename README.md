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

Simply pulling `klutchell/unbound:1.9.4` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

The architectures supported by this image are:

- `linux/amd64`
- `linux/arm64`
- `linux/ppc64le`
- `linux/s390x`
- `linux/386`
- `linux/arm/v7`

## Building

```bash
# display available commands
make help

# build and test on the host OS architecture
make build BUILD_OPTIONS=--no-cache

# cross-build multiarch manifest(s) with configured platforms
make all BUILD_OPTIONS=--push

# inspect manifest contents
make inspect
```

## Usage

NLnet Labs documentation: <https://nlnetlabs.nl/documentation/unbound/>

```bash
# print version info
docker run --rm klutchell/unbound -v

# print general usage
docker run --rm klutchell/unbound -h

# run dns server on host port 53
docker run -p 53:5053/tcp -p 53:5053/udp klutchell/unbound

# mount external configuration directory
docker run -v /path/to/config:/app/etc/unbound klutchell/unbound

# generate a root trust anchor for DNSSEC validation
docker run --entrypoint unbound-anchor klutchell/unbound
```

## Author

Kyle Harding: <https://klutchell.dev>

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.

## Acknowledgments

Original software is by NLnet Labs: <https://unbound.net>

## License

- klutchell/unbound: [MIT License](./LICENSE)
- Unbound: [BSD License](https://github.com/NLnetLabs/unbound/blob/master/LICENSE)
