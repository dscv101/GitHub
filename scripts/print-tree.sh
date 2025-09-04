#!/usr/bin/env bash
set -euo pipefail
command -v tree >/dev/null || { echo "install 'tree' to pretty print"; exit 0; }
cd "$(dirname "$0")/.."
tree -a
