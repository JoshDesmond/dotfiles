#!/usr/bin/env bash
# screenlapser.sh — Capture periodic screenshots into ~/Pictures/timelapse/<timestamp>/ when the GNOME screensaver is inactive.
#
# Usage: screenlapser.sh
#   --help, -h  Print this help and exit.
#
# Uses gnome-screensaver-command, scrot/import on host "prospero", or import on other hosts. Runs until stopped.

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

# First create and navigate to a new folder
timelapse_directory="$HOME/Pictures/timelapse"
mkdir -p "$timelapse_directory"
cd "$timelapse_directory" || exit 1
var_time=$(date +%Y-%m-%d-%H%M%S)
mkdir "$var_time"
cd "./$var_time" || exit 1

if ! [ -x "$(command -v gnome-screensaver-command)" ]; then
	echo 'Error: gnome-screensaver-command is not installed.' >&2
	exit 1
fi

if [ "$(hostname)" == 'prospero' ]; then
	while [ 1 ]; do
		if gnome-screensaver-command -q | grep -q "inactive"; then
			scrot -q 100 "$(date +%Y-%m-%d-%H%M%S).jpg"
		fi
		sleep 10
	done
fi

while [ 1 ]; do
	if gnome-screensaver-command -q | grep -q "inactive"; then
		import -silent -window root -crop 1920x1080+0+0 "$(date +%Y-%m-%d-%H%M%S).jpg"
	fi
	sleep 10
done

exit 1
