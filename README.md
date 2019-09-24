# unofficial unbound docker image

[![Build Status](https://travis-ci.com/klutchell/unbound.svg?branch=master)](https://travis-ci.com/klutchell/unbound)
[![Docker Pulls](https://img.shields.io/docker/pulls/klutchell/unbound.svg?style=flat)](https://hub.docker.com/r/klutchell/unbound/)

[Unbound](https://unbound.net/) is a validating, recursive, and caching DNS resolver.

## Tags

* `latest`, `1.9.3`
* `amd64-latest`, `amd64-1.9.3`
* `arm32v6-latest`, `arm32v6-1.9.3`
* `arm32v7-latest`, `arm32v7-1.9.3`
* `arm64v8-latest`, `arm64v8-1.9.3`
* `i386-latest`, `i386-1.9.3`
* `ppc64le-latest`, `ppc64le-1.9.3`
* `s390x-latest`, `s390x-1.9.3`

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
make build
```

## Usage

NLnet Labs documentation: https://nlnetlabs.nl/documentation/unbound/

## Author

Kyle Harding: https://klutchell.dev

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.

## Acknowledgments

This image is mostly based on MatthewVance's work: https://github.com/MatthewVance/unbound-docker

## License

* klutchell/unbound: [MIT License](./LICENSE)
* OpenSSL: [OpenSSL & SSLeay](https://www.openssl.org/source/license-openssl-ssleay.txt)
* Unbound: [BSD License](https://github.com/NLnetLabs/unbound/blob/master/LICENSE)
