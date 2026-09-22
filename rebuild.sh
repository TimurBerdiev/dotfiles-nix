#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# Resolve the absolute path before sudo, which resets PATH to a secure default.
DARWIN_REBUILD="$(command -v darwin-rebuild || echo /run/current-system/sw/bin/darwin-rebuild)"
exec sudo "$DARWIN_REBUILD" switch --flake "path:$DIR#mac"
