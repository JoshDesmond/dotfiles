# Logging Function
# $StartTime = $(get-date).Ticks
function Print-ProfileLog {
	param(
		$text,
		[switch]$error
	)

    # ($(get-date).Ticks - $StartTime) / 10000000
    # $Script:StartTime = $(Get-Date).Ticks

	if ($error) {
		Write-Host $text -ForegroundColor red	
	} else {
		Write-Host $text -ForegroundColor green	
	}
}

New-Alias ppl Print-ProfileLog -Force

#======================
#=== Machine Logic ====
#======================
# Check powershell version to see if you are on PSCore

if ($PSVersionTable.PSEdition -eq "Desktop") {
	ppl "Warning: You are running the Desktop Version of Powershell" -error
	ppl "Download the latest version of Powershell core at:" -error
	ppl "https://github.com/PowerShell/PowerShell/releases/latest" -error
	# Note that $IsWindows (and other features, surely), will only work on PSCore
	# Look for <a href="/PowerShell/PowerShell/releases/download/v7.0.1/PowerShell-7.0.1-win-x64.msi">
	# If you want to automate core installation
}

# Check which computer you are on and set variables
$isDesktop = ($env:COMPUTERNAME -eq "DESKTOP-TOBINO0")
$isLaptop = ($env:COMPUTERNAME -eq "Desktop-G1KSHUE")
$isPersonal = ($isDesktop -or $isLaptop)

#======================
#====== Aliases =======
#======================
Print-ProfileLog 'Configuring Aliases'
New-Alias ppl Print-ProfileLog -Force
New-Alias which get-command -Force
New-Alias npp OpenWith-NotepadPlusPlus -Force
New-Alias version Get-PowershellVersion -Force
New-Alias vim nvim -Force
New-Alias vi vim -Force
New-Alias sha Get-StringHash -Force
if ($isPersonal) {
	New-Alias pc "C:\Users\$env:username\Google Drive\Percent Complete 2017.xlsx" -Force
	New-Alias schedule "C:\Users\$env:username\Google Drive\Schedule.xlsx" -Force
}

#======================
#=== $Env Settings ====
#======================
ppl 'Configuring Env Settings'

# Colors:
$colors = $host.privatedata
$colors.ErrorBackgroundColor = "DarkGray"
$colors.WarningBackgroundColor = "DarkGray"
$colors.DebugBackgroundColor = "DarkGray"
$colors.VerboseBackgroundColor = "DarkGray"

# Console Config:
$console = $host.ui.rawui
$console.backgroundcolor = "black"
$MaximumHistoryCount = 32767

# $Env:
$Env:Path += ";C:\Shortcuts"

# Neovim:
if (Test-Path "C:\tools\Neovim\bin\") {
    ppl 'Importing Neovim'
    $Env:Path += ";C:\tools\Neovim\bin\"
} else {
    ppl 'Neovim Installation not detected.' -error
    # TODO download
    # https://github.com/neovim/neovim/releases
    # look for nvim-win64.zip
    # Extract the archive into c:/tools/Neovim/
}

#======================
#== Import Chocolatey =
#======================
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	ppl 'Importing Chocolatey'
    Import-Module "$ChocolateyProfile"
}

#======================
#=== Import Modules ===
#======================

# Posh-git
$Script:downloadStrategy = {
    ppl 'Importing Posh-Git'
    $script:modulePath = Resolve-Path "C:\tools\posh-git\posh-git*\src\posh-git.psd1"
    Import-Module $Script:modulePath
}
if (Test-Path C:\tools\posh-git\) {
    Invoke-Command -ScriptBlock $Script:downloadStrategy
}
elseif (Get-Module -name posh-git) {
	ppl 'Importing Posh-Git'
	Import-Module posh-git
}
else {
    ppl 'Posh-Git not detected, attempting install' -error
    & "$PSScriptRoot\install-posh-ssh.ps1" "posh-git"
    if (Test-Path "C:\tools\posh-git\") {
        Invoke-Command -ScriptBlock $Script:downloadStrategy
    }
}

# Posh-sshell
$Script:downloadStrategy = {
    ppl 'Importing Posh-Shhell'
    $Script:modulePath = Resolve-Path "C:\tools\posh-sshell\posh-sshell*\posh-sshell.psd1"
    Import-Module $Script:modulePath
}
if (Test-Path C:\tools\posh-sshell\) {
    Invoke-Command -ScriptBlock $Script:downloadStrategy
}
elseif (Get-Module -Name posh-sshell) {
    ppl 'Importing Posh-Sshell'
    Import-Module posh-sshell
} 
else {
    ppl 'Posh-Sshell not detected, attempting install' -error
    & "$PSScriptRoot\install-posh-ssh.ps1" "posh-sshell"
    if (Test-Path "C:\tools\posh-sshell\") {
        Invoke-Command -ScriptBlock $Script:downloadStrategy
    }
}

# TODO write an admin script that will do:
# Get-Service -Name ssh-agent | Set-Service -StartupType Manual
Start-SshAgent -Quiet


#ppl 'Importing AWSPowerShell'
#Import-Module AWSPowerShell

#======================
#===== Functions ====== 
#======================
ppl 'Defining Functions'

# Get-NodePackages
# Prints the current npm packages installed in the local directory
function Get-NodePackages {
	npm list --depth 0
}

# ll
# Colorized LS function replacement. See:
# http://mow001.blogspot.com 
# http://stackoverflow.com/questions/138144/what-s-in-your-powershell-profile-ps1-file
function ll {
	param ($dir = ".", $all = $false) 

	$origFg = $host.ui.rawui.foregroundColor 

	if ( $all ) { $toList = ls -force $dir }
	else { $toList = ls $dir }

	foreach ($Item in $toList) { 
		Switch ($Item.Extension) { 
			".Exe" {$host.ui.rawui.foregroundColor = "Yellow"} 
			".cmd" {$host.ui.rawui.foregroundColor = "Red"} 
			".msh" {$host.ui.rawui.foregroundColor = "Red"} 
			".vbs" {$host.ui.rawui.foregroundColor = "Red"} 
			Default {$host.ui.rawui.foregroundColor = $origFg}
		} 
		if ($item.Mode.StartsWith("d")) {$host.ui.rawui.foregroundColor = "Green"}
		$item
	}  
	$host.ui.rawui.foregroundColor = $origFg 
}

function lla {
	param ( $dir=".")
	ll $dir $true
}

function la {ls -force}

# Get-Colors
# Prints a line of each color to console.
function Get-Colors {
	[System.ConsoleColor].GetEnumValues() | ForEach-Object { Write-Host $_ -ForegroundColor $_ }
}

# Get-StringHash
# Prints the Sha1 hash of a string
# http://jongurgul.com/blog/get-stringhash-get-filehash/ 
Function Get-StringHash([String] $String, $HashName = "SHA1") {
	$StringBuilder = New-Object System.Text.StringBuilder 
	[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{
		[Void]$StringBuilder.Append($_.ToString("x2")) 
	}
	$StringBuilder.ToString() 
}

# Block-YouTube
# Adds YouTube.com to the hosts file.
Function Block-Youtube {
	if (-Not $isWindows) { return }

	$hosts = 'C:\Windows\System32\drivers\etc\hosts'

	$is_blocked = Get-Content -Path $hosts |
	Select-String -Pattern ([regex]::Escape("youtube.com"))

	If(-not $is_blocked) {
		Add-Content -Path $hosts -Value "127.0.0.1 youtube.com"
			Add-Content -Path $hosts -Value "127.0.0.1 www.youtube.com"
	}
}

# Unblock-YouTube
# Removes any lines from the hosts file containing Youtube.com
Function Unblock-Youtube {
	if (-not $isWindows) { return }

	$hosts = 'C:\Windows\System32\drivers\etc\hosts'

	$is_blocked = Get-Content -Path $hosts |
	Select-String -Pattern ([regex]::Escape("youtube.com"))

	If($is_blocked) {
		$newhosts = Get-Content -Path $hosts |
			Where-Object {
				$_ -notmatch ([regex]::Escape("youtube.com"))
			}
		Set-Content -Path $hosts -Value $newhosts
	}
}

# OpenWith-NotepadPlusPlus
# Opens a file with notepad++
Function OpenWith-NotepadPlusPlus {
	notepad++.lnk (Get-ChildItem $args[0])
}

# Get-History-All
# Outputs the entire history that's saved
Function Get-History-All {
	cat (Get-PSReadlineOption).HistorySavePath
}

# Start-StartTranscript
# Starts a transcription of the current powershell session at the path ${tracefile}
Function Start-StartTranscript {
	if (-not $isWindows) { break }
	$tracefile="C:\Users\$env:username\Documents\WindowsPowerShell\Logs\PS-Session-$(get-date -format 'yyyyMMdd-HHmm').txt"
	Start-Transcript -Path $tracefile -NoClobber
}

# git-whoami
# Prints to console the configured username and email in the current directory
Function git-whoami {
	$gitUserName = git config user.name
	$gitUserEmail = git config user.email
	Write-Host "Name: ${gitUserName}, Email: ${gitUserEmail}"
}

# Confirm-UserApproval
# Prompts the user with ${PromptText} text, and exits 
Function Confirm-UserApproval([String] $PromptText="Are you sure you would like to proceed") {
	$confirmation = Read-Host $PromptText
	if ($confirmation -eq 'y') {
		# proceed
		return True
		}
	else {
		return false
	}
}

# Measure-LastCommand
# Outputs the amount of time it took for the last command in shell history to run
Function Measure-LastCommand() {
	$command = Get-History -Count 1
	($command.EndExecutionTime - $command.StartExecutionTime) | Format-Table
}

# Returns the version of powershell that is running.
Function Get-PowershellVersion { $PSVersionTable }

#Converts an HTTP remote to an SSH remote. Only works with remotes called origin
Function Convert-RepoToSSH() {
	#https://github.com/USERNAME/REPOSITORY.git
	#git@github.com:USERNAME/REPOSITORY.git

	$remote = git remote get-url origin
	if ($remote -notmatch '\.com\/\S+\/\S+\.git') {
		Write-Error "Remote $remote does not appear to be an http remote"
	}
	$remote -match '\.com\/(?<username>\S+)\/(?<repository>\S+)\.git' | out-null
	$newRemote = "git@github.com:$($matches.username)/$($matches.repository).git"
	git remote set-url origin $newRemote
	git remote -v
}

#======================
#=Me Specific Commands=
#======================
ppl 'Defining Personal Functions'

# Starts the IOTA Full Node running on localhost:14625
if ($isDesktop) {
Function Launch-IOTA {
	java -jar C:\Git\iri\target\iri-1.4.1.4.jar -p 14265
}
}

#======================
#==== Finishing Up ====
#======================
# Clear-Host
Write-Host 'Configuration Complete. Hello!'

# Notes and Favorited Commands:
# dir *.cs -Recurse | sls "TODO" | select -Unique "Path" #grep
# Get-Command -Module PackageManagement # Prints available commands in the PackageManagement module
# Get-Package -Provider Programs -IncludeWindowsInstaller # Shows everything installed
# Get-Content -path C:\CS\Powershell\script.ps1 -raw | invoke-expression # can add an external script
# $tracefile="$pwd\$(get-date -format 'MMddyyyy').txt" # Neat way to concat strings
# eval $(ssh-agent -s) , ssh-add ~/.ssh/id_rsa
# Get-Process | Sort CPU -Desc | Select -First 5
# Measure-Command { npm test | Out-Default } | Out-Default is better than Out-Host if you're scripting
# Get-History | Group {$_.StartExecutionTime.Hour} | sort Count -desc
# Get-PSDrive # outputs drives you can jump to
# Get-NetTCPConnection | ? State -eq Established | ? RemoteAddress -notlike 127* | % { $_; Resolve-DnsName $_.RemoteAddress -type PTR -ErrorAction SilentlyContinue }
# $env:path -split ";" | Where-Object {-not (Test-Path $_) } # Tests $env:path for missing folders
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-6

# Instead Of           Use
# ----------           ---
# $env:USERNAME        [Environment]::UserName
# $env:COMPUTERNAME    [Environment]::MachineName
# `n                   [Environment]::NewLine
# `r`n                 [Environment]::NewLine
# $env:TEMP            [IO.Path]::GetTempDirectory()
