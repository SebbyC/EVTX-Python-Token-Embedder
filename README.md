# EVTX Python Token Embedder

A Python tool for reading and processing Windows Event Log (EVTX) files with token embedding capabilities.

## 🚀 Quick Start

### Prerequisites
- Python 3.8 or higher
- Git
- SSH key configured for GitHub

### Setup

#### Option 1: WSL/Linux/macOS
```bash
cd scripts
chmod +x setup.sh
./setup.sh
```

#### Option 2: Windows PowerShell
```powershell
cd scripts
.\setup.ps1
```

## 📁 Project Structure
```
EVTX-Python-Token-Embedder/
├── scripts/
│   ├── setup.sh          # WSL/Linux setup script
│   └── setup.ps1         # Windows PowerShell setup script
├── evtx_files/           # Directory for EVTX files (created on setup)
├── read_evtx_files.py    # Main script to read EVTX files
├── requirements.txt      # Python dependencies
├── .gitignore           # Git ignore file
└── README.md            # This file
```

## 🔧 Usage

1. Place your EVTX files in the `evtx_files/` directory
2. Run the script:
   ```bash
   python read_evtx_files.py
   ```

## 🛠️ Development

### Setting up Git Repository

1. Create a new repository on GitHub
2. Initialize and push:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPO_NAME.git
   git push -u origin main
   ```

### Virtual Environment

The setup scripts automatically create a virtual environment. To activate it manually:

**WSL/Linux/macOS:**
```bash
source venv/bin/activate
```

**Windows:**
```powershell
.\venv\Scripts\Activate
```

### Installing Dependencies

```bash
pip install -r requirements.txt
```

## 📦 Dependencies

See `requirements.txt` for a full list of dependencies.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 🐛 Known Issues

- The script currently only reads EVTX file metadata. Full parsing requires additional libraries.

## 📞 Contact

Sebastian Jorge Colon -https://www.linkedin.com/in/sebastianjcolon/ - sebastian.j.colon@runi-uni.com

Project Link: https://github.com/SebbyC/EVTX-Python-Token-Embedder
