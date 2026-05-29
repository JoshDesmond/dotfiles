#!/usr/bin/env bash
# fix_audio.sh — Restart PulseAudio (kill existing daemon, then start a new one).
#
# Usage: fix_audio.sh
#   --help, -h  Print this help and exit.
#
# Uses killall and pulseaudio; intended for local desktop troubleshooting.

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

killall pulseaudio 2>/dev/null || true
pulseaudio -k 2>/dev/null || true
pulseaudio --start
