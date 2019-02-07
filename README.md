# unbound-docker

unofficial [Unbound](https://unbound.net) docker image

[![Build Status](https://travis-ci.org/klutchell/unbound.svg?branch=master)](https://travis-ci.org/klutchell/unbound)
[![Docker Pulls](https://img.shields.io/docker/pulls/klutchell/unbound.svg?style=flat)](https://hub.docker.com/r/klutchell/unbound/)

## Tags

|tag|description|
|---|---|
|`latest`|latest multi-arch|
|`1.9.0`|unbound 1.9.0 multi-arch|
|`amd64-1.9.0`|unbound 1.9.0 amd64|
|`arm-1.9.0`|unbound 1.9.0 arm32v6|
|`arm64-1.9.0`|unbound 1.9.0 arm64v8|

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
make build ARCH=arm
make build ARCH=arm64 BUILD_OPTIONS=--no-cache
```

## Testing

```bash
# examples
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