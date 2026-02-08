#!/bin/bash

timelapse_directory="$HOME/Pictures/timelapse"
mkdir -p $timelapse_directory
cd $timelapse_directory
var_time=$(date +%Y-%m-%d-%H%M%S)
mkdir $var_time
cd "./$var_time"

# Now take pictures every 10 seconds
while [ 1 ]; do
	if osascript -e 'tell application "ScreenSaverEngine" to get name' >/dev/null 2>&1; then
		# TODO branch for laptop vs. desktop or generalize for different screens
		screencapture -R 0,0,1920,1080 -x "`date +%Y-%m-%d-%H%M%S`.jpg"
	fi
	sleep 10;
done

exit 1
