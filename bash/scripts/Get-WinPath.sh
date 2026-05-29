#!/usr/bin/env bash
# Get-WinPath.sh — Print a Windows UNC path (\\wsl$\<distro>\...) for a WSL Linux path, or wslpath for /mnt/ drives.
#
# Usage: Get-WinPath [path]
#   path        Defaults to the current directory. Resolved with realpath -m.
#   --help, -h  Print this help and exit.
#
# Exits with an error on non-WSL hosts. Uses wslpath -w for paths under /mnt/.

set -euo pipefail

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

_is_wsl() {
	[[ -f /proc/version ]] && grep -qiE 'microsoft|wsl' /proc/version
}

_distro_name() {
	if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
		printf '%s' "$WSL_DISTRO_NAME"
		return 0
	fi
	if command -v wslpath >/dev/null 2>&1; then
		# e.g. \\wsl.localhost\Ubuntu\ → last non-empty segment
		wslpath -w / 2>/dev/null | tr '\\' '\n' | grep -v '^$' | tail -n1 || true
	fi
}

_resolve_abs() {
	realpath -m "${1:-.}"
}

if ! _is_wsl; then
	echo "Get-WinPath: not running in WSL (Linux path is already native on this OS)." >&2
	exit 1
fi

target="${1:-.}"
abs="$(_resolve_abs "$target")"

if [[ "$abs" == /mnt/* ]] && command -v wslpath >/dev/null 2>&1; then
	wslpath -w "$abs"
	exit 0
fi

distro="$(_distro_name)"
if [[ -z "$distro" ]]; then
	echo "Get-WinPath: could not determine WSL distro name (set WSL_DISTRO_NAME?)." >&2
	exit 1
fi

rest="${abs#/}"
winpath=$(printf '%s' "$rest" | tr '/' '\\')
printf '%s\n' "\\\\wsl\$\\${distro}\\${winpath}\\"
