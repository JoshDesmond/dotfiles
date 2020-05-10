#!/bin/bash
# Sets up .bashrc

# TODO grep ~/.bashrc and check for "/.bash_personal" so you can know if it's already a thing

printf "\n\n" >> ~/.bashrc
printf "source $PWD/.bash_personal_aliases\n" >> ~/.bashrc
printf "source $PWD/.bash_personal_config\n\n" >> ~/.bashrc

