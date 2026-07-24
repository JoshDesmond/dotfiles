#!/usr/bin/env bash
# git-branches-by-age.sh — List local and remote git branches sorted by last commit date.
#
# Usage: git-branches-by-age [options]
#   (no options)     Oldest branches first (stale branches rise to the top).
#   --newest-first,
#   -n               Newest branches first.
#   --local, -l      Local branches only.
#   --remote, -r     Remote-tracking branches only.
#   --help, -h       Print this help and exit.
#
# Must be run inside a git repository. Skips symbolic refs such as origin/HEAD.

set -euo pipefail

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

SORT_ORDER="committerdate"
REF_SPECS=(refs/heads refs/remotes)

while [[ $# -gt 0 ]]; do
	case "$1" in
	--newest-first|-n)
		SORT_ORDER="-committerdate"
		;;
	--local|-l)
		REF_SPECS=(refs/heads)
		;;
	--remote|-r)
		REF_SPECS=(refs/remotes)
		;;
	*)
		echo "git-branches-by-age: unknown option: $1" >&2
		echo "Try 'git-branches-by-age --help'." >&2
		exit 1
		;;
	esac
	shift
done

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
	echo "git-branches-by-age: not inside a git repository." >&2
	exit 1
}

# ── Output ─────────────────────────────────────────────────────────────

branch_label() {
	local refname="$1"
	case "$refname" in
	refs/heads/*)
		printf '  %s' "${refname#refs/heads/}"
		;;
	refs/remotes/*)
		printf '  %s' "${refname#refs/}"
		;;
	*)
		printf '  %s' "$refname"
		;;
	esac
}

print_branches() {
	local date relative refname head_marker label

	while IFS=$'\t' read -r date relative refname head_marker; do
		[[ "$refname" == refs/remotes/*/HEAD ]] && continue

		label="$(branch_label "$refname")"
		if [[ "$head_marker" == "*" ]]; then
			label="${label/#  /  * }"
		fi

		printf '%-10s  %-16s  %s\n' "$date" "$relative" "$label"
	done < <(
		git for-each-ref \
			--sort="$SORT_ORDER" \
			--format='%(committerdate:short)	%(committerdate:relative)	%(refname)	%(HEAD)' \
			"${REF_SPECS[@]}"
	)
}

# ── Main ───────────────────────────────────────────────────────────────

main() {
	printf '%-10s  %-16s  %s\n' "DATE" "LAST COMMIT" "BRANCH"
	print_branches
}

main
