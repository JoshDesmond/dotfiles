#!/bin/bash

if ! [ -x "$(command -v nvidia-settings)" ]; then
	echo 'Error: nvidia-settings command was not found.' >&2
	exit 1
fi

script_fan_name=$(nvidia-settings -q fans | grep FAN-0)
if [ -z "$script_fan_name" ] ; then
	echo 'Error: FAN-0 not found, try altering this script to use:'
	echo `nvidia-settings -q fans`
	exit 1
fi

nvidia-settings --assign=GPUTargetFanSpeed[FAN-0]=50
exit 0
