# fix-linear-shortcuts.ps1 — Add GPU workaround flags to Linear desktop shortcuts.
#
# Usage:
#   fix-linear-shortcuts.ps1
#   fix-linear-shortcuts.ps1 -Arguments "--disable-gpu --disable-gpu-compositing"
#   fix-linear-shortcuts.ps1 --help
#
# Updates Start Menu and taskbar .lnk files that target Linear.exe, and creates
# a Start Menu shortcut if the installer removed it. Re-run after Linear updates
# if shortcuts lose their arguments.

param(
    [string]$Arguments = "--disable-gpu --disable-gpu-compositing",
    [string]$LinearExe = "$env:LOCALAPPDATA\Programs\Linear\Linear.exe",
    [switch]$WhatIf
)

$HelpText = @"
fix-linear-shortcuts.ps1 — Add GPU workaround flags to Linear desktop shortcuts.

Usage:
  fix-linear-shortcuts.ps1
  fix-linear-shortcuts.ps1 -Arguments `"--disable-gpu --disable-gpu-compositing`"
  fix-linear-shortcuts.ps1 -WhatIf
  fix-linear-shortcuts.ps1 --help

Updates .lnk files in common locations (Start Menu, taskbar pin folder, Desktop)
that target Linear.exe. Creates a Start Menu shortcut when missing.

You cannot bake launch arguments into Linear.exe itself; shortcuts (or a wrapper
script) are the supported approach. Linear updates replace the exe under
Local\Programs\Linear but usually keep existing shortcuts — if an updater
recreates them without args, run this script again.
"@

if ($args -contains "--help" -or $args -contains "-h") {
    Write-Output $HelpText
    exit 0
}

function Get-ShortcutDetails {
    param([string]$Path)

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($Path)
    [PSCustomObject]@{
        Path = $Path
        TargetPath = $shortcut.TargetPath
        Arguments = $shortcut.Arguments
        WorkingDirectory = $shortcut.WorkingDirectory
        IconLocation = $shortcut.IconLocation
        Description = $shortcut.Description
    }
}

function Set-LinearShortcut {
    param(
        [string]$Path,
        [string]$TargetPath,
        [string]$Arguments,
        [string]$WorkingDirectory,
        [string]$IconLocation,
        [string]$Description = "Linear"
    )

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }

    if ($WhatIf) {
        Write-Output "[WhatIf] Would update: $Path"
        return "would-update"
    }

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($Path)
    $shortcut.TargetPath = $TargetPath
    $shortcut.Arguments = $Arguments
    $shortcut.WorkingDirectory = $WorkingDirectory
    $shortcut.IconLocation = $IconLocation
    $shortcut.Description = $Description
    $shortcut.Save()

    return "updated"
}

if (-not (Test-Path $LinearExe)) {
    Write-Error "Linear.exe not found at: $LinearExe"
    exit 1
}

$linearDir = Split-Path -Parent $LinearExe
$iconLocation = "$LinearExe,0"

$shortcutPaths = @(
    Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Linear.lnk"
    Join-Path $env:APPDATA "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Linear.lnk"
    Join-Path $env:USERPROFILE "Desktop\Linear.lnk"
)

$searchRoots = @(
    Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
    Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs"
    Join-Path $env:APPDATA "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
    Join-Path $env:APPDATA "Microsoft\Internet Explorer\Quick Launch\User Pinned\ImplicitAppShortcuts"
    $env:USERPROFILE
)

foreach ($root in $searchRoots) {
    if (-not (Test-Path $root)) {
        continue
    }

    Get-ChildItem -Path $root -Recurse -Filter "*.lnk" -ErrorAction SilentlyContinue |
        ForEach-Object {
            try {
                $details = Get-ShortcutDetails -Path $_.FullName
                if ($details.TargetPath -ieq $LinearExe) {
                    $shortcutPaths += $details.Path
                }
            } catch {
                # Ignore unreadable shortcuts.
            }
        }
}

$shortcutPaths = $shortcutPaths | Select-Object -Unique
$results = @()

foreach ($path in $shortcutPaths) {
    if (Test-Path $path) {
        $before = Get-ShortcutDetails -Path $path
        if ($before.Arguments -eq $Arguments) {
            $results += [PSCustomObject]@{
                Path = $path
                Action = "unchanged"
                Arguments = $before.Arguments
            }
            continue
        }
    }

    $action = Set-LinearShortcut -Path $path `
        -TargetPath $LinearExe `
        -Arguments $Arguments `
        -WorkingDirectory $linearDir `
        -IconLocation $iconLocation

    $results += [PSCustomObject]@{
        Path = $path
        Action = if (Test-Path $path) { $action } else { $action }
        Arguments = $Arguments
    }
}

if ($results.Count -eq 0) {
    Write-Output "No Linear shortcuts found or created."
    exit 0
}

Write-Output "Linear launch arguments: $Arguments"
Write-Output ""
$results | Format-Table -AutoSize
