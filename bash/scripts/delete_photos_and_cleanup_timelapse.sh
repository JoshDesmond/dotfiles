#!/usr/bin/env bash
# delete_photos_and_cleanup_timelapse.sh — After a timelapse build, archive files.txt, optionally copy the latest mp4, gzip the list, and delete listed JPEGs.
#
# Usage: delete_photos_and_cleanup_timelapse.sh
#   --help, -h  Print this help and exit.
#
# Uses a mutex file under ~/Pictures/timelapse. Expects machine-specific paths (e.g. NuData backup). Review before running on a new host.

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

path_timelapse_dir="$HOME/Pictures/timelapse"
path_mutex="$path_timelapse_dir/mutex"

if [ -f "$path_mutex" ]; then
	echo "file $path_mutex found, printing \
contents and exiting"
	cat "$path_mutex"
	exit 1
fi

printf "Starting" >"$path_mutex"
pushd "$path_timelapse_dir" || exit 1

path_files="$path_timelapse_dir/files.txt"
if ! [ -f "$path_files" ]; then
	echo "$path_files not found, hmmm..."
	exit 1
fi

last_files_file=$(basename "$(tail -n 1 "$path_files")")
last_files_date=${last_files_file%.*}
echo "$(tail -n 1 "$path_files") extracted to:"
echo "$last_files_date"
new_files="$path_timelapse_dir/$last_files_date-files.txt"
echo "renaming files to $new_files" >"$path_mutex"
cp "$path_files" "$new_files"

nudata="/media/viridian/NuData/"

if ! [ -d "$nudata" ]; then
	echo "NuData not found, attempting mount"
	udisksctl mount --block-device /dev/sdb2
fi
if ! [ -d "$nudata" ]; then
	echo "Error: NuData not found, skipping \
backup routine"
else
	last_movie=$(ls -1t "$PWD"/*.mp4 2>/dev/null | head -n 1)
	echo "Last_movie_filename: $last_movie"
	echo "$last_movie" >>"$path_mutex"
fi

gzip "$new_files"

echo "deleting pictures in 3 seconds"
sleep 3
count=0
while IFS= read -r f; do
	count=$((count + 1))
	rm "$f"
done <"$path_files"

echo "Removed $count photos. (recycling)"

rm "$path_mutex"
# rm $path_files

popd || true
