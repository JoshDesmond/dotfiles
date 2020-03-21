param (
    [Parameter(Mandatory=$true)]
    [String]
     $repository
)

switch ($repository) {
    "posh-git" {
        $script:repoURL = "dahlbyk/posh-git"
        $script:downloadURL = "/$repoURL/archive/\S*zip"
        Break
    }
    "posh-sshell" {
        $script:repoURL = "dahlbyk/posh-sshell"
        $script:downloadURL = "/$repoURL/archive/\S*zip"
        Break
    }
    "posh-ssh" {
        $script:repoURL = "darkoperator/Posh-SSH"
        $script:downloadURL = "/$repoURL/releases/download/"
        $script:strategy = {
            param($temp)
        }
        Break
    }
    default {
        write-error "Repository $repository is not configured for auto-installation."
    }
}

if ((Test-Path c:/tools/) -eq $false) {
	write-host "Creating directory c:/tools/"
	mkdir c:/tools/
}


if (Test-Path "C:/tools/$repository/") {
	write-host "$repository already installed, aborting"
	exit
}


write-host $repoURL
$release = "https://github.com/$repoURL/releases/latest"
$webResponseObject = (Invoke-WebRequest -Uri $release -UseBasicParsing)
$download = ($webResponseObject.Links -match $downloadURL).href
if ($download -eq $null) {
    write-host "No download found at URL $release"
    Write-Error "Failed to extract download URL for given repository, $repository"
    exit -1
}
$download = "https://github.com$download"


write-host "Download URL found, $download, attempting to download"
Invoke-WebRequest "$download" -OutFile "C:\tools\$repository.zip"


Expand-Archive "C:/tools/$repository.zip" -DestinationPath "C:/tools/$repository"
Remove-Item "C:/tools/$repository.zip" -Force