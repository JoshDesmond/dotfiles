#!/bin/bash

# Run this script to copy the configuration files to their location and have
# regolith reload the configuration

echo Setting up regolith configuration

CONFIG_DIRECTORY=~/.config/regolith2/
if [ -d "$CONFIG_DIRECTORY" ]; then
	cp ./Xresources ~/.config/regolith2/Xresources
	mkdir picom 2> /dev/null
	cp ./picom.config ~/.config/regolith2/picom/config
	regolith-look refresh

else
	echo "Regolith Configuration directory $CONFIG_DIRECTORY not found"
	echo "Aborting script..."
fi
