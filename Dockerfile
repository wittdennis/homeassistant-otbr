ARG ARCH=amd64
FROM docker.io/homeassistant/${ARCH}-addon-otbr:2.13.0

COPY rootfs /
