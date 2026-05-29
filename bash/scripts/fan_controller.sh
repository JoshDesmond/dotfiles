#!/usr/bin/env bash
# fan_controller.sh — Set NVIDIA GPU fan FAN-0 to a fixed speed via nvidia-settings.
#
# Usage: fan_controller.sh
#   --help, -h  Print this help and exit.
#
# Requires nvidia-settings and a visible FAN-0; edit the script to adjust speed or fan query.

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

if ! [ -x "$(command -v nvidia-settings)" ]; then
	echo 'Error: nvidia-settings command was not found.' >&2
	exit 1
fi

script_fan_name=$(nvidia-settings -q fans | grep FAN-0)
if [ -z "$script_fan_name" ]; then
	echo 'Error: FAN-0 not found, try altering this script to use:'
	nvidia-settings -q fans
	exit 1
fi

nvidia-settings --assign=GPUTargetFanSpeed[FAN-0]=50
exit 0
