# unofficial unbound docker image

[![Build Status](https://travis-ci.com/klutchell/unbound.svg?branch=master)](https://travis-ci.com/klutchell/unbound)
[![Docker Pulls](https://img.shields.io/docker/pulls/klutchell/unbound.svg?style=flat)](https://hub.docker.com/r/klutchell/unbound/)

[Unbound](https://unbound.net/) is a validating, recursive, and caching DNS resolver.

## Tags

`latest`,
`1.9.3`,
`1.9.0`

## Deployment

```bash
docker run -p 53:53/tcp -p 53:53/udp klutchell/unbound
```

## Parameters

* `-p 53:53/tcp` - expose tcp port 53 on the container to tcp port 53 on the host
* `-p 53:53/udp` - expose udp port 53 on the container to udp port 53 on the host
* `-v /path/to/config:/opt/unbound/etc/unbound/conf.d` - (optional) mount a custom configuration directory

## Building

```bash
make help
make build ARCH=amd64
make build ARCH=arm32v6
make build ARCH=arm32v7
make build ARCH=arm64v8
```

## Testing

```bash
make help
make all ARCH=amd64
make all ARCH=arm32v6
make all ARCH=arm32v7
make all ARCH=arm64v8
```

## Usage

Official NLnet Labs documentation: <https://nlnetlabs.nl/documentation/unbound/>

## Author

Kyle Harding: <https://klutchell.dev>

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.

## Acknowledgments

This image is mostly based on MatthewVance's work: <https://github.com/MatthewVance/unbound-docker>

## License

* klutchell/unbound: [MIT License](./LICENSE)
* OpenSSL: [OpenSSL & SSLeay](https://www.openssl.org/source/license-openssl-ssleay.txt)
* Unbound: [BSD License](https://github.com/NLnetLabs/unbound/blob/master/LICENSE)
