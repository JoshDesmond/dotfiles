#!/bin/bash
# Cross-platform package installer.
# Replaces the older bash/install_scripts.sh TODO with a strategy-pattern
# dispatch based on `uname` / distro detection.
#
# Usage:
#   ./install_packages.sh                # installs the default package list
#   ./install_packages.sh git curl wget  # installs the given packages
#
# Can also be sourced to expose `install_packages` for other scripts:
#   source bash/install_packages.sh && install_packages git curl

# Default packages installed across all platforms when no args are passed.
# Keep this list short -- per-tool setup scripts handle their own deps.
DEFAULT_PACKAGES=(
	git
	openssh-client
	keychain
	age
	imagemagick
	gnome-screensaver
)

detect_os() {
	# Echoes one of: darwin, arch, debian, unknown
	case "$(uname -s)" in
		Darwin) echo "darwin" ;;
		Linux)
			if [ -f /etc/arch-release ]; then
				echo "arch"
			elif [ -f /etc/debian_version ]; then
				echo "debian"
			else
				echo "unknown"
			fi
			;;
		*) echo "unknown" ;;
	esac
}

# Map cross-platform package names to platform-specific equivalents.
# Most names line up, only translate the known mismatches.
map_package() {
	local pkg="$1"
	local os="$2"
	case "$os:$pkg" in
		# openssh-client is the apt name; arch/brew ship it as `openssh`
		arch:openssh-client)   echo "openssh" ;;
		darwin:openssh-client) echo "openssh" ;;
		# gnome-screensaver isn't available on macOS; skip it there
		darwin:gnome-screensaver) echo "" ;;
		# TODO untested: arch may not have gnome-screensaver in the default repos
		arch:gnome-screensaver) echo "gnome-screensaver" ;;
		*) echo "$pkg" ;;
	esac
}

install_packages() {
	local os
	os="$(detect_os)"
	local pkgs=("$@")
	if [ ${#pkgs[@]} -eq 0 ]; then
		pkgs=("${DEFAULT_PACKAGES[@]}")
	fi

	# Translate package names per OS, dropping any that map to empty.
	local mapped=()
	local p mapped_name
	for p in "${pkgs[@]}"; do
		mapped_name="$(map_package "$p" "$os")"
		if [ -n "$mapped_name" ]; then
			mapped+=("$mapped_name")
		fi
	done

	echo "Installing packages on '$os': ${mapped[*]}"

	case "$os" in
		debian)
			sudo apt-get --assume-yes update
			sudo apt-get --assume-yes install "${mapped[@]}"
			;;
		arch)
			# TODO untested on a real Arch system
			sudo pacman -Sy --noconfirm --needed "${mapped[@]}"
			;;
		darwin)
			# TODO untested on macOS
			if ! command -v brew >/dev/null 2>&1; then
				echo "Error: Homebrew not installed. See https://brew.sh/"
				return 1
			fi
			brew install "${mapped[@]}"
			;;
		*)
			echo "Error: unsupported OS '$(uname -a)'. Install manually: ${mapped[*]}"
			return 1
			;;
	esac
}

# Only auto-run when executed directly (not when sourced).
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	install_packages "$@"
fi
