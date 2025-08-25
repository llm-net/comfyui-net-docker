#!/usr/bin/env python3

"""
ComfyUI Release Checker
Checks for new ComfyUI releases and triggers build if needed
"""

import json
import os
import sys
import requests
from datetime import datetime
from typing import Dict, List, Optional

# Configuration
GITHUB_API_URL = "https://api.github.com/repos/comfyanonymous/ComfyUI/releases"
VERSIONS_FILE = "versions.json"
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")

def get_headers() -> Dict[str, str]:
    """Get headers for GitHub API requests"""
    headers = {"Accept": "application/vnd.github.v3+json"}
    if GITHUB_TOKEN:
        headers["Authorization"] = f"token {GITHUB_TOKEN}"
    return headers

def fetch_releases() -> List[Dict]:
    """Fetch releases from ComfyUI GitHub repository"""
    try:
        response = requests.get(GITHUB_API_URL, headers=get_headers())
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"Error fetching releases: {e}")
        sys.exit(1)

def load_versions() -> Dict:
    """Load existing versions from versions.json"""
    if not os.path.exists(VERSIONS_FILE):
        return {
            "last_checked": None,
            "built_versions": [],
            "latest_version": None
        }
    
    try:
        with open(VERSIONS_FILE, 'r') as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError) as e:
        print(f"Error loading versions file: {e}")
        return {
            "last_checked": None,
            "built_versions": [],
            "latest_version": None
        }

def save_versions(versions: Dict) -> None:
    """Save versions to versions.json"""
    try:
        with open(VERSIONS_FILE, 'w') as f:
            json.dump(versions, f, indent=2)
    except IOError as e:
        print(f"Error saving versions file: {e}")
        sys.exit(1)

def check_for_new_releases() -> Optional[str]:
    """Check for new ComfyUI releases"""
    print("Checking for new ComfyUI releases...")
    
    # Load existing versions
    versions = load_versions()
    
    # Fetch latest releases
    releases = fetch_releases()
    
    if not releases:
        print("No releases found")
        return None
    
    # Get the latest release (first non-prerelease)
    latest_release = None
    for release in releases:
        if not release.get("prerelease", False):
            latest_release = release
            break
    
    if not latest_release:
        print("No stable releases found")
        return None
    
    latest_version = latest_release.get("tag_name")
    
    # Update last checked time
    versions["last_checked"] = datetime.now().isoformat()
    
    # Check if this is a new version
    if latest_version not in versions.get("built_versions", []):
        print(f"New version found: {latest_version}")
        versions["latest_version"] = latest_version
        save_versions(versions)
        return latest_version
    else:
        print(f"Latest version {latest_version} already built")
        save_versions(versions)
        return None

def update_built_version(version: str) -> None:
    """Mark a version as built"""
    versions = load_versions()
    
    if version not in versions.get("built_versions", []):
        versions.setdefault("built_versions", []).append(version)
        versions["last_built"] = datetime.now().isoformat()
        save_versions(versions)
        print(f"Marked version {version} as built")

def main():
    """Main function"""
    if len(sys.argv) > 1:
        # If version is provided as argument, mark it as built
        version = sys.argv[1]
        update_built_version(version)
    else:
        # Check for new releases
        new_version = check_for_new_releases()
        
        if new_version:
            # Output the new version for GitHub Actions
            print(f"::set-output name=new_version::{new_version}")
            print(f"::set-output name=has_new_version::true")
            
            # Also write to environment file for newer Actions
            if "GITHUB_OUTPUT" in os.environ:
                with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                    f.write(f"new_version={new_version}\n")
                    f.write("has_new_version=true\n")
        else:
            print("::set-output name=has_new_version::false")
            
            if "GITHUB_OUTPUT" in os.environ:
                with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                    f.write("has_new_version=false\n")

if __name__ == "__main__":
    main()