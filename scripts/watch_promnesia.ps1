# watch_promnesia.ps1
Param(
    [Parameter(Mandatory=$true)]
    [string]$ConfigPath,
    
    [Parameter(Mandatory=$true)]
    [string]$PythonPath
)

# Extract the directory to watch from the full file path
$configDir = Split-Path -Parent $ConfigPath
$configFile = Split-Path -Leaf $ConfigPath

$watcher = New-Object IO.FileSystemWatcher
$watcher.Path = $configDir
$watcher.Filter = $configFile
$watcher.EnableRaisingEvents = $true

Write-Host "--- Monitoring: $ConfigPath ---" -ForegroundColor Cyan

while($true) {
    $change = $watcher.WaitForChanged('Changed', 1000)
    
    if ($change.TimedOut -eq $false) {
        Write-Host "Change detected! Re-indexing..." -ForegroundColor Yellow
        Start-Sleep -Milliseconds 500
        
        # Run the indexer using the passed paths
        & $PythonPath -m promnesia index --config "$ConfigPath"
        
        Write-Host "Done! [$(Get-Date -Format 'HH:mm:ss')]" -ForegroundColor Green
        # [System.Console]::Beep(440, 200) # Optional: A little 'success' beep
    }
}