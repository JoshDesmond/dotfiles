# Logging Function
function Print-ProfileLog {
	param($text)
	Write-Host $text -ForegroundColor green	
}

#======================
#=== Machine Logic ====
#======================
$isWindows = ($env:OS -like "*windows*")
$isVirtusa = ($env:COMPUTERNAME -eq "WTLJDESMOND")
$isDesktop = ($env:COMPUTERNAME -eq "TROLOLO")
$isLaptop = ($env:COMPUTERNAME -eq "Desktop-G1SKU")
$isPersonal = ($isDesktop -or $isLaptop)

#======================
#====== Aliases =======
#======================
Print-ProfileLog 'Configuring Aliases'
New-Alias ppl Print-ProfileLog -Force
New-Alias which get-command -Force
New-Alias npp OpenWith-NotepadPlusPlus -Force
Function Get-PowershellVersion { $PSVersionTable }
New-Alias version Get-PowershellVersion -Force
New-Alias vim nvim -Force
New-Alias vi vim -Force
New-Alias sha Get-StringHash -Force
if ($isPersonal) {
	New-Alias pc "C:\Users\$env:username\Google Drive\Percent Complete 2017.xlsx" -Force
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

# $Env:
$Env:Path += ";C:\Shortcuts"
if ($isVirtusa) {
	$Env:Path += ";C:\Users\jdesmond\Documents\Neovim\bin\"
	$Env:Path += ";C:\Users\jdesmond\Documents\NodeJS\node-v10.16.0-win-x64\"
}

#======================
#== Import posh-git ===
#======================
ppl 'Importing Posh-Git'
Import-Module posh-git
# Also posh-sshell
ppl 'Importing Posh-Sshell'
Import-Module posh-sshell

#======================
#=== Import AWS-CLI ===
#======================
#ppl 'Importing AWSPowerShell'
#Import-Module AWSPowerShell

#======================
#== Import Chocolatey =
#======================
ppl 'Importing Chocolatey'
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

#======================
#===== Functions ====== 
#======================
ppl 'Defining Functions'

# Print-NodePackages
# Prints the current npm packages installed in the local directory
function Print-NodePackages {
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

# Print-Colors
# Prints a line of each color to console.
function Print-Colors {
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

# This doesn't work.
if ($isVirtusa) {
Function Launch-VM {
	$vbox_file = Get-Item "C:\Users\$env:username\VirtualBox VMs\CentOS 7\CentOS 7.vbox"
	start-job {C:\Program Files\Oracle\VirtualBox\VBoxHeadless.exe -startvm $vbox_path -v}
	Write-Host "If ssh fails, try the following command again more than once"
	Write-Host "ssh -p2222 admin@127.0.0.1 -v" -ForegroundColor green
	Write-Host "You can access the PowerShell jobs with the variable $job"
	ssh -p2222 admin@127.0.0.1 -v
}
}

if ($isVirtusa) {
Function CentOSSH {
	ssh -p2222 admin@127.0.0.1 -v
}
}

# Adding an external script real quick.
if ($isVirtusa) {
	get-content -path C:\Shortcuts\lunatic.ps1 -raw | invoke-expression
}
#======================
#==== Finishing Up ====
#======================
# Clear-Host
Write-Host 'Configuration Complete. Hello!'

# Notes and Favorited Commands:
# Get-Command -Module PackageManagement # Prints available commands in the PackageManagement module
# Get-Package -Provider Programs -IncludeWindowsInstaller # Shows everything installed
# Get-Content -path C:\CS\Powershell\script.ps1 -raw | invoke-expression # can add an external script
# $tracefile="$pwd\$(get-date -format 'MMddyyyy').txt" # Neat way to concat strings
# eval $(ssh-agent -s) , ssh-add ~/.ssh/id_rsa
# Get-Process | Sort CPU -Desc | Select -First 5
