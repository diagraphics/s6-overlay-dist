# syntax = docker/dockerfile:1.4

ARG S6_BASE_IMAGE=${S6_BASE_IMAGE:-scratch}

FROM curlimages/curl:latest AS fetch

ARG S6_OVERLAY_VERSION=${S6_OVERLAY_VERSION:-3.2.0.2}
ARG S6_DOWNLOAD_PREFIX=${S6_DOWNLOAD_PREFIX:-https://github.com/just-containers/s6-overlay/releases/download}
ARG TARGETARCH

COPY ./targetarch /targetarch

WORKDIR /tmp

RUN S6_ARCH=$(/targetarch) && \
    curl -fsSL \
        -O ${S6_DOWNLOAD_PREFIX}/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz \
        -O ${S6_DOWNLOAD_PREFIX}/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz.sha256 \
        -O ${S6_DOWNLOAD_PREFIX}/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz \
        -O ${S6_DOWNLOAD_PREFIX}/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz.sha256 && \
    sha256sum -c *.sha256 && \
    mkdir -p /tmp/s6-rootfs && \
    tar -C /tmp/s6-rootfs -Jxpf s6-overlay-noarch.tar.xz && \
    tar -C /tmp/s6-rootfs -Jxpf s6-overlay-${S6_ARCH}.tar.xz


FROM ${S6_BASE_IMAGE} AS main

COPY --link --from=fetch /tmp/s6-rootfs /
ADD --chmod=755 https://github.com/ko1nksm/shdotenv/releases/latest/download/shdotenv /command/shdotenv
COPY ./s6-rootfs /

ENTRYPOINT [ "/init" ]
