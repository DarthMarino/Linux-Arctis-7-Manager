#!/bin/bash
# Build script for Debian package

set -e

echo "Building Debian package for Linux-Arctis-7-Manager..."

# Check if we're in the right directory
if [[ ! -f "arctis_manager.py" ]]; then
    echo "Error: Please run this script from the project root directory"
    exit 1
fi

# Install build dependencies
echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y debhelper-compat python3-dev python3-pip python3-venv python3-setuptools python3-wheel dh-python build-essential

# Setup Python environment and build PyInstaller binaries
echo "Setting up Python environment..."
python3 -m pip install --upgrade pip pipenv
python3 -m pipenv install --deploy

echo "Building PyInstaller binaries..."
python3 -m pipenv run pyinstaller arctis-manager.spec
python3 -m pipenv run pyinstaller arctis-manager-launcher.spec

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf debian/arctis-manager/ debian/.debhelper/ debian/files debian/debhelper-build-stamp

# Create source package directory
PACKAGE_VERSION=$(grep "version=" VERSION.ini | cut -d'=' -f2 2>/dev/null || echo "1.6.1")
echo "Package version: $PACKAGE_VERSION"

# Build the package
echo "Building package..."
dpkg-buildpackage -us -uc -b

echo "Debian package built successfully!"
echo "Package files are in the parent directory:"
ls -la ../arctis-manager*.deb 2>/dev/null || echo "No .deb files found in parent directory"