#!/usr/bin/env python3

"""
Update versions.json after successful push
"""

import json
import sys
from datetime import datetime

def update_versions(version):
    """Update versions.json with newly pushed version"""
    try:
        # Load existing versions
        try:
            with open('versions.json', 'r') as f:
                data = json.load(f)
        except FileNotFoundError:
            data = {
                "last_checked": None,
                "built_versions": [],
                "latest_version": None
            }
        
        # Add version if not already present
        if version not in data.get("built_versions", []):
            data.setdefault("built_versions", []).append(version)
        
        # Update timestamps
        data["latest_version"] = version
        data["last_pushed"] = datetime.now().isoformat()
        
        # Save updated versions
        with open('versions.json', 'w') as f:
            json.dump(data, f, indent=2)
        
        print(f"Updated versions.json with {version}")
        
    except Exception as e:
        print(f"Error updating versions.json: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: update_versions.py <version>")
        sys.exit(1)
    
    update_versions(sys.argv[1])