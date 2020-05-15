$path = "C:\temp\NewFolder"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

cd "C:\Users\$env:username\Pictures\timelapse"
