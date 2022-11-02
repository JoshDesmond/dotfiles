#!/bin/bash
killall pulseaudio; pulseaudio -k
pulseaudio --start
