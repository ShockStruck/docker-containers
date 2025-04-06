# Base image
FROM docker.io/library/ubuntu:24.04

# Build arguments
ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

# Environment variables
ENV DEBCONF_NONINTERACTIVE_SEEN="true" \
    DEBIAN_FRONTEND="noninteractive" \
    NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
    UMASK="0002" \
    TZ="Etc/UTC"

# Set working directory
WORKDIR /tmp

# Install dependencies based on architecture
RUN <<EOT
    set -xe
    apt-get update
    case "${TARGETPLATFORM}" in
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
                mesa-va-drivers
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
                libraspberrypi0
            ;;
        *)
            echo "Unsupported platform: ${TARGETPLATFORM}" >&2
            exit 1
            ;;
    esac

    # Install Emby
    echo "**** Installing Emby ****"
    mkdir -p /app/emby /tmp/emby
    curl -fsSL -o /tmp/emby.rpm \
        "https://github.com/MediaBrowser/Emby.Releases/releases/download/${VERSION}/emby-server-rpm_${VERSION}_${ARCH}.rpm"
    rpm2cpio /tmp/emby.rpm | cpio -idm
    mv -t /app/emby \
        /tmp/opt/emby-server/system/* \
        /tmp/opt/emby-server/lib/* \
        /tmp/opt/emby-server/bin/ff* \
        /tmp/opt/emby-server/etc \
        /tmp/opt/emby-server/extra/lib/*

    # Cleanup
    echo "**** Cleaning up ****"
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
    apt-get autoremove -y
    apt-get clean
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
    chown -R root:root /app
    chmod -R 755 /app
    printf "umask %d" "${UMASK}" >> /etc/bash.bashrc
EOT

# Copy entrypoint script
COPY ./apps/emby/entrypoint.sh /entrypoint.sh

# Switch to non-root user
USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

# Entrypoint and command
ENTRYPOINT ["/usr/bin/catatonit", "--"]
CMD ["/entrypoint.sh"]

# Metadata
LABEL org.opencontainers.image.source="https://github.com/MediaBrowser/Emby"