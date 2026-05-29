#!/usr/bin/env bash
# get-windows-path.sh — Print the Windows path for a WSL Linux path (files or directories).
#
# Usage: get-windows-path [path]
#   path        Defaults to the current directory. Resolved with realpath -m.
#   --help, -h  Print this help and exit.
#
# Requires wslpath (WSL).

set -euo pipefail

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

if ! command -v wslpath >/dev/null 2>&1; then
	echo "get-windows-path: wslpath not found (run this from WSL)." >&2
	exit 1
fi

target="${1:-.}"
wslpath -w "$(realpath -m "$target")"
