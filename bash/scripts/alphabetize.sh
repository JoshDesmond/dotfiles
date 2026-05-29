#!/usr/bin/env bash
# alphabetize.sh — Print the letters of a word sorted alphabetically (one line, no separators).
#
# Usage: alphabetize <word>
#   --help, -h  Print this help and exit.
#
# Requires a non-empty word argument (after any help flag).

_script_help() {
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
}

case "${1:-}" in
--help|-h)
	_script_help
	exit 0
	;;
esac

if [ -z "${1:-}" ]; then
	_script_help >&2
	exit 1
fi

word="$1"
sorted_word=$(echo "$word" | grep -o . | sort | tr -d '\n')
echo "$sorted_word"
