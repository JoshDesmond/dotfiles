# Simple script to manage Cursor keybindings on Windows
# Usage: .\powershell_cursor_keybindings.ps1 [check|copy]
# // TODO: Legacy copy workflow — migrate to powershell_cursor_symlinks.ps1 and remove this script.

param(
    [Parameter(Position = 0)]
    [ValidateSet("check", "copy")]
    [string]$Action = "check"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DotfilesPath = Join-Path $ScriptDir "keybindings.json"

# Common Cursor config locations on Windows
$CursorPaths = @(
    (Join-Path $env:APPDATA "Cursor\User/keybindings.json")
    (Join-Path $env:LOCALAPPDATA "Cursor/User/keybindings.json")
)

function Find-CursorConfig {
    foreach ($path in $CursorPaths) {
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            return $path
        }
    }

    foreach ($path in $CursorPaths) {
        $parentDir = Split-Path -Parent $path
        if (Test-Path -LiteralPath $parentDir -PathType Container) {
            return $path
        }
    }

    return $null
}

function Show-FileDiff {
    param(
        [string]$CursorPath,
        [string]$DotfilesPath
    )

    if (Get-Command git -ErrorAction SilentlyContinue) {
        $previousErrorAction = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        try {
            & git diff --no-index --no-color "$CursorPath" "$DotfilesPath" 2>$null |
                Select-Object -First 30
        }
        finally {
            $ErrorActionPreference = $previousErrorAction
        }
        return
    }

    $cursorLines = Get-Content -LiteralPath $CursorPath
    $dotfilesLines = Get-Content -LiteralPath $DotfilesPath
    Compare-Object $cursorLines $dotfilesLines | ForEach-Object {
        $prefix = if ($_.SideIndicator -eq "<=") { "-" } else { "+" }
        "$prefix $($_.InputObject)"
    } | Select-Object -First 30
}

$CursorPath = Find-CursorConfig

if (-not $CursorPath) {
    Write-Host "Could not find Cursor config directory" -ForegroundColor Red
    Write-Host "Checked locations:"
    foreach ($path in $CursorPaths) {
        Write-Host "  - $path"
    }
    exit 1
}

Write-Host "Found Cursor config at: $CursorPath"

if (-not (Test-Path -LiteralPath $DotfilesPath -PathType Leaf)) {
    Write-Host "Source keybindings missing in this repo:" -ForegroundColor Red
    Write-Host "   $DotfilesPath"
    Write-Host ""
    Write-Host "This script copies keybindings FROM your dotfiles repo TO Cursor's config."
    Write-Host "Add the file (e.g. export from Cursor, or copy from another machine):"
    Write-Host "   Copy-Item `"$CursorPath`" `"$DotfilesPath`""
    exit 1
}

switch ($Action) {
    "check" {
        if (Test-Path -LiteralPath $CursorPath -PathType Leaf) {
            $cursorHash = (Get-FileHash -LiteralPath $CursorPath -Algorithm SHA256).Hash
            $dotfilesHash = (Get-FileHash -LiteralPath $DotfilesPath -Algorithm SHA256).Hash

            if ($cursorHash -eq $dotfilesHash) {
                Write-Host "Files are identical" -ForegroundColor Green
            }
            else {
                Write-Host "Files differ:" -ForegroundColor Yellow
                Show-FileDiff -CursorPath $CursorPath -DotfilesPath $DotfilesPath
                Write-Host ""
                Write-Host "Run '.\powershell_cursor_keybindings.ps1 copy' to update Cursor config"
            }
        }
        else {
            Write-Host "No Cursor keybindings file exists yet" -ForegroundColor Yellow
            Write-Host "Run '.\powershell_cursor_keybindings.ps1 copy' to create it"
        }
    }

    "copy" {
        $destDir = Split-Path -Parent $CursorPath
        if (-not (Test-Path -LiteralPath $destDir -PathType Container)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        Copy-Item -LiteralPath $DotfilesPath -Destination $CursorPath -Force
        Write-Host "Successfully copied keybindings to Cursor" -ForegroundColor Green
    }
}
