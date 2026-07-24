#!/usr/bin/env bash
# git-branch-detect-redundant.sh — Check whether a branch is redundant relative to main.
#
# Usage: git-branch-detect-redundant <branch> [options]
#   branch           Local or remote branch (e.g. feature/foo, origin/feature/foo).
#   --base, -b REF   Base branch to compare against (default: main).
#   --help, -h       Print this help and exit.
#
# First checks whether every commit on the branch is reachable from the base.
# If not, runs a three-dot diff (base...branch) to detect unique file changes —
# including squash-merged branches whose commits differ but content is already in base.
#
# Exit status: 0 if redundant, 1 if unique commits or diff remain, 2 on error.

set -euo pipefail

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

readonly SCRIPT_NAME="git-branch-detect-redundant"
BASE_REF="main"
BRANCH_ARG=""

usage() {
	echo "Usage: ${SCRIPT_NAME} <branch> [--base REF]" >&2
	echo "Try '${SCRIPT_NAME} --help'." >&2
}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
	echo "${SCRIPT_NAME}: not inside a git repository." >&2
	exit 2
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--base|-b)
		[[ $# -ge 2 ]] || {
			echo "${SCRIPT_NAME}: --base requires a ref." >&2
			exit 2
		}
		BASE_REF="$2"
		shift 2
		;;
	--*)
		echo "${SCRIPT_NAME}: unknown option: $1" >&2
		usage
		exit 2
		;;
	*)
		if [[ -n "$BRANCH_ARG" ]]; then
			echo "${SCRIPT_NAME}: unexpected argument: $1" >&2
			usage
			exit 2
		fi
		BRANCH_ARG="$1"
		shift
		;;
	esac
done

[[ -n "$BRANCH_ARG" ]] || {
	echo "${SCRIPT_NAME}: branch name required." >&2
	usage
	exit 2
}

# ── Ref resolution ─────────────────────────────────────────────────────

resolve_ref() {
	local name="$1"
	local candidate

	for candidate in \
		"$name" \
		"refs/heads/$name" \
		"refs/remotes/$name" \
		"refs/remotes/origin/$name" \
		"origin/$name"; do
		if git rev-parse --verify --quiet "$candidate" >/dev/null 2>&1; then
			printf '%s' "$candidate"
			return 0
		fi
	done

	return 1
}

display_ref() {
	local ref="$1"
	local short

	short="$(git rev-parse --abbrev-ref "$ref" 2>/dev/null || true)"
	if [[ -n "$short" && "$short" != "HEAD" ]]; then
		printf '%s' "$short"
		return
	fi

	case "$ref" in
	refs/heads/*)
		printf '%s' "${ref#refs/heads/}"
		;;
	refs/remotes/*)
		printf '%s' "${ref#refs/}"
		;;
	*)
		printf '%s' "$ref"
		;;
	esac
}

# ── Analysis ───────────────────────────────────────────────────────────

readonly MAX_COMMITS_SHOWN=15

print_unique_commits() {
	local base="$1" branch="$2"
	local commits total

	total="$(git rev-list --count "${base}..${branch}")"
	commits="$(git log --oneline -n "$MAX_COMMITS_SHOWN" "${base}..${branch}" 2>/dev/null || true)"
	if [[ -z "$commits" ]]; then
		return 1
	fi

	echo "$commits"
	if ((total > MAX_COMMITS_SHOWN)); then
		echo "... and $((total - MAX_COMMITS_SHOWN)) more commit(s)"
	fi
	return 0
}

print_diff_stat() {
	local base="$1" branch="$2"

	git diff --stat "${base}...${branch}"
}

has_unique_diff() {
	local base="$1" branch="$2"

	! git diff --quiet "${base}...${branch}"
}

# ── Main ───────────────────────────────────────────────────────────────

main() {
	local base_ref branch_ref base_display branch_display
	local commit_count commits

	base_ref="$(resolve_ref "$BASE_REF")" || {
		echo "${SCRIPT_NAME}: base ref not found: ${BASE_REF}" >&2
		exit 2
	}
	branch_ref="$(resolve_ref "$BRANCH_ARG")" || {
		echo "${SCRIPT_NAME}: branch not found: ${BRANCH_ARG}" >&2
		exit 2
	}

	if [[ "$base_ref" == "$branch_ref" ]]; then
		echo "${SCRIPT_NAME}: branch and base are the same ref." >&2
		exit 2
	fi

	base_display="$(display_ref "$base_ref")"
	branch_display="$(display_ref "$branch_ref")"

	printf 'Branch: %s\n' "$branch_display"
	printf 'Base:   %s\n\n' "$base_display"

	commit_count="$(git rev-list --count "${base_ref}..${branch_ref}" 2>/dev/null || echo 0)"

	if [[ "$commit_count" -eq 0 ]]; then
		echo "Commit check: all commits are already in ${base_display}"
		echo "Verdict: REDUNDANT — safe to delete"
		exit 0
	fi

	echo "Commit check: ${commit_count} commit(s) on branch are NOT in ${base_display}"
	commits="$(print_unique_commits "$base_ref" "$branch_ref")"
	if [[ -n "$commits" ]]; then
		echo "$commits" | sed 's/^/  /'
	fi
	echo ""

	printf 'Diff check (%s...%s):\n' "$base_display" "$branch_display"
	if has_unique_diff "$base_ref" "$branch_ref"; then
		echo "  UNIQUE CHANGES FOUND"
		echo ""
		print_diff_stat "$base_ref" "$branch_ref" | sed 's/^/  /'
		echo ""
		echo "Review the full diff:"
		printf '  git diff %s...%s\n' "$base_display" "$branch_display"
		echo ""
		echo "See unique commits:"
		printf '  git log --oneline %s..%s\n' "$base_display" "$branch_display"
		echo ""
		echo "Verdict: NOT REDUNDANT — review before deleting"
		exit 1
	fi

	echo "  no unique file changes (content likely already in ${base_display}, e.g. squash-merge)"
	echo ""
	echo "Verdict: REDUNDANT — commit history differs but changes appear to be in base"
	exit 0
}

main
