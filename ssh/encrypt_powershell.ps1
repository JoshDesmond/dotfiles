# Encrypt SSH config from ~/.ssh/config to dotfiles

$ScriptDir = $PSScriptRoot
$Source = "$env:USERPROFILE\.ssh\config"
$TempFile = "$ScriptDir\config"
$EncryptedFile = "$ScriptDir\config.enc"

Copy-Item $Source $TempFile -Force

$Password = Read-Host "Password" -AsSecureString
$Password2 = Read-Host "Confirm Password" -AsSecureString

$BSTR1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$BSTR2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password2)
$PlainPassword1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR1)
$PlainPassword2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR2)

if ($PlainPassword1 -ne $PlainPassword2) {
    Write-Host "Passwords don't match"
    Remove-Item $TempFile
    exit 1
}

openssl aes-256-cbc -salt -pbkdf2 -in $TempFile -out $EncryptedFile -pass pass:$PlainPassword1

Remove-Item $TempFile

Write-Host "Encrypted ~/.ssh/config to config.enc"