#!/usr/bin/env python3
"""
Simple script to read all .evtx files in the evtx_files directory
"""

import os
import glob
from pathlib import Path

def read_evtx_files(directory="evtx_files"):
    """
    Read all .evtx files in the specified directory
    """
    # Get the absolute path of the directory
    dir_path = Path(directory)
    
    # Check if directory exists
    if not dir_path.exists():
        print(f"Error: Directory '{directory}' does not exist")
        return
    
    # Find all .evtx files in the directory
    evtx_files = list(dir_path.glob("*.evtx"))
    
    if not evtx_files:
        print(f"No .evtx files found in '{directory}'")
        return
    
    print(f"Found {len(evtx_files)} .evtx file(s):")
    print("-" * 50)
    
    for evtx_file in evtx_files:
        print(f"\nFile: {evtx_file.name}")
        print(f"Size: {evtx_file.stat().st_size:,} bytes")
        
        # Note: To actually parse EVTX files, you would need a library like python-evtx
        # For now, this just reads the file metadata
        
        try:
            # Read first few bytes to verify it's an EVTX file
            with open(evtx_file, 'rb') as f:
                header = f.read(8)
                if header[:4] == b'ElfF':
                    print("Valid EVTX file signature detected")
                else:
                    print("Warning: File may not be a valid EVTX file")
        except Exception as e:
            print(f"Error reading file: {e}")

if __name__ == "__main__":
    read_evtx_files()