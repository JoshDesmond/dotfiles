#!/bin/bash
pushd ~/Pictures/timelapse/

printf "" > files.txt

for f in ./*
do
	if [ -d "$f" ]; then
		cd "$f"
		SCRIPT_NUM_JPGS=$(ls -1tr *.jpg | wc -l)
		echo "Cataloging $SCRIPT_NUM_JPGS .jpgs from $PWD into ../files.txt"
		ls -1tr $PWD/*.jpg >> ../files.txt
		cd ..
	fi
done

SCRIPT_TOTAL_NUM_SCREENSHOTS=$(wc -l ./files.txt)

echo "files.txt created, beginning sorting of $SCRIPT_TOTAL_NUM_SCREENSHOTS image files"

sort files.txt >/dev/null

echo "sorting finished, running encoder command:"
echo "mencoder -noskip -ovc x264 -x264encopts subq=7:frameref=4:threads=auto:qcomp=0.9 -mf w=1920:h=1080:fps=60:type=jpg 'mf://@files.txt' -o \"$(date +%F%H)-screenlapse.avi\""


# mencoder -ovc x264 -mf w=1920:h=1080:fps=60:type=jpg 'mf://@files.txt' -o
# "$(date +%F%H)-screenlapse.avi" # this was the original command
mencoder -noskip -ovc x264 -x264encopts subq=7:frameref=4:threads=auto:qcomp=0.9 -mf w=1920:h=1080:fps=60:type=jpg 'mf://@files.txt' -o "$(date +%F%H)-screenlapse.mp4"

popd
