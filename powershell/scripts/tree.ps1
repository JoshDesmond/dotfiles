param(
    [string]$Path = ".",
    [int]$MaxDepth = 3,
    [int]$MaxItems = 5,
    [switch]$ShowFiles
)

function Show-DirectoryTree {
    param(
        [string]$CurrentPath,
        [int]$Depth = 0,
        [string]$Prefix = ""
    )
    
    if ($Depth -gt ($MaxDepth - 1)) { return }
    
    try {
        # Get directories and files separately
        $folders = Get-ChildItem -Path $CurrentPath -Directory -ErrorAction Stop | Where-Object { $_.Name -ne "node_modules" }
        $files = @()
        if ($ShowFiles) {
            $files = Get-ChildItem -Path $CurrentPath -File -ErrorAction Stop
        }
        
        # Limit items and create display objects
        $displayItems = @()
        
        # Add folders first (limited by MaxItems)
        $folders | Select-Object -First $MaxItems | ForEach-Object {
            $displayItems += [PSCustomObject]@{
                Name = $_.Name
                FullName = $_.FullName
                Type = "Directory"
                SortOrder = 0
            }
        }
        
        # Add files (limited by remaining MaxItems slots)
        if ($ShowFiles) {
            $remainingSlots = $MaxItems - $displayItems.Count
            if ($remainingSlots -gt 0) {
                $files | Select-Object -First $remainingSlots | ForEach-Object {
                    $displayItems += [PSCustomObject]@{
                        Name = $_.Name
                        FullName = $_.FullName
                        Type = "File"
                        SortOrder = 1
                    }
                }
            }
        }
        
        # Sort: directories first, then files, both alphabetically
        $displayItems = $displayItems | Sort-Object SortOrder, Name
        
        # Display items
        for ($i = 0; $i -lt $displayItems.Count; $i++) {
            $item = $displayItems[$i]
            $isLast = ($i -eq $displayItems.Count - 1)
            
            if ($isLast) {
                if ($item.Type -eq "Directory") {
                    Write-Host "$Prefix└── $($item.Name)/" -ForegroundColor Cyan
                } else {
                    Write-Host "$Prefix└── $($item.Name)" -ForegroundColor White
                }
                $newPrefix = "$Prefix    "
            } else {
                if ($item.Type -eq "Directory") {
                    Write-Host "$Prefix├── $($item.Name)/" -ForegroundColor Cyan
                } else {
                    Write-Host "$Prefix├── $($item.Name)" -ForegroundColor White
                }
                $newPrefix = "$Prefix│   "
            }
            
            # Recursively show subdirectories only
            if ($item.Type -eq "Directory") {
                Show-DirectoryTree -CurrentPath $item.FullName -Depth ($Depth + 1) -Prefix $newPrefix
            }
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

