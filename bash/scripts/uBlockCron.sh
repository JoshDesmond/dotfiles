#!/bin/bash

# If firefox is running, get its pid
pid=$(ps -a | grep firefox | cut -d' ' -f1)

if [ -n $pid ]
then
	pushd "/proc/$pid" > /dev/null
	uBlockGrep=$(timeout 0.3s grep "uBlock" -r 2> /dev/null)
	if [ -n "$uBlockGrep" ]
	then
		echo "No uBlock!"
	else
		echo "okie"
	fi

	popd > /dev/null
fi


