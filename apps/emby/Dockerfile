FROM docker.io/library/ubuntu:24.04

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV DEBCONF_NONINTERACTIVE_SEEN="true" \
    DEBIAN_FRONTEND="noninteractive"

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

ENV UMASK="0002" \
    TZ="Etc/UTC"

USER root
WORKDIR /tmp

# hadolint ignore=DL3008,DL3015,SC2039,SC2086
RUN \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') \
            export ARCH='x86_64'; \
            apt-get update \
            && \
            apt-get install -y --no-install-recommends --no-install-suggests \
                bash \
                ca-certificates \
                catatonit \
                coreutils \
                curl \
                jo \
                jq \
                nano \
                tzdata \
                uuid-runtime \
                xmlstarlet \
                cpio \
                rpm2cpio \
                mesa-va-drivers \
        ;; \
        'linux/arm64') \
            export ARCH='aarch64'; \
            unset NVIDIA_DRIVER_CAPABILITIES; \
            apt-get update \
            && \
            apt-get install -y --no-install-recommends --no-install-suggests \
                bash \
                ca-certificates \
                catatonit \
                coreutils \
                curl \
                jo \
                jq \
                nano \
                tzdata \
                uuid-runtime \
                xmlstarlet \
                cpio \
                rpm2cpio \
                libomxil-bellagio0 \
                libomxil-bellagio-bin \
                libraspberrypi0 \
        ;; \
    esac && \
    echo "**** install emby ****" && \
    mkdir -p \
      /app/emby \
      /tmp/emby && \
    curl -fsSL -o /tmp/emby.rpm \
        "https://github.com/MediaBrowser/Emby.Releases/releases/download/${VERSION}/emby-server-rpm_${VERSION}_${ARCH}.rpm" && \
    rpm2cpio /tmp/emby.rpm | cpio -i --make-directories \
    && \
    mv -t \
        /app/emby \
        /tmp/opt/emby-server/system/* \
        /tmp/opt/emby-server/lib/* \
        /tmp/opt/emby-server/bin/ff* \
        /tmp/opt/emby-server/etc \
        /tmp/opt/emby-server/extra/lib/* && \
    echo "**** cleanup ****" && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/* && \
    chown -R root:root /app && \
    chmod -R 755 /app && \
    printf "umask %d" "${UMASK}" >> /etc/bash.bashrc

COPY ./apps/emby/entrypoint.sh /entrypoint.sh

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

ENTRYPOINT [ "/usr/bin/catatonit", "--" ]
CMD ["/entrypoint.sh"]


LABEL org.opencontainers.image.source="https://github.com/MediaBrowser/Emby"
