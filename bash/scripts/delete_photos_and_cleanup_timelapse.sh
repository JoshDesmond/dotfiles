#!/bin/bash

path_timelapse_dir="$HOME/Pictures/timelapse"
path_mutex="$path_timelapse_dir/mutex"

if [ -f "$path_mutex" ]; then
	echo "file $path_mutex found, printing \
\	contents and exiting"
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

last_files_file=$(basename $(tail -n 1 "$path_files"))
last_files_date=${last_files_file%.*}
echo "$(tail -n 1 "$path_files") extracted to:"
echo "$last_files_date"
new_files="$path_timelapse_dir/$last_files_date-files.txt"
echo "renaming files to $new_files" > "$path_mutex"
cp "$path_files" "$new_files" TODO TEMP uncomment

nudata="/media/viridian/NuData/"

if ! [ -d "$nudata" ]; then
	echo "NuData not found, attempting mount"
	udisksctl mount --block-device /dev/sdb2
fi
if ! [ -d "$nudata" ]; then
	echo "Error: NuData not found, skipping \
	backup routine"
	# TODO ??
else
	last_movie=$(ls -1t $PWD/*.mp4 | head -n 1)
	#last_movie_base=#TODO
	echo "Last_movie_filename: $last_movie"
	echo "$last_movie" >> "$path_mutex"
	# cp "$last_movie"\
	# "$nudata/Videos/timelapse/$last_movie_base"
fi

gzip "$new_files" TODO TEMP uncomment

# Delete all of the files that were listed in files.txt
count=0
for f in $(cat "$path_files"); do
	let "count=count+1"
	rm $f
done

echo "Removed $count photos. (recycling)"

# Bonus: Print the length of the video, the number of photos that are being deleted, and the first and last
# timestamps of photos and add a confirmation dialogue to the user before executing any data deletion

rm $path_mutex
# rm $path_files

popd
