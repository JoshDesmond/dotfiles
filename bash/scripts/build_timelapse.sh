#!/usr/bin/env bash
# build_timelapse.sh — Build a timelapse video from ~/Pictures/timelapse subfolders into an mp4 using mencoder.
#
# Usage: build_timelapse.sh
#   --help, -h  Print this help and exit.
#
# Writes files.txt, runs mencoder with fixed 1920x1080 @ 60fps settings. Changes cwd under Pictures/timelapse.

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

pushd ~/Pictures/timelapse/ || exit 1

printf "" >files.txt

for f in ./*; do
	if [ -d "$f" ]; then
		cd "$f" || exit 1
		SCRIPT_NUM_JPGS=$(ls -1tr *.jpg 2>/dev/null | wc -l)
		echo "Cataloging $SCRIPT_NUM_JPGS .jpgs from $PWD into ../files.txt"
		ls -1tr "$PWD"/*.jpg >>../files.txt 2>/dev/null
		cd .. || exit 1
	fi
done

SCRIPT_TOTAL_NUM_SCREENSHOTS=$(wc -l <./files.txt)

echo "files.txt created, beginning sorting of $SCRIPT_TOTAL_NUM_SCREENSHOTS image files"

sort files.txt >/dev/null

echo "sorting finished, running encoder command:"
echo "mencoder -noskip -ovc x264 -x264encopts subq=7:frameref=4:threads=auto:qcomp=0.9 -mf
w=1920:h=1080:fps=60:type=jpg 'mf://@files.txt' -o \"$(date +%F%H)-screenlapse.mp4\""

mencoder -noskip -ovc x264 -x264encopts subq=7:frameref=4:threads=auto:qcomp=0.9 -mf w=1920:h=1080:fps=60:type=jpg 'mf://@files.txt' -o "$(date +%F%H)-screenlapse.mp4"

popd || true
