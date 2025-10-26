#!/usr/bin/env python3
"""Extract unreleased changes from CHANGELOG.md"""

import re
import sys

def extract_unreleased_changelog(changelog_path='CHANGELOG.md', version=''):
    """Extract the Unreleased section from CHANGELOG.md"""
    try:
        with open(changelog_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Find Unreleased section
        pattern = r'## \[Unreleased\](.*?)(?=## \[|\Z)'
        match = re.search(pattern, content, re.DOTALL)
        
        if match:
            notes = match.group(1).strip()
            # Remove separator lines
            notes = re.sub(r'^---\s*$', '', notes, flags=re.MULTILINE)
            notes = notes.strip()
            
            if notes:
                return notes
        
        # Fallback
        return f"Release v{version}" if version else "Release"
        
    except FileNotFoundError:
        print(f"Error: {changelog_path} not found", file=sys.stderr)
        return f"Release v{version}" if version else "Release"
    except Exception as e:
        print(f"Error extracting changelog: {e}", file=sys.stderr)
        return f"Release v{version}" if version else "Release"

if __name__ == '__main__':
    version = sys.argv[1] if len(sys.argv) > 1 else ''
    changelog = extract_unreleased_changelog(version=version)
    print(changelog)
