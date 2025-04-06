FROM docker.io/library/ubuntu:24.04

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV DEBCONF_NONINTERACTIVE_SEEN="true" \
    DEBIAN_FRONTEND="noninteractive" \
    NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
    UMASK="0002" \
    TZ="Etc/UTC"

WORKDIR /tmp

RUN <<EOT
    set -xe
    apt-get update
    case "${ TARGETPLATFORM}" in
        'linux/amd64')
            export ARCH='x86_64'
            apt-get install -y --no-install-recommends \
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
                libsqlite3-0 \
                libfontconfig1 \
                libssl3
            ;;
        'linux/arm64')
            export ARCH='aarch64'
            unset NVIDIA_DRIVER_CAPABILITIES
            apt-get install -y --no-install-recommends \
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
                libsqlite3-0 \
                libfontconfig1 \
                libssl3
            ;;
        *)
            echo "Unsupported platform: ${TARGETPLATFORM}" >&2
            exit 1
            ;;
    esac

    echo "**** Installing Emby ****"
    mkdir -p /app/emby /tmp/emby /config
    curl -fsSL -o /tmp/emby.rpm \
        "https://github.com/MediaBrowser/Emby.Releases/releases/download/${VERSION}/emby-server-rpm_${VERSION}_${ARCH}.rpm"
    rpm2cpio /tmp/emby.rpm | cpio -idmv
    ls -l /tmp/opt/emby-server/system/  # Debug: Check contents
    if [ ! -f /tmp/opt/emby-server/system/EmbyServer ]; then
        echo "Error: EmbyServer binary not found in RPM" >&2
        exit 1
    fi
    mv -t /app/emby /tmp/opt/emby-server/*  # Copy everything
    chown -R root:root /app
    chmod -R 755 /app
    chown nobody:nogroup /config
    chmod 755 /config
    ls -l /app/emby/  # Debug: Verify EmbyServer is present

    echo "**** Cleaning up ****"
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
    apt-get autoremove -y
    apt-get clean
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
    printf "umask %d" "${UMASK}" >> /etc/bash.bashrc
EOT

COPY ./apps/emby/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

ENTRYPOINT ["/entrypoint.sh"]
CMD []

LABEL org.opencontainers.image.source="https://github.com/MediaBrowser/Emby"