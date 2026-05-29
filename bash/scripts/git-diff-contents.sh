#!/usr/bin/env bash
# git-diff-contents.sh — Print the contents of files changed in the current git diff (for review or AI context).
#
# Usage: git-diff-contents [ref]
#   ref         Compare against this commit, branch, or ref (default: HEAD).
#   --help, -h  Print this help and exit.
#
# Skips deleted paths and omits package-lock.json. Caps each file at 1000 lines.

set -euo pipefail

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

# ── Constants ──────────────────────────────────────────────────────────
readonly MAX_LINES=1000
readonly EXCLUDED_FILES="package-lock.json"
readonly DIFF_TARGET="${1:-HEAD}"
readonly REPO_ROOT="$(git rev-parse --show-toplevel)"

# ── Functions ──────────────────────────────────────────────────────────

# Get the list of changed files, filtering out deleted files and exclusions.
get_changed_files() {
	git diff --name-only --diff-filter=d "$DIFF_TARGET" \
		| grep -v -F "$EXCLUDED_FILES"
}

# Print a single file's contents, capped at MAX_LINES.
print_file() {
	local filepath="$1"

	echo "\`\`\`${filepath}"
	head -n "$MAX_LINES" "${REPO_ROOT}/${filepath}"
	echo '```'
	echo ""
}

# ── Main ───────────────────────────────────────────────────────────────
main() {
	local files
	files=$(get_changed_files) || true

	if [[ -z "$files" ]]; then
		echo "No changed files found (compared to ${DIFF_TARGET})."
		exit 0
	fi

	while IFS= read -r filepath; do
		print_file "$filepath"
	done <<< "$files"
}

main
