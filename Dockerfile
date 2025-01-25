FROM --platform=aarch64 docker.io/homeassistant/aarch64-addon-otbr:2.13.0
FROM --platform=amd64 docker.io/homeassistant/amd64-addon-otbr:2.13.0

COPY rootfs /
