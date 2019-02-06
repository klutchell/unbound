# unbound-docker [![Build Status](https://travis-ci.org/klutchell/unbound.svg?branch=master)](https://travis-ci.org/klutchell/unbound)

unofficial [Unbound](https://unbound.net) docker image

## Tags

|tag|description|
|---|---|
|`latest`|latest multi-arch|
|`1.9.0`|unbound 1.9.0 multi-arch|
|`amd64-1.9.0`|unbound 1.9.0 for amd64|
|`arm-1.9.0`|unbound 1.9.0 for arm32v6|
|`arm64-1.9.0`|unbound 1.9.0 for arm64v8|

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
# usage:
make build ARCH=[amd64|arm|arm64]

# example:
make build ARCH=arm
```

## Testing

```bash
# usage:
make test ARCH=[amd64|arm|arm64]

# example:
make test ARCH=arm
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