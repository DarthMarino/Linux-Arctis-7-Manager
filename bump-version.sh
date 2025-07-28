#!/bin/bash
# Version bumping script for Linux-Arctis-7-Manager

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/VERSION.ini"

# Function to display usage
usage() {
    echo "Usage: $0 [major|minor|patch|VERSION]"
    echo "  major: Bump major version (X.0.0)"
    echo "  minor: Bump minor version (X.Y.0)" 
    echo "  patch: Bump patch version (X.Y.Z)"
    echo "  VERSION: Set specific version (e.g., 1.2.3)"
    echo ""
    echo "Examples:"
    echo "  $0 patch      # 1.6.1 -> 1.6.2"
    echo "  $0 minor      # 1.6.1 -> 1.7.0"  
    echo "  $0 major      # 1.6.1 -> 2.0.0"
    echo "  $0 1.8.0      # Set to 1.8.0"
    exit 1
}

# Function to validate semantic version
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Invalid version format. Use semantic versioning (X.Y.Z)"
        exit 1
    fi
}

# Function to compare versions (returns 0 if v1 >= v2, 1 if v1 < v2)
version_compare() {
    local v1=$1
    local v2=$2
    
    IFS='.' read -ra V1 <<< "$v1"
    IFS='.' read -ra V2 <<< "$v2"
    
    for i in {0..2}; do
        local num1=${V1[i]:-0}
        local num2=${V2[i]:-0}
        
        if (( num1 > num2 )); then
            return 0
        elif (( num1 < num2 )); then
            return 1
        fi
    done
    return 1  # versions are equal, considered as "not greater"
}

# Get current version
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        # Try new format first (version=X.Y.Z)
        local version=$(grep -E "^version\s*=" "$VERSION_FILE" 2>/dev/null | sed 's/.*=\s*//' | tr -d '"' | tr -d "'")
        if [[ -n "$version" ]]; then
            echo "$version"
            return
        fi
        
        # Try old format (SOFTWARE=X.Y.Z)
        version=$(grep -E "^SOFTWARE\s*=" "$VERSION_FILE" 2>/dev/null | sed 's/.*=\s*//' | tr -d '"' | tr -d "'")
        if [[ -n "$version" ]]; then
            echo "$version"
            return
        fi
    fi
    
    echo "1.6.3"  # Default starting version from existing file
}

# Bump version based on type
bump_version() {
    local current=$1
    local bump_type=$2
    
    IFS='.' read -ra VERSION_PARTS <<< "$current"
    local major=${VERSION_PARTS[0]}
    local minor=${VERSION_PARTS[1]}
    local patch=${VERSION_PARTS[2]}
    
    case $bump_type in
        "major")
            echo "$((major + 1)).0.0"
            ;;
        "minor")
            echo "${major}.$((minor + 1)).0"
            ;;
        "patch")
            echo "${major}.${minor}.$((patch + 1))"
            ;;
        *)
            echo "Error: Invalid bump type"
            exit 1
            ;;
    esac
}

# Main logic
if [[ $# -ne 1 ]]; then
    usage
fi

BUMP_TYPE=$1
CURRENT_VERSION=$(get_current_version)

echo "Current version: $CURRENT_VERSION"

# Determine new version
if [[ $BUMP_TYPE =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # Specific version provided
    NEW_VERSION=$BUMP_TYPE
    validate_version "$NEW_VERSION"
    
    # Check if new version is greater than current
    if ! version_compare "$NEW_VERSION" "$CURRENT_VERSION"; then
        echo "Error: New version ($NEW_VERSION) must be greater than current version ($CURRENT_VERSION)"
        exit 1
    fi
elif [[ $BUMP_TYPE =~ ^(major|minor|patch)$ ]]; then
    # Bump type provided
    NEW_VERSION=$(bump_version "$CURRENT_VERSION" "$BUMP_TYPE")
else
    echo "Error: Invalid argument. Use 'major', 'minor', 'patch', or a specific version."
    usage
fi

echo "New version: $NEW_VERSION"

# Create/update VERSION.ini
cat > "$VERSION_FILE" << EOF
# Version file for Linux-Arctis-7-Manager
# This file is used by the build system and GitHub Actions
version=$NEW_VERSION
EOF

# Update debian/changelog
if [[ -f "$SCRIPT_DIR/debian/changelog" ]]; then
    # Backup current changelog
    cp "$SCRIPT_DIR/debian/changelog" "$SCRIPT_DIR/debian/changelog.bak"
    
    # Create new changelog entry
    cat > "$SCRIPT_DIR/debian/changelog" << EOF
arctis-manager ($NEW_VERSION-1) unstable; urgency=medium

  * Version bump to $NEW_VERSION
  * See GitHub releases for detailed changelog

 -- DarthMarino <https://github.com/DarthMarino>  $(date -R)

EOF
    
    # Append old changelog
    cat "$SCRIPT_DIR/debian/changelog.bak" >> "$SCRIPT_DIR/debian/changelog"
fi

echo ""
echo "Version updated successfully!"
echo "Files updated:"
echo "  - VERSION.ini"
if [[ -f "$SCRIPT_DIR/debian/changelog" ]]; then
    echo "  - debian/changelog"
fi

echo ""
echo "Next steps:"
echo "1. Review the changes"
echo "2. Commit and push to trigger automatic build:"
echo "   git add VERSION.ini debian/changelog"
echo "   git commit -m \"Bump version to $NEW_VERSION\""
echo "   git push origin main"
echo ""
echo "3. GitHub Actions will automatically:"
echo "   - Build Flatpak, Debian, and RPM packages"
echo "   - Create a GitHub release with binaries"
echo "   - Tag the release as v$NEW_VERSION"