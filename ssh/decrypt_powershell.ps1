# Decrypt SSH config and copy to ~/.ssh/config

$ScriptDir = $PSScriptRoot
$EncryptedFile = "$ScriptDir\config.enc"
$DecryptedFile = "$ScriptDir\config"
$Target = "$env:USERPROFILE\.ssh\config"

$Password = Read-Host "Password" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

openssl aes-256-cbc -d -salt -pbkdf2 -in $EncryptedFile -out $DecryptedFile -pass pass:$PlainPassword

Copy-Item $DecryptedFile $Target -Force
Remove-Item $DecryptedFile

Write-Host "Decrypted to ~/.ssh/config"