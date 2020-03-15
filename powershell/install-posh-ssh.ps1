# Test
$repo = "darkoperator/Posh-SSH"

$release = "https://github.com/$repo/releases/latest"
$tag = (Invoke-WebRequest -Uri $release -UseBasicParsing)
$download = ($tag.Links -match "/$repo/releases/download/").href
$download = "https://github.com$download"

write-host "Download URL found, $download, attempting to download"

if ((Test-Path c:/tools/) -eq $false) {
	write-host "Creating directory c:/tools/"
	mkdir c:/tools/
}

$filename = "poshssh"

if (Test-Path "C:/tools/$filename/") {
	write-host "poshssh already installed, aborting"
	exit
}

Invoke-WebRequest "$download" -OutFile "C:\tools\$filename.zip"

Expand-Archive "C:/tools/$filename.zip" -DestinationPath "C:/tools/$filename"
Remove-Item "C:/tools/$filename.zip" -Force
