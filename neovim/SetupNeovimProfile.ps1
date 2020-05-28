if (! $IsWindows) {
	write-error "OS doesn't seem to be Windows"
	Break Script
}

if (Test-Path "C:\tools\Neovim\bin\") {
	echo "Neovim installation found"
} else {
	echo "Warning, installation not found at \"C:/tools/Neovim/\", aborting script."
	Break Script
}


$appdatalocalpath = "$ENV:UserProfile\AppData\Local\"
if (!(test-path $appdatalocalpath)) {
	write-error "Can't find path $appdatalocalpath"
	Break Script
}

cd "$ENV:UserProfile\AppData\Local\"


if(!(test-path ".\nvim\")) {
	New-Item -ItemType Directory -Force -Path ".\nvim\"
}

cd ".\nvim\"
if(test-path ".\init.vim") {
	write-host "Error: init.vim already exists. Printing contents and exiting script"
	cat .\init.vim
} else {
	"source $PSScriptRoot\_vimrc" > ".\init.vim"
}

# The following section is for making your _vimrc work with ideavim
cd "$ENV:UserProfile\"
if (test-path ".\.ideavimrc") {
	write-host "Error: ~\ideavimrc already exists. Printing contents and exiting script"
	cat .\.ideavimrc
} else {
	"source $PSScriptRoot\_vimrc" > ".\.ideavimrc"
}


cd $PSScriptRoot
