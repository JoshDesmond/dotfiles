# One-time setup: symlink Cursor user config files to this dotfiles repo.
# After linking, edits and git pull apply directly — no copy/sync step.
#
# Usage:
#   .\powershell_cursor_symlinks.ps1 check
#   .\powershell_cursor_symlinks.ps1 link
#
# Windows note: creating symlinks requires either Developer Mode
# (Settings > System > For developers) or running this script in an
# elevated (Administrator) PowerShell session.

param(
    [Parameter(Position = 0)]
    [ValidateSet("check", "link")]
    [string]$Action = "check"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CursorUserDir = Join-Path $env:APPDATA "Cursor\User"
$ManagedFiles = @("settings.json", "keybindings.json")
$BackupSuffix = ".bak.pre-symlink"

function Get-DotfilesPath {
    param([string]$FileName)
    Join-Path $ScriptDir $FileName
}

function Get-CursorPath {
    param([string]$FileName)
    Join-Path $CursorUserDir $FileName
}

function Resolve-NormalizedPath {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return (Resolve-Path -LiteralPath (Split-Path -Parent $Path)).Path + "\" + (Split-Path -Leaf $Path)
    }

    return (Resolve-Path -LiteralPath $Path).Path
}

function Test-SymlinkToDotfiles {
    param(
        [string]$CursorPath,
        [string]$DotfilesPath
    )

    if (-not (Test-Path -LiteralPath $CursorPath)) {
        return $false
    }

    $item = Get-Item -LiteralPath $CursorPath -Force
    if ($item.LinkType -ne "SymbolicLink") {
        return $false
    }

    $target = $item.Target
    if ($target -is [array]) {
        $target = $target[0]
    }

    return (Resolve-NormalizedPath $DotfilesPath) -eq (Resolve-NormalizedPath $target)
}

function Get-LinkStatus {
    param([string]$FileName)

    $dotfilesPath = Get-DotfilesPath $FileName
    $cursorPath = Get-CursorPath $FileName

    if (-not (Test-Path -LiteralPath $dotfilesPath -PathType Leaf)) {
        return [pscustomobject]@{
            FileName     = $FileName
            Status       = "missing-dotfiles"
            CursorPath   = $cursorPath
            DotfilesPath = $dotfilesPath
        }
    }

    if (-not (Test-Path -LiteralPath $cursorPath)) {
        return [pscustomobject]@{
            FileName     = $FileName
            Status       = "missing-cursor"
            CursorPath   = $cursorPath
            DotfilesPath = $dotfilesPath
        }
    }

    $item = Get-Item -LiteralPath $cursorPath -Force
    if ($item.LinkType -eq "SymbolicLink") {
        if (Test-SymlinkToDotfiles -CursorPath $cursorPath -DotfilesPath $dotfilesPath) {
            return [pscustomobject]@{
                FileName     = $FileName
                Status       = "linked"
                CursorPath   = $cursorPath
                DotfilesPath = $dotfilesPath
            }
        }

        return [pscustomobject]@{
            FileName     = $FileName
            Status       = "wrong-link"
            CursorPath   = $cursorPath
            DotfilesPath = $dotfilesPath
            Target       = $item.Target
        }
    }

    return [pscustomobject]@{
        FileName     = $FileName
        Status       = "regular-file"
        CursorPath   = $cursorPath
        DotfilesPath = $dotfilesPath
    }
}

function Write-LinkStatus {
    param($Status)

    switch ($Status.Status) {
        "linked" {
            Write-Host "$($Status.FileName): linked to dotfiles" -ForegroundColor Green
        }
        "regular-file" {
            Write-Host "$($Status.FileName): regular file (not symlinked)" -ForegroundColor Yellow
        }
        "missing-cursor" {
            Write-Host "$($Status.FileName): dotfiles exists, Cursor file missing" -ForegroundColor Yellow
        }
        "missing-dotfiles" {
            Write-Host "$($Status.FileName): missing in dotfiles repo" -ForegroundColor Red
        }
        "wrong-link" {
            Write-Host "$($Status.FileName): symlink points elsewhere ($($Status.Target))" -ForegroundColor Red
        }
    }
}

function Ensure-CursorUserDir {
    if (-not (Test-Path -LiteralPath $CursorUserDir -PathType Container)) {
        New-Item -ItemType Directory -Path $CursorUserDir -Force | Out-Null
    }
}

function Install-DotfilesSymlink {
    param([string]$FileName)

    $dotfilesPath = Get-DotfilesPath $FileName
    $cursorPath = Get-CursorPath $FileName
    $backupPath = "$cursorPath$BackupSuffix"

    if (-not (Test-Path -LiteralPath $dotfilesPath -PathType Leaf)) {
        throw "Dotfiles source missing: $dotfilesPath"
    }

    Ensure-CursorUserDir

    if (Test-SymlinkToDotfiles -CursorPath $cursorPath -DotfilesPath $dotfilesPath) {
        Write-Host "${FileName}: already linked" -ForegroundColor Green
        return
    }

    if (Test-Path -LiteralPath $cursorPath) {
        Copy-Item -LiteralPath $cursorPath -Destination $backupPath -Force
        Remove-Item -LiteralPath $cursorPath -Force
        Write-Host "${FileName}: backed up existing file to $backupPath"
    }

    New-Item -ItemType SymbolicLink -Path $cursorPath -Target $dotfilesPath -Force | Out-Null
    Write-Host "${FileName}: linked $cursorPath -> $dotfilesPath" -ForegroundColor Green
}

Write-Host "Cursor user config dir: $CursorUserDir"
Write-Host "Dotfiles dir: $ScriptDir"
Write-Host ""

$statuses = foreach ($fileName in $ManagedFiles) {
    Get-LinkStatus $fileName
}

switch ($Action) {
    "check" {
        foreach ($status in $statuses) {
            Write-LinkStatus $status
        }

        $needsLink = $statuses | Where-Object { $_.Status -ne "linked" -and $_.Status -ne "missing-dotfiles" }
        if ($needsLink) {
            Write-Host ""
            Write-Host "Run '.\powershell_cursor_symlinks.ps1 link' to symlink Cursor to dotfiles."
        }
    }

    "link" {
        foreach ($status in $statuses) {
            if ($status.Status -eq "missing-dotfiles") {
                throw "Cannot link $($status.FileName): add it to dotfiles first."
            }
        }

        foreach ($fileName in $ManagedFiles) {
            Install-DotfilesSymlink $fileName
        }

        Write-Host ""
        Write-Host "Done. Cursor now reads/writes your dotfiles directly." -ForegroundColor Green
        Write-Host "Reload Cursor (Ctrl+Shift+P -> Developer: Reload Window) if it was open during linking."
    }
}
