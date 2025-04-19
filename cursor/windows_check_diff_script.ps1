# Simple script to compare keybindings.json files for Cursor
# Usage: .\windows_check_diff_script.ps1

# Define paths - adjust as needed
$cursorPath = "~\AppData\Roaming\Cursor\User\keybindings.json"
$dotfilesPath = "~\code\dotfiles\cursor\keybindings.json"

# Expand paths (handle ~ correctly)
$cursorPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($cursorPath)
$dotfilesPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($dotfilesPath)

# Check if Cursor keybindings file exists
if (-not (Test-Path $cursorPath)) {
    Write-Warning "No Cursor keybindings found at: $cursorPath"
    exit 1
}

# Check if dotfiles keybindings file exists
if (-not (Test-Path $dotfilesPath)) {
    Write-Warning "No dotfiles keybindings found at: $dotfilesPath"
    exit 1
}

# Compare the files and output diff in a clean format
$diff = Compare-Object (Get-Content $cursorPath) (Get-Content $dotfilesPath) -PassThru

# If no differences, say so
if ($null -eq $diff) {
    Write-Output "Files are identical."
    exit 0
}

# Output differences in a clean, pipe-able format
Write-Output "# Differences between keybindings files:"
$diff | Format-Table -Property InputObject, SideIndicator
