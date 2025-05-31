# EVTX Python Token Embedder Setup Script for Windows PowerShell
# This script sets up the development environment

Write-Host "🚀 EVTX Python Token Embedder Setup" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

# Function to print colored output
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

# Check if running as Administrator (optional, but recommended)
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Not running as Administrator. Some operations might fail."
}

# Check Python version
Write-Host "Checking Python version..."
try {
    $pythonVersion = python --version 2>&1
    if ($pythonVersion -match "Python (\d+)\.(\d+)") {
        $majorVersion = [int]$matches[1]
        $minorVersion = [int]$matches[2]
        
        if ($majorVersion -eq 3 -and $minorVersion -ge 8) {
            Write-Success "Python $majorVersion.$minorVersion found (>= 3.8 required)"
        } else {
            Write-Error "Python $majorVersion.$minorVersion found, but >= 3.8 is required"
            Write-Host "Please download Python from https://www.python.org/downloads/"
            exit 1
        }
    }
} catch {
    Write-Error "Python is not installed or not in PATH"
    Write-Host "Please download Python from https://www.python.org/downloads/"
    exit 1
}

# Navigate to project root
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectPath = Split-Path -Parent $scriptPath
Set-Location $projectPath
Write-Success "Project directory: $projectPath"

# Remove old virtual environment if exists
if (Test-Path "venv") {
    Write-Warning "Virtual environment already exists. Removing old venv..."
    Remove-Item -Recurse -Force "venv"
}

# Create virtual environment
Write-Host "Creating virtual environment..."
python -m venv venv
if ($?) {
    Write-Success "Virtual environment created"
} else {
    Write-Error "Failed to create virtual environment"
    exit 1
}

# Activate virtual environment
Write-Host "Activating virtual environment..."
& ".\venv\Scripts\Activate.ps1"
if ($?) {
    Write-Success "Virtual environment activated"
} else {
    Write-Error "Failed to activate virtual environment"
    Write-Warning "You may need to run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
    exit 1
}

# Upgrade pip
Write-Host "Upgrading pip..."
python -m pip install --upgrade pip setuptools wheel
if ($?) {
    Write-Success "pip upgraded"
}

# Install requirements
Write-Host "Installing requirements..."
if (Test-Path "requirements.txt") {
    pip install -r requirements.txt
    if ($?) {
        Write-Success "Requirements installed"
    } else {
        Write-Error "Failed to install some requirements"
    }
} else {
    Write-Error "requirements.txt not found!"
    exit 1
}

# Create necessary directories
Write-Host "Creating project directories..."
$directories = @("evtx_files", "output", "logs")
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}
Write-Success "Directories created"

# Create sample .env file if it doesn't exist
if (-not (Test-Path ".env")) {
    Write-Host "Creating sample .env file..."
    @"
# Environment variables for EVTX Python Token Embedder
# Add your configuration here

# Example:
# API_KEY=your_api_key_here
# LOG_LEVEL=INFO
"@ | Out-File -FilePath ".env" -Encoding UTF8
    Write-Success ".env file created"
}

# Git initialization check
Write-Host "Checking Git setup..."
if (Test-Path ".git") {
    Write-Warning "Git repository already initialized"
} else {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Host "Initializing Git repository..."
        git init
        if ($?) {
            Write-Success "Git repository initialized"
        }
    } else {
        Write-Warning "Git is not installed. Please install Git from https://git-scm.com/"
    }
}

# Final setup status
Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Activate the virtual environment:"
Write-Host "   .\venv\Scripts\Activate" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Place your EVTX files in the evtx_files\ directory"
Write-Host ""
Write-Host "3. Run the script:"
Write-Host "   python read_evtx_files.py" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. To push to GitHub:"
Write-Host "   git add ." -ForegroundColor Yellow
Write-Host "   git commit -m `"Initial commit`"" -ForegroundColor Yellow
Write-Host "   git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPO.git" -ForegroundColor Yellow
Write-Host "   git push -u origin main" -ForegroundColor Yellow
Write-Host ""
Write-Success "Happy coding! 🎉"