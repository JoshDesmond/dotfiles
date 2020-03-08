#!/bin/bash
# Sets up an SSH key for the user.

SSH_DIRECTORY=~/.ssh
SSH_DEFAULT_KEY=~/.ssh/id_rsa.pub
SSH_DEFAULT_KEY_PRIVATE=~/.ssh/id_rsa

if [ -d "$SSH_DIRECTORY" ]; then
	echo "Note: the ~/.ssh/ folder already exists, printing contents:"
	ls -al $SSH_DIRECTORY
fi

if [ -f "$SSH_DEFAULT_KEY" ]; then
	echo "Error: Default key already exists, printing contents:"
	cat $SSH_DEFAULT_KEY
	echo "You can test whether it is password protected with ssh-keygen -p -f $SSH_DEFAULT_KEY"
	exit 2
fi	

ssh-keygen -t rsa -b 4096 -C "JoshDesmond@users.noreply.github.com"
ssh-add "$SSH_DEFAULT_KEY_PRIVATE"

echo
echo "Created new key $SSH_DEFAULT_KEY"

