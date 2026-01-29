# PowerShell Script to Remove All Print Statements
# This script removes all print() statements from Dart files in the project

$projectPath = "d:\flutter\semesterprojectgetx\lib"
$backupPath = "d:\flutter\semesterprojectgetx\lib_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Create backup
Write-Host "Creating backup at: $backupPath" -ForegroundColor Yellow
Copy-Item -Path $projectPath -Destination $backupPath -Recurse

# Get all Dart files
$dartFiles = Get-ChildItem -Path $projectPath -Recurse -Filter "*.dart"

$totalFiles = 0
$totalLinesRemoved = 0

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalLineCount = ($content -split "`n").Count
    
    # Remove lines containing print statements
    # Matches: print('...'); or print("...");
    $newContent = $content -split "`n" | Where-Object { 
        $_ -notmatch "^\s*print\(" 
    } | Out-String
    
    $newLineCount = ($newContent -split "`n").Count
    $linesRemoved = $originalLineCount - $newLineCount
    
    if ($linesRemoved -gt 0) {
        Set-Content -Path $file.FullName -Value $newContent.TrimEnd()
        $totalFiles++
        $totalLinesRemoved += $linesRemoved
        Write-Host "Cleaned: $($file.Name) - Removed $linesRemoved lines" -ForegroundColor Green
    }
}

Write-Host "`nCleanup Complete!" -ForegroundColor Cyan
Write-Host "Files modified: $totalFiles" -ForegroundColor Cyan
Write-Host "Total print statements removed: $totalLinesRemoved" -ForegroundColor Cyan
Write-Host "Backup location: $backupPath" -ForegroundColor Yellow
Write-Host "`nIMPORTANT: Run 'flutter analyze' to check for any issues" -ForegroundColor Red
