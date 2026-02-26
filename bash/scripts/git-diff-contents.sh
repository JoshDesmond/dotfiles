#!/usr/bin/env bash
# git-diff-contents — Print the contents of files changed in the current git diff.
#
# Usage:
#   git-diff-contents              # diff against HEAD (unstaged + staged)
#   git-diff-contents main         # diff against a branch/commit
#   git-diff-contents HEAD~3       # diff against 3 commits ago

set -euo pipefail

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

