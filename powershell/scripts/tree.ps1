param(
    [string]$Path = ".",
    [int]$MaxDepth = 3,
    [int]$MaxFolders = 5
)

function Show-DirectoryTree {
    param(
        [string]$CurrentPath,
        [int]$Depth = 0,
        [string]$Prefix = ""
    )
    
    if ($Depth -gt ($MaxDepth - 1)) { return }
    
    try {
        $folders = Get-ChildItem -Path $CurrentPath -Directory -ErrorAction Stop | Select-Object -First $MaxFolders
        
        for ($i = 0; $i -lt $folders.Count; $i++) {
            $folder = $folders[$i]
            $isLast = ($i -eq $folders.Count - 1)
            
            if ($isLast) {
                Write-Host "$Prefix└── $($folder.Name)" -ForegroundColor Cyan
                $newPrefix = "$Prefix    "
            } else {
                Write-Host "$Prefix├── $($folder.Name)" -ForegroundColor Cyan
                $newPrefix = "$Prefix│   "
            }
            
            Show-DirectoryTree -CurrentPath $folder.FullName -Depth ($Depth + 1) -Prefix $newPrefix
        }
    }
    catch {
        Write-Host "$Prefix[Access Denied]" -ForegroundColor Red
    }
}

# Get the full path and display root
$fullPath = Resolve-Path $Path
Write-Host $fullPath -ForegroundColor Yellow

# Show the tree
Show-DirectoryTree -CurrentPath $fullPath

