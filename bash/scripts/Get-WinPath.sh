#!/usr/bin/env bash
# Print the Windows-accessible path for a WSL filesystem location as a UNC
# string: \\wsl$\<distro>\<unix path with backslashes>\
# On non-WSL systems, prints an error and exits 1.
# For paths under /mnt/ (drvfs), uses wslpath -w when available.

set -euo pipefail

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
