# docker-cloud9

[cloud9](https://c9.io/) docker images

## Build

```bash
# build for x86_64
make

# build for armhf
make armhf
```

## Deploy

```bash
docker run --name cloud9 \
    -v cloud9_home:/root \
    -v cloud9_workspace:/workspace \
    -p 8080:8080 \
    --privileged \
    klutchell/cloud9
```

## Environment

|Name|Description|Example|
|---|---|---|
|`C9_USER`|(optional) username for http auth|`root`|
|`C9_PASS`|(optional) password for http auth|`resin`|
|`TZ`|(optional) container timezone|`America/Toronto`|

## Usage

log into the [cloud9 ide](https://c9.io/) by visiting `http://<server-ip>:8080`

## Author

Kyle Harding <kylemharding@gmail.com>

## License

[MIT License](./LICENSE)

## Acknowledgments

* https://github.com/hwegge2/rpi-cloud9-ide
* https://github.com/kdelfour/cloud9-docker