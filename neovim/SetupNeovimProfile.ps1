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

cd $PSScriptRoot
