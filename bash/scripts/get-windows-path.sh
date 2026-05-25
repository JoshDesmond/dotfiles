#!/usr/bin/env bash
# get-windows-path — Print the full Windows path for a directory (WSL2).
#
# Usage:
#   get-windows-path              # current directory
#   get-windows-path /home/foo    # specific path

set -euo pipefail

# ── Constants ──────────────────────────────────────────────────────────
readonly TARGET_PATH="${1:-.}"

# ── Functions ──────────────────────────────────────────────────────────

require_wslpath() {
  if ! command -v wslpath >/dev/null 2>&1; then
    echo "get-windows-path: wslpath not found (run this from WSL2)." >&2
    exit 1
  fi
}

# Resolve to an absolute Linux path, then convert to a Windows path.
get_windows_path() {
  local linux_path
  linux_path="$(cd "$TARGET_PATH" 2>/dev/null && pwd -P)" || {
    echo "get-windows-path: not a directory: ${TARGET_PATH}" >&2
    exit 1
  }
  wslpath -w "$linux_path"
}

# ── Main ───────────────────────────────────────────────────────────────

main() {
  require_wslpath
  get_windows_path
}

main
