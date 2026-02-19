# OpenClaw Daily Backup Script
$ErrorActionPreference = "Stop"

$RepoPath = "D:\Jim\openclawd"
$LogFile = "$RepoPath\backup.log"

function Write-Log($Message) {
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogFile -Append
    Write-Host $Message
}

try {
    Write-Log "Starting backup..."
    
    Set-Location $RepoPath
    
    # Check if there are changes
    $Status = git status --porcelain
    if (-not $Status) {
        Write-Log "No changes to commit."
        exit 0
    }
    
    # Add all changes
    git add .
    Write-Log "Changes staged."
    
    # Commit with timestamp
    $CommitMsg = "Auto backup - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    git commit -m "$CommitMsg"
    Write-Log "Committed: $CommitMsg"
    
    # Push to GitHub
    git push origin main
    Write-Log "Pushed to GitHub successfully."
    
    exit 0
} catch {
    Write-Log "ERROR: $_"
    exit 1
}
