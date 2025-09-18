$Script:new_profile = "$PSScriptRoot/profile.ps1"
if ( -Not $(Test-Path $Script:new_profile)) {
	write-error "File \"profile.ps1\" not found in script directory, aborting"
	exit 1
}

###
# Quick note: I'm kind of mixing paradigms here by introducing an install script into the
# setup_profile.ps1 script. Ideally, I'd separate the logic a little more, but this will
# work for now.
###

# Install OpenSSL
winget install --id=FireDaemon.OpenSSL -e

# Add to system PATH permanently
$openSSLPath = "C:\Program Files\FireDaemon OpenSSL 3\bin"
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
# Check if the path is already in PATH to avoid duplicates
if ($currentPath -notlike "*$openSSLPath*") {
    # Add to system PATH (requires admin privileges)
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$openSSLPath", "Machine")
    Write-Host "Added $openSSLPath to system PATH"
} else {
    Write-Host "Path already exists in system PATH"
}
# Refresh the current session's PATH
$env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine")


###
# And now back to the original PowerShell profile installation
###

if ($PROFILE -eq "$PSScriptRoot\profile.ps1") {
	echo "Profile already appears to be configured?"
	exit 0
}

$OG_PROFILE = "$PROFILE"

if ( -Not $(Test-Path "$PROFILE")) {
	echo "Profile file $PROFILE not found, attempting to create stub/redirect file"
	echo "Note: if $PROFILE is in a strange/non-standard location,"
	echo "	this scipt might cause some damage?"

	$Script:PowershellProfileFolder = Split-Path $PROFILE
	if ( -Not $(Test-Path "$Script:PowershellProfileFolder")) {
		New-Item -ItemType Directory -Force -Path $Script:PowershellProfileFolder
		echo "Creating directory $Script:PowershellProfileFolder"
	}

    # Using backticks (`) to escape variables so they're preserved as literal strings in the file
	echo "`$PROFILE = `"$PSScriptRoot\profile.ps1`"" > $PROFILE
	echo '. "$PROFILE"' >> $PROFILE
}
else {
	echo "`$PROFILE = `"$PSScriptRoot\profile.ps1`"" >> $PROFILE
	echo '. $PROFILE' >> $PROFILE
}

echo "OG_PROFILE: $OG_PROFILE"
