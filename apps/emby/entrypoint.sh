#!/usr/bin/env bash

# Exit on error, unset variables, and pipe failures
set -euo pipefail

# Source umask script if it exists
if [[ -f "/scripts/umask.sh" ]]; then
    # shellcheck disable=SC1091
    source "/scripts/umask.sh"
fi

# Set environment variables for Emby
export LD_LIBRARY_PATH="/app/emby${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
export FONTCONFIG_PATH="/app/emby/etc/fonts"
export SSL_CERT_FILE="/app/emby/etc/ssl/certs/ca-certificates.crt"

# Conditionally set LIBVA_DRIVERS_PATH for x86_64 architecture
if [[ -d "/lib/x86_64-linux-gnu" ]]; then
    export LIBVA_DRIVERS_PATH="/usr/lib/x86_64-linux-gnu/dri:/app/emby/dri"
fi

# Execute EmbyServer with provided arguments
exec /app/emby/EmbyServer \
    -programdata /config \
    -ffdetect /app/emby/ffdetect \
    -ffmpeg /app/emby/ffmpeg \
    -ffprobe /app/emby/ffprobe \
    -restartexitcode 3 \
    "$@"