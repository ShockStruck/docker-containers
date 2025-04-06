#!/usr/bin/env bash

# Exit on error, unset variables, and pipe failures
set -euo pipefail

# Fetch the latest release tag from GitHub API
version=$(curl -sX GET "https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest" \
  | jq --raw-output '.tag_name') || {
  echo "Error: Failed to fetch or parse latest release from GitHub API" >&2
  exit 1
}

# Clean up the version string
version="${version#v}"          # Remove leading 'v' if present
version="${version#release-}"  # Remove 'Release-' prefix if present

# Output the cleaned version
printf "%s" "${version}"