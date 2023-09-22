#!/bin/bash

# First create and navigate to the timelapse folder
timelapse_directory="$HOME/Pictures/timelapse"
if [ ! -d "$timelapse_directory" ]; then
	echo "Timelapse directory does not exist. Creating it..."
	mkdir -p "$timelapse_directory"
fi
cd "$timelapse_directory"

# Next, create and navigate to a folder named with the current timestamp
var_time=$(date +%Y-%m-%d-%H%M%S)
mkdir $var_time
cd "./$var_time"

# Confirm that the grim command is available
if ! [ -x "$(command -v grim)" ]; then
	echo 'Error: grim is not installed.' >&2
	exit 1
fi

# TODO check for HDMI-A-1 output device in xrandr, create mayhem or a warning if not
while [ 1 ]; do
	grim -o HDMI-A-1 $(date +%Y-%m-%d-%H%M%S).jpg	
	sleep 10;
done

exit 1

## The code below is outdated and was written for back when I was running gnome.
# I'm only keeping it there for reference
# First check if running gnome
if ! [ -x "$(command -v gnome-screensaver-command)" ]; then
  echo 'Error: gnome-screensaver-command is not installed.' >&2
  exit 1
fi

if [ `hostname` == 'prospero' ]; then
	while [ 1 ]; do
		if gnome-screensaver-command -q | grep -q "inactive" ; then
			scrot -q 100 $(date +%Y-%m-%d-%H%M%S).jpg;
		fi
		sleep 10;
	done
fi

# Now take pictures every 10 seconds
while [ 1 ]; do 
	if gnome-screensaver-command -q | grep -q "inactive" ; then
		# TODO branch for laptop vs. desktop or generalize for different screens
		import -silent -window root -crop 1920x1080+0+0 "`date +%Y-%m-%d-%H%M%S`.jpg"
	fi
	sleep 10;
done

