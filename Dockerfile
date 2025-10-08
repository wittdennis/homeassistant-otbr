# renovate: datasource=docker depName=homeassistant/amd64-addon-otbr versioning=docker
ARG VERSION=2.14.0
ARG ARCH=amd64
FROM docker.io/homeassistant/${ARCH}-addon-otbr:${VERSION}

COPY rootfs /
