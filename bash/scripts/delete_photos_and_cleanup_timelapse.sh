#!/bin/bash

path_timelapse_dir="$HOME/Pictures/timelapse"
path_mutex="$path_timelapse_dir/mutex"

if [ -f "$path_mutex" ]; then
	echo "file $path_mutex found, printing\
	contents and exiting"
	cat $path_mutex
	exit 1
fi

printf "Starting" > "$path_mutex"
pushd $path_timelapse_dir

path_files="$path_timelapse_dir/files.txt"
if ! [ -f "$path_files" ]; then
	echo "$path_files not found, hmmm..."
	exit 1
fi



# Make a backup of files.txt, use the file name of the latest video that was created (gzip the file)
# Copy the video file that was created to the media drive
# Delete all of the files that were listed in files.txt
# Delete files.txt
# Remind user to clear the recycling bin
# remove the "mutex" lock in the folder.

# Bonus: Print the length of the video, the number of photos that are being deleted, and the first and last
# timestamps of photos and add a confirmation dialogue to the user before executing any data deletion

rm $path_mutex

popd
