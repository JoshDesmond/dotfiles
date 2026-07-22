# Setup-Git.ps1 — Point the system git config at the dotfiles git config.
#
# Sets ~/.gitconfig to include git/.gitconfig from this repo.
# Optionally sets the dotfiles repo origin remote to SSH.
#
# Usage:
#   ./git/Setup-Git.ps1

param(
	[switch]$Help
)

$HelpText = @'
Setup-Git.ps1 — Point the system git config at the dotfiles git config.

Sets ~/.gitconfig to include git/.gitconfig from this repo.
Optionally sets the dotfiles repo origin remote to SSH.

Usage:
  ./git/Setup-Git.ps1
'@

if ($Help) {
	Write-Output $HelpText
	exit 0
}

# Resolve paths for the system git config, dotfiles git config, and dotfiles root
$GitDir = $PSScriptRoot
$DotfilesRoot = Split-Path $GitDir -Parent
$SystemGitconfig = Join-Path $HOME ".gitconfig"
$DotfilesGitconfig = Join-Path $GitDir ".gitconfig"
$DotfilesGitconfigPath = ($DotfilesGitconfig -replace '\\', '/')
$SystemGitconfigHeader = "# Managed by dotfiles git/Setup-Git.ps1."

# Verify the dotfiles git config exists before pointing the system config at it
if (-not (Test-Path $DotfilesGitconfig)) {
	Write-Error "Dotfiles git config not found at $DotfilesGitconfig"
	exit 1
}

# Skip setup if the system git config already points at the dotfiles git config
if ((Test-Path $SystemGitconfig) -and (Select-String -Path $SystemGitconfig -Pattern ([regex]::Escape($DotfilesGitconfigPath)) -Quiet)) {
	Write-Host "$SystemGitconfig already points at the dotfiles git config:"
	Write-Host "======== $SystemGitconfig ========"
	Get-Content $SystemGitconfig
	Write-Host "==================================="
} else {
	# Back up the existing system git config before replacing it
	if (Test-Path $SystemGitconfig) {
		$Timestamp = Get-Date -Format "yyyyMMddHHmmss"
		$Backup = "$SystemGitconfig.bak.$Timestamp"
		Write-Host "Backing up existing $SystemGitconfig to $Backup"
		Copy-Item $SystemGitconfig $Backup
	}

	# Point the system git config at the dotfiles git config
	$SystemGitconfigContent = @"
$SystemGitconfigHeader
[include]
	path = $DotfilesGitconfigPath
"@
	Set-Content -Path $SystemGitconfig -Value $SystemGitconfigContent -Encoding utf8
	Write-Host "Wrote $SystemGitconfig"
}

# Point the dotfiles repo origin at GitHub over SSH when run from the repo
if (Test-Path (Join-Path $DotfilesRoot ".git")) {
	git -C $DotfilesRoot remote set-url origin "git@github.com:JoshDesmond/dotfiles.git"
	Write-Host "Set dotfiles origin remote to git@github.com:JoshDesmond/dotfiles.git"
}

Write-Host "Git setup complete."
