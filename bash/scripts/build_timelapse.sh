#!/bin/bash
pushd ~/Pictures/timelapse/

printf "" > files.txt

for f in ./*
do
	if [ -d "$f" ]; then
		cd $f
		pwd
		ls -1trd $PWD/*.jpg >> ../files.txt
		cd ..
	fi
done

echo "files.txt created, beginning sorting"

sort files.txt >/dev/null

echo "sorting finished"

mencoder -ovc x264 -mf w=1920:h=1080:fps=60:type=jpg 'mf://@files.txt' -o "$(date +%F%H)-screenlapse.avi"

popd
