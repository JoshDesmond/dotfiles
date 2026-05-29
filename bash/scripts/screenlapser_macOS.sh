#!/usr/bin/env bash
# screenlapser_macOS.sh — Capture periodic screenshots into ~/Pictures/timelapse/<timestamp>/ when ScreenSaverEngine is available (macOS).
#
# Usage: screenlapser_macOS.sh
#   --help, -h  Print this help and exit.
#
# Uses osascript and screencapture in a loop. Fixed crop region 1920x1080; adjust for your display.

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

timelapse_directory="$HOME/Pictures/timelapse"
mkdir -p "$timelapse_directory"
cd "$timelapse_directory" || exit 1
var_time=$(date +%Y-%m-%d-%H%M%S)
mkdir "$var_time"
cd "./$var_time" || exit 1

while [ 1 ]; do
	if osascript -e 'tell application "ScreenSaverEngine" to get name' >/dev/null 2>&1; then
		screencapture -R 0,0,1920,1080 -x "$(date +%Y-%m-%d-%H%M%S).jpg"
	fi
	sleep 10
done

exit 1
