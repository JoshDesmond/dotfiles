#!/bin/bash

# Check if a word is provided as an argument
if [ -z "$1" ]; then
    echo "Error: No word provided."
    exit 1
fi

# Read the word from the command line argument
word="$1"

# Sort the characters of the word in alphabetical order
sorted_word=$(echo "$word" | grep -o . | sort | tr -d '\n')

# Print the sorted word
echo "$sorted_word"

