# TODO fix indentation

# Setup $timelapse_directory
$timelapse_directory = "C:\Users\$env:username\Pictures\timelapse\"
If(!(test-path $timelapse_directory))
{
      New-Item -ItemType Directory -Force -Path $timelapse_directory
}

# Create a new sub folder for current date-time and update $timelapse_directory
$timelapse_directory = Join-Path -Path $timelapse_directory -ChildPath $(get-date -f yyyy-MM-dd-HHmmss)
New-Item -ItemType Directory -Force -Path $timelapse_directory

echo $timelapse_directory

# Set speed seperately for laptop vs. desktop (#TODO create some kind of config file?)
[int]$sleep_time = 5
if ($env:COMPUTERNAME -eq "Desktop-G1KSHUE") {
	$sleep_time = 12
}


Function Take-Screenshots {
	if ($script:sleep_time -isnot [int]) {
		echo "Error, invalid \$sleep_time value, $script:sleep_time"
	}

	Add-Type -AssemblyName System.Windows.Forms
    Add-type -AssemblyName System.Drawing

    $Screen = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
    $Width = $Screen.Width
    $Height = $Screen.Height
    $Left = $Screen.Left
    $Top = $Screen.Top

    $Imageformat= [System.Drawing.Imaging.ImageFormat]::Jpeg
	
	# Create bitmap using the top-left and bottom-right bounds
	$Bitmap = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Width, $Height

	# Create Graphics object
	$Graphic = [System.Drawing.Graphics]::FromImage($Bitmap)

	do {
        if (Get-Process logonui -ErrorAction SilentlyContinue) {
            Start-Sleep -Seconds 30
            Continue
        }

        $FullName = Join-Path -Path $timelapse_directory -ChildPath $((get-date -f yyyy-MM-dd-HHmmss)+".jpg")

	    # Capture screen
	    $Graphic.CopyFromScreen(0, 0, 0, 0, $Bitmap.Size)

	    # Save to file
	    $Bitmap.Save($FullName, $Imageformat)

        Start-Sleep -Seconds $sleep_time

        
    } While ($TRUE)
}


Take-Screenshots
