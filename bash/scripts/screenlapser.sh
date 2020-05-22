#!/bin/bash

# First create and navigate to a new folder
cd ~/Pictures/timelapse # TODO refactor with other photo scripts
var_time=$(date +%Y-%m-%d-%H%M%S)
mkdir $var_time
cd "./$var_time"

# Now take pictures every 1 second
while [ 1 ]; do scrot --silent -q 100 $(date +%Y-%m-%d-%H%M%S).jpg; sleep 4; done

# TODO move files to the media drive or data drive, perform encoding.
