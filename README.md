# unbound-docker

[unbound](https://unbound.net) docker images

## Build

```bash
# build for amd64
make ARCH=amd64

# build for armv7hf
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

_tbd_

## Author

Kyle Harding <kylemharding@gmail.com>

## License

[MIT License](./LICENSE)

## Acknowledgments

* https://docs.pi-hole.net/guides/unbound/
* https://github.com/MatthewVance/unbound-docker