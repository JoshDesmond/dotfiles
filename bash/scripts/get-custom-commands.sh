#!/usr/bin/env bash
# get-custom-commands.sh — List dotfiles bash scripts, aliases, and functions.
#
# Usage: get-custom-commands [options]
#   (no options)  Compact table sized to the terminal (tput cols).
#   --full, -f    Full paths and complete detail (no column truncation).
#   --help, -h    Print this help and exit.

set -euo pipefail

case "${1:-}" in
--help|-h)
	awk 'NR==1{next} /^#/{sub(/^#[[:space:]]*/, ""); print; next} {exit}' "$0"
	exit 0
	;;
esac

FULL_OUTPUT=0
case "${1:-}" in
--full|-f) FULL_OUTPUT=1 ;;
"") ;;
*)
	echo "get-custom-commands: unknown option: ${1}" >&2
	echo "Try 'get-custom-commands --help'." >&2
	exit 1
	;;
esac

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_BASH="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly CONFIG_FILES=(
	"${DOTFILES_BASH}/.bash_personal_aliases"
	"${DOTFILES_BASH}/.bash_personal_config"
)

# ── Output ─────────────────────────────────────────────────────────────

term_cols() {
	local c
	c="$(tput cols 2>/dev/null || true)"
	if [[ -n "$c" && "$c" =~ ^[0-9]+$ && "$c" -gt 0 ]]; then
		echo "$c"
	elif [[ -n "${COLUMNS:-}" && "${COLUMNS}" =~ ^[0-9]+$ ]]; then
		echo "${COLUMNS}"
	else
		echo 80
	fi
}

# Truncate string to max runes (bytes for ASCII); append ellipsis when shortened.
truncate_str() {
	local text="$1" max="$2"
	if ((${#text} <= max)); then
		printf '%s' "$text"
	elif ((max < 2)); then
		printf '%s' "${text:0:max}"
	else
		printf '%s…' "${text:0:max-1}"
	fi
}

config_basename() {
	printf '%s' "$(basename "$1")"
}

print_table() {
	local cols type_w=10 name_max detail_max
	local type name detail line

	cols="$(term_cols)"
	# Reserve space for TYPE, NAME, DETAIL, tabs, and a little margin.
	name_max=$(( (cols - type_w) / 3 ))
	((name_max < 14)) && name_max=14
	((name_max > 36)) && name_max=36
	detail_max=$((cols - type_w - name_max - 3))
	((detail_max < 16)) && detail_max=16

	{
		printf '%s\t%s\t%s\n' "TYPE" "NAME" "DETAIL"
		while IFS= read -r line; do
			[[ -n "$line" ]] || continue
			IFS='|' read -r type name detail <<< "$line"
			if ((FULL_OUTPUT == 0)); then
				name="$(truncate_str "$name" "$name_max")"
				detail="$(truncate_str "$detail" "$detail_max")"
			fi
			printf '%s\t%s\t%s\n' "$type" "$name" "$detail"
		done
	} | column -t -s $'\t'

	if ((FULL_OUTPUT == 0)); then
		printf '\n(%s columns — use --full for paths and complete detail)\n' "$(term_cols)"
	fi
}

emit_row() {
	printf '%s|%s|%s\n' "$1" "$2" "$3"
}

# ── Scripts (bash/scripts) ─────────────────────────────────────────────

scripts_on_path() {
	local scripts_dir="$1"
	case ":${PATH}:" in
		*":${scripts_dir}:"*) return 0 ;;
		*) return 1 ;;
	esac
}

join_parts() {
	local joined="$1" part
	shift
	for part in "$@"; do
		joined+=" · ${part}"
	done
	printf '%s' "$joined"
}

script_detail() {
	local f="$1" in_path="$2"
	local -a parts=()

	if [[ -x "$f" ]]; then
		parts=("executable" "alias")
	else
		parts=("not executable")
	fi
	if [[ "$in_path" == yes ]]; then
		parts+=("on PATH")
	else
		parts+=("not on PATH")
	fi

	if ((FULL_OUTPUT)); then
		printf '%s · %s' "$f" "$(join_parts "${parts[@]}")"
	else
		join_parts "${parts[@]}"
	fi
}

collect_scripts() {
	local scripts_dir="${DOTFILES_BASH}/scripts"
	local f base detail in_path

	if [[ ! -d "$scripts_dir" ]]; then
		return
	fi

	if scripts_on_path "$scripts_dir"; then
		in_path="yes"
	else
		in_path="no"
	fi

	for f in "$scripts_dir"/*.sh; do
		[[ -f "$f" ]] || continue
		base="$(basename "$f" .sh)"
		detail="$(script_detail "$f" "$in_path")"
		emit_row "script" "$base" "$detail"
	done
}

# ── Parse aliases / functions from config files ────────────────────────

strip_comments() {
	sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$1"
}

is_auto_script_alias() {
	local value="$1"
	[[ "$value" == *"${DOTFILES_BASH}/scripts/"*.sh ]] \
		|| [[ "$value" == *"/bash/scripts/"*.sh ]]
}

alias_detail() {
	local value="$1" file="$2"
	if ((FULL_OUTPUT)); then
		printf '%s (%s)' "$value" "$file"
	else
		printf '→ %s [%s]' "$value" "$(config_basename "$file")"
	fi
}

collect_aliases_from_file() {
	local file="$1"
	local line name value

	[[ -f "$file" ]] || return

	while IFS= read -r line; do
		[[ "$line" =~ ^[[:space:]]*alias[[:space:]]+([^=[:space:]]+)= ]] || continue
		name="${BASH_REMATCH[1]}"
		value="${line#*=}"
		value="${value#"${value%%[![:space:]]*}"}"
		value="${value%"${value##*[![:space:]]}"}"
		value="${value#\'}"
		value="${value%\'}"
		value="${value#\"}"
		value="${value%\"}"

		if is_auto_script_alias "$value"; then
			continue
		fi

		emit_row "alias" "$name" "$(alias_detail "$value" "$file")"
	done < <(strip_comments "$file" | grep -E '^[[:space:]]*alias[[:space:]]+' || true)
}

function_detail() {
	local file="$1"
	if ((FULL_OUTPUT)); then
		printf '%s' "$file"
	else
		config_basename "$file"
	fi
}

collect_functions_from_file() {
	local file="$1"
	local line name

	[[ -f "$file" ]] || return

	while IFS= read -r line; do
		if [[ "$line" =~ ^[[:space:]]*function[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
			name="${BASH_REMATCH[1]}"
			emit_row "function" "$name" "$(function_detail "$file")"
			continue
		fi
		if [[ "$line" =~ ^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)\(\)[[:space:]]*\{ ]]; then
			name="${BASH_REMATCH[1]}"
			emit_row "function" "$name" "$(function_detail "$file")"
		fi
	done < <(strip_comments "$file")
}

config_file_already_parsed() {
	local target="$1"
	local config
	for config in "${CONFIG_FILES[@]}"; do
		[[ "$config" -ef "$target" ]] && return 0
	done
	return 1
}

collect_from_bashrc_sources() {
	local bashrc="${HOME}/.bashrc"
	local profile="${HOME}/.bash_profile"
	local rc_file line path

	for rc_file in "$bashrc" "$profile"; do
		[[ -f "$rc_file" ]] || continue
		while IFS= read -r line; do
			[[ "$line" =~ ^[[:space:]]*(source|\.)[[:space:]]+(.+)$ ]] || continue
			path="${BASH_REMATCH[2]}"
			path="${path%%#*}"
			path="${path%"${path##*[![:space:]]}"}"
			path="${path#"${path%%[![:space:]]*}"}"
			path="${path%\"}"
			path="${path#\"}"
			path="${path%\'}"
			path="${path#\'}"

			[[ -f "$path" ]] || continue
			config_file_already_parsed "$path" && continue
			case "$path" in
				"${DOTFILES_BASH}"/*)
					collect_aliases_from_file "$path"
					collect_functions_from_file "$path"
					;;
			esac
		done < <(strip_comments "$rc_file" | grep -E '^[[:space:]]*(source|\.)[[:space:]]+' || true)
	done
}

# ── Main ───────────────────────────────────────────────────────────────

main() {
	local rows

	rows="$(
		collect_scripts
		for config in "${CONFIG_FILES[@]}"; do
			collect_aliases_from_file "$config"
			collect_functions_from_file "$config"
		done
		collect_from_bashrc_sources
	)"

	if [[ -z "$rows" ]]; then
		echo "No custom commands found under ${DOTFILES_BASH}."
		exit 0
	fi

	print_table <<< "$(printf '%s\n' "$rows" | sort -t'|' -k2,2 -k1,1)"
}

main
