# syntax = docker/dockerfile:1.4

ARG S6_BASE_IMAGE=${S6_BASE_IMAGE:-scratch}

FROM busybox AS fetch

ARG S6_OVERLAY_VERSION=${S6_OVERLAY_VERSION:-3.2.0.2}
ARG S6_DOWNLOAD_PREFIX=${S6_DOWNLOAD_PREFIX:-https://github.com/just-containers/s6-overlay/releases/download}

WORKDIR /tmp

ADD ${S6_DOWNLOAD_PREFIX}/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD ${S6_DOWNLOAD_PREFIX}/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz.sha256 /tmp
ADD ${S6_DOWNLOAD_PREFIX}/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
ADD ${S6_DOWNLOAD_PREFIX}/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz.sha256 /tmp

RUN sha256sum -c *.sha256

WORKDIR /s6-rootfs

RUN tar -Jxpf /tmp/s6-overlay-noarch.tar.xz \
 && tar -Jxpf /tmp/s6-overlay-x86_64.tar.xz


FROM ${S6_BASE_IMAGE} AS main

COPY --link --from=fetch /s6-rootfs /
ADD --chmod=755 https://github.com/ko1nksm/shdotenv/releases/latest/download/shdotenv /command/shdotenv
COPY ./s6-rootfs /

ENTRYPOINT [ "/init" ]
