#!/bin/bash
# Sets up .bashrc

# Increase and modify Bash history logs
export HISTTIMEFORMAT="%h %d %H:%M:%S "
export HISTSIZE=1000000
export HISTFILESIZE=1000000
shopt -s histappend
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:la:lla"

