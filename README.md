# unbound-docker

[unbound](https://www.nlnetlabs.nl/projects/unbound/about/) docker images

## Build

```bash
# build for x86_64
make

# build for armhf
make armhf
```

## Deploy

```bash
docker run --name unbound \
    -p 5353:5353 \
    klutchell/unbound
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