#!/bin/bash

# EVTX Python Token Embedder Setup Script for WSL/Linux/macOS
# This script sets up the development environment

set -e  # Exit on error

echo "🚀 EVTX Python Token Embedder Setup"
echo "===================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check Python version
echo "Checking Python version..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    REQUIRED_VERSION="3.8"
    
    if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then 
        print_status "Python $PYTHON_VERSION found (>= 3.8 required)"
    else
        print_error "Python $PYTHON_VERSION found, but >= 3.8 is required"
        exit 1
    fi
else
    print_error "Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

# Navigate to project root
cd "$(dirname "$0")/.."
PROJECT_DIR=$(pwd)
print_status "Project directory: $PROJECT_DIR"

# Create virtual environment
echo "Creating virtual environment..."
if [ -d "venv" ]; then
    print_warning "Virtual environment already exists. Removing old venv..."
    rm -rf venv
fi

python3 -m venv venv
print_status "Virtual environment created"

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate
print_status "Virtual environment activated"

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip setuptools wheel
print_status "pip upgraded"

# Install requirements
echo "Installing requirements..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    print_status "Requirements installed"
else
    print_error "requirements.txt not found!"
    exit 1
fi

# Create necessary directories
echo "Creating project directories..."
mkdir -p evtx_files
mkdir -p output
mkdir -p logs
print_status "Directories created"

# Create sample .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating sample .env file..."
    cat > .env << EOF
# Environment variables for EVTX Python Token Embedder
# Add your configuration here

# Example:
# API_KEY=your_api_key_here
# LOG_LEVEL=INFO
EOF
    print_status ".env file created"
fi

# Git initialization check
echo "Checking Git setup..."
if [ -d ".git" ]; then
    print_warning "Git repository already initialized"
else
    echo "Initializing Git repository..."
    git init
    print_status "Git repository initialized"
fi

# Final setup status
echo ""
echo "====================================="
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo "====================================="
echo ""
echo "Next steps:"
echo "1. Activate the virtual environment:"
echo "   source venv/bin/activate"
echo ""
echo "2. Place your EVTX files in the evtx_files/ directory"
echo ""
echo "3. Run the script:"
echo "   python read_evtx_files.py"
echo ""
echo "4. To push to GitHub:"
echo "   git add ."
echo "   git commit -m \"Initial commit\""
echo "   git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPO.git"
echo "   git push -u origin main"
echo ""
print_status "Happy coding! 🎉"