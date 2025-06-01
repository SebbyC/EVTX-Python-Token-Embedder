# EVTX Log Collector - PowerShell Script
# Collects Windows Event Logs and saves them as EVTX files
# Requires Administrator privileges for some logs

param(
    [Parameter(Mandatory=$false)]
    [string]$OutputDirectory = ".\evtx_files",
    
    [Parameter(Mandatory=$false)]
    [string[]]$LogNames = @("System", "Application", "Security", "Setup", "Windows PowerShell"),
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeAllLogs,
    
    [Parameter(Mandatory=$false)]
    [switch]$CompressOutput,
    
    [Parameter(Mandatory=$false)]
    [int]$MaxSizeMB = 100,
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeMetadata
)

# Set strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# Color functions
function Write-Success {
    Write-Host "[+] $args" -ForegroundColor Green
}

function Write-Info {
    Write-Host "[*] $args" -ForegroundColor Cyan
}

function Write-Warning-Custom {
    Write-Host "[!] $args" -ForegroundColor Yellow
}

function Write-Error-Custom {
    Write-Host "[-] $args" -ForegroundColor Red
}

# Header
Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "     Windows Event Log Collector for EVTX" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Warning-Custom "Not running as Administrator. Some logs (like Security) may not be accessible."
    Write-Info "To collect all logs, run PowerShell as Administrator"
    Write-Host ""
}

# Create output directory if it doesn't exist
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
if (!(Test-Path $OutputDirectory)) {
    Write-Info "Creating output directory: $OutputDirectory"
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

# Create timestamp for this collection
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$collectionDir = Join-Path $OutputDirectory "collection_$timestamp"
New-Item -ItemType Directory -Path $collectionDir -Force | Out-Null

Write-Success "Output directory: $collectionDir"

# Function to export a single log
function Export-EventLog {
    param(
        [string]$LogName,
        [string]$OutputPath
    )
    
    try {
        # Check if log exists
        $log = Get-WinEvent -ListLog $LogName -ErrorAction Stop
        
        # Get log size in MB
        $logSizeMB = [math]::Round($log.FileSize / 1MB, 2)
        
        Write-Info "Exporting '$LogName' log (Size: $logSizeMB MB)..."
        
        # Check size limit
        if ($logSizeMB -gt $MaxSizeMB) {
            Write-Warning-Custom "Log '$LogName' exceeds size limit ($logSizeMB MB > $MaxSizeMB MB). Skipping..."
            return $false
        }
        
        # Export the log
        $exportPath = Join-Path $OutputPath "$($LogName.Replace('/', '_')).evtx"
        wevtutil export-log $LogName $exportPath /overwrite:true
        
        if ($?) {
            Write-Success "Exported: $($LogName).evtx"
            
            # Get file info
            $fileInfo = Get-Item $exportPath
            $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
            
            return @{
                LogName = $LogName
                FilePath = $exportPath
                FileSizeMB = $fileSizeMB
                RecordCount = $log.RecordCount
                LastWriteTime = $log.LastWriteTime
                IsEnabled = $log.IsEnabled
            }
        } else {
            Write-Error-Custom "Failed to export '$LogName'"
            return $false
        }
    }
    catch [System.Exception] {
        if ($_.Exception.Message -like "*Access is denied*") {
            Write-Warning-Custom "Access denied for '$LogName'. Run as Administrator to access this log."
        } else {
            Write-Error-Custom "Error accessing '$LogName': $($_.Exception.Message)"
        }
        return $false
    }
}

# Get list of logs to export
if ($IncludeAllLogs) {
    Write-Info "Collecting all available Windows Event Logs..."
    $LogNames = @()
    
    try {
        $allLogs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | 
                   Where-Object { $_.RecordCount -gt 0 } |
                   Sort-Object LogName
        
        $LogNames = $allLogs.LogName
        Write-Success "Found $($LogNames.Count) non-empty logs"
    }
    catch {
        Write-Error-Custom "Failed to enumerate all logs: $_"
        exit 1
    }
}

# Export logs
Write-Host "`nExporting Event Logs..." -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

$exportedLogs = @()
$failedLogs = @()

foreach ($logName in $LogNames) {
    $result = Export-EventLog -LogName $logName -OutputPath $collectionDir
    
    if ($result -ne $false) {
        $exportedLogs += $result
    } else {
        $failedLogs += $logName
    }
}

# Create metadata file if requested
if ($IncludeMetadata -and $exportedLogs.Count -gt 0) {
    Write-Info "Creating metadata file..."
    
    $metadata = @{
        CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ComputerName = $env:COMPUTERNAME
        UserName = $env:USERNAME
        IsAdministrator = $isAdmin
        WindowsVersion = (Get-CimInstance Win32_OperatingSystem).Version
        TotalLogsExported = $exportedLogs.Count
        TotalSizeMB = [math]::Round(($exportedLogs | Measure-Object -Property FileSizeMB -Sum).Sum, 2)
        Logs = $exportedLogs
    }
    
    $metadataPath = Join-Path $collectionDir "collection_metadata.json"
    $metadata | ConvertTo-Json -Depth 3 | Out-File -FilePath $metadataPath -Encoding UTF8
    Write-Success "Metadata saved to: collection_metadata.json"
}

# Compress output if requested
if ($CompressOutput -and $exportedLogs.Count -gt 0) {
    Write-Info "Compressing collected logs..."
    
    $zipPath = Join-Path $OutputDirectory "evtx_collection_$timestamp.zip"
    
    try {
        Compress-Archive -Path "$collectionDir\*" -DestinationPath $zipPath -CompressionLevel Optimal
        Write-Success "Compressed archive created: $zipPath"
        
        # Optionally remove uncompressed files
        $response = Read-Host "Remove uncompressed files? (y/N)"
        if ($response -eq 'y') {
            Remove-Item -Path $collectionDir -Recurse -Force
            Write-Success "Uncompressed files removed"
        }
    }
    catch {
        Write-Error-Custom "Failed to create compressed archive: $_"
    }
}

# Summary
Write-Host "`n================================================" -ForegroundColor Green
Write-Host "           Collection Summary" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

Write-Host "Successfully exported: " -NoNewline
Write-Host "$($exportedLogs.Count) logs" -ForegroundColor Green

if ($failedLogs.Count -gt 0) {
    Write-Host "Failed to export: " -NoNewline
    Write-Host "$($failedLogs.Count) logs" -ForegroundColor Red
}

if ($exportedLogs.Count -gt 0) {
    $totalSize = [math]::Round(($exportedLogs | Measure-Object -Property FileSizeMB -Sum).Sum, 2)
    Write-Host "Total size: " -NoNewline
    Write-Host "$totalSize MB" -ForegroundColor Cyan
    
    Write-Host "`nExported logs:" -ForegroundColor Cyan
    foreach ($log in $exportedLogs) {
        Write-Host "  - $($log.LogName) " -NoNewline
        Write-Host "($($log.FileSizeMB) MB, $($log.RecordCount) records)" -ForegroundColor Gray
    }
}

Write-Host "`nOutput location: " -NoNewline
Write-Host $collectionDir -ForegroundColor Yellow

# Tips for using with Python script
Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "           Next Steps" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "1. The EVTX files are ready for processing"
Write-Host "2. Run your Python script:"
Write-Host "   python read_evtx_files.py" -ForegroundColor Yellow
Write-Host ""

# Create a simple batch file to run this script
$batchContent = @"
@echo off
echo Running EVTX Log Collector...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0collect_logs.ps1" %*
pause
"@

$batchPath = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "collect_logs.bat"
$batchContent | Out-File -FilePath $batchPath -Encoding ASCII
Write-Info "Created batch file for easy execution: collect_logs.bat"
