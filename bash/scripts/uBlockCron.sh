#!/usr/bin/env bash
# uBlockCron.sh — Rough check whether Firefox's process memory maps suggest uBlock-related strings (experimental).
#
# Usage: uBlockCron.sh
#   --help, -h  Print this help and exit.
#
# Greps /proc/<firefox-pid>; output is "okie" or "No uBlock!". Depends on ps/grep layout.

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

pid=$(ps -a | grep firefox | cut -d' ' -f1)

if [ -n "$pid" ]; then
	pushd "/proc/$pid" >/dev/null
	uBlockGrep=$(timeout 0.3s grep "uBlock" -r 2>/dev/null)
	if [ -n "$uBlockGrep" ]; then
		echo "No uBlock!"
	else
		echo "okie"
	fi
	popd >/dev/null
fi
