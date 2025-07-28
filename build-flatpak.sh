#!/bin/bash
# Build script for Flatpak package

set -e

echo "Building Flatpak package for Linux-Arctis-7-Manager..."

# Check if we're in the right directory
if [[ ! -f "io.github.DarthMarino.ArctisManager.yml" ]]; then
    echo "Error: Flatpak manifest not found. Please run this script from the project root directory"
    exit 1
fi

# Check if flatpak is installed
if ! command -v flatpak &> /dev/null; then
    echo "Error: Flatpak is not installed. Please install flatpak first:"
    echo "  Ubuntu/Debian: sudo apt install flatpak"
    echo "  Fedora: sudo dnf install flatpak"
    echo "  Arch: sudo pacman -S flatpak"
    exit 1
fi

# Check if flatpak-builder is installed
if ! command -v flatpak-builder &> /dev/null; then
    echo "Error: flatpak-builder is not installed. Please install it first:"
    echo "  Ubuntu/Debian: sudo apt install flatpak-builder"
    echo "  Fedora: sudo dnf install flatpak-builder"
    echo "  Arch: sudo pacman -S flatpak-builder"
    exit 1
fi

# Add Flathub repository if not already added
echo "Ensuring Flathub repository is available..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install KDE runtime if not already installed
echo "Installing KDE runtime..."
flatpak install -y flathub org.kde.Platform//6.7 org.kde.Sdk//6.7 || true

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf build-dir .flatpak-builder

# Build the Flatpak
echo "Building Flatpak package..."
flatpak-builder --force-clean --install-deps-from=flathub build-dir io.github.DarthMarino.ArctisManager.yml

# Create a local repository and export the app
echo "Creating local repository..."
flatpak-builder --repo=repo --force-clean build-dir io.github.DarthMarino.ArctisManager.yml

echo "Building bundle..."
flatpak build-bundle repo arctis-manager.flatpak io.github.DarthMarino.ArctisManager

echo "Flatpak package built successfully!"
echo "Package file: arctis-manager.flatpak"
echo ""
echo "To install locally:"
echo "  flatpak install arctis-manager.flatpak"
echo ""
echo "To test the app:"
echo "  flatpak run io.github.DarthMarino.ArctisManager"