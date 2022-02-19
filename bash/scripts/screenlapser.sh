#!/bin/bash

# First create and navigate to a new folder
timelapse_directory="~/Pictures/timelapse"
# TODO test if path doesn't exist
cd ~/Pictures/timelapse # TODO refactor with other photo scripts
var_time=$(date +%Y-%m-%d-%H%M%S)
mkdir $var_time
cd "./$var_time"

if ! [ -x "$(command -v gnome-screensaver-command)" ]; then
  echo 'Error: gnome-screensaver-command is not installed.' >&2
  exit 1
fi


# Now take pictures every 10 seconds
while [ 1 ]; do 
	if gnome-screensaver-command -q | grep -q "inactive" ; then
		scrot --silent -q 100 $(date +%Y-%m-%d-%H%M%S).jpg; 
	fi
	sleep 10;
done

exit 1
