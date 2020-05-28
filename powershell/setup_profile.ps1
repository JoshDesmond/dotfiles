$Script:new_profile = "$PSScriptRoot/profile.ps1"
if ( -Not $(Test-Path $Script:new_profile)) {
	write-error "File \"profile.ps1\" not found in script directory, aborting"
	exit 1
}

if ($PROFILE -eq "C:\code\dotfiles\powershell\profile.ps1") {
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
	# TODO how do you avoid escaping $PROFILE but also allow
	# for $PSScriptRoot in the same string creation? TODO
	echo '$PROFILE = "C:\code\dotfiles\powershell\profile.ps1"' > $PROFILE
	echo '. "$PROFILE"' >> $PROFILE
}
else {
	echo '$PROFILE = "$PSScriptRoot\profile.ps1"' >> $PROFILE
	echo '. $PROFILE' >> $PROFILE
}

echo "OG_PROFILE: $OG_PROFILE"
. $OG_PROFILE