# Linux-Arctis-7-Manager Packaging Guide

This document explains how to build and distribute Linux-Arctis-7-Manager as both Flatpak and Debian packages.

## Overview

This project supports two main distribution methods:
- **Flatpak**: Universal Linux package format, ideal for Flathub distribution
- **Debian Package (.deb)**: Traditional package format for Debian-based distributions

## Prerequisites

### For Flatpak Building
```bash
# Ubuntu/Debian
sudo apt install flatpak flatpak-builder

# Fedora
sudo dnf install flatpak flatpak-builder

# Arch Linux
sudo pacman -S flatpak flatpak-builder
```

### For Debian Package Building
```bash
# Ubuntu/Debian
sudo apt install debhelper-compat python3-dev python3-pip python3-venv \
                 python3-setuptools python3-wheel dh-python build-essential
```

## Building Packages

### Building Flatpak Package

1. **Quick Build**:
   ```bash
   chmod +x build-flatpak.sh
   ./build-flatpak.sh
   ```

2. **Manual Build**:
   ```bash
   # Add Flathub repository
   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   
   # Install KDE runtime
   flatpak install flathub org.kde.Platform//6.7 org.kde.Sdk//6.7
   
   # Build the application
   flatpak-builder --force-clean --install-deps-from=flathub build-dir io.github.DarthMarino.ArctisManager.yml
   
   # Create bundle for distribution
   flatpak-builder --repo=repo --force-clean build-dir io.github.DarthMarino.ArctisManager.yml
   flatpak build-bundle repo arctis-manager.flatpak io.github.DarthMarino.ArctisManager
   ```

3. **Testing the Flatpak**:
   ```bash
   flatpak install arctis-manager.flatpak
   flatpak run io.github.DarthMarino.ArctisManager
   ```

### Building Debian Package

1. **Quick Build**:
   ```bash
   chmod +x build-deb.sh
   ./build-deb.sh
   ```

2. **Manual Build**:
   ```bash
   # Install build dependencies
   sudo apt-get update
   sudo apt-get install debhelper-compat python3-dev python3-pip python3-venv \
                        python3-setuptools python3-wheel dh-python build-essential
   
   # Build the package
   dpkg-buildpackage -us -uc -b
   ```

3. **Installing the .deb Package**:
   ```bash
   sudo dpkg -i ../arctis-manager_*.deb
   sudo apt-get install -f  # Fix any dependency issues
   ```

## Package Contents

### Flatpak Package
- **App ID**: `io.github.DarthMarino.ArctisManager`
- **Runtime**: KDE Platform 6.7
- **Permissions**: USB device access, PulseAudio, systemd user services
- **Size**: ~15-20 MB (including dependencies)

### Debian Package
- **Package Name**: `arctis-manager`
- **Dependencies**: Python 3.9+, PulseAudio utilities, Qt6/X11 libraries
- **Services**: systemd user services, udev rules
- **Size**: ~5-10 MB

## Distribution

### Flathub Submission

To submit to Flathub:

1. Fork the [Flathub repository template](https://github.com/flathub/flathub)
2. Create a new repository named `io.github.DarthMarino.ArctisManager`
3. Copy the `io.github.DarthMarino.ArctisManager.yml` manifest
4. Submit a pull request to Flathub

### Debian Repository

For Debian-based distributions:

1. **Personal Package Archive (PPA)**:
   - Create a Launchpad account
   - Upload source package with `dput`
   - Package will be built automatically

2. **Custom Repository**:
   - Use `reprepro` or similar to create APT repository
   - Host on GitHub Pages or custom server

## File Structure

```
Linux-Arctis-7-Manager/
├── debian/                           # Debian packaging files
│   ├── control                      # Package metadata and dependencies
│   ├── rules                        # Build rules
│   ├── changelog                    # Package changelog
│   ├── copyright                    # Licensing information
│   └── compat                       # Debhelper compatibility level
├── io.github.DarthMarino.ArctisManager.yml  # Flatpak manifest
├── build-flatpak.sh                # Flatpak build script
├── build-deb.sh                    # Debian build script
└── PACKAGING.md                     # This file
```

## Troubleshooting

### Common Flatpak Issues

1. **Runtime not found**: Install the required KDE Platform runtime
2. **Permission errors**: Ensure the manifest has correct finish-args
3. **USB access**: Flatpak requires `--device=all` for USB device access

### Common Debian Issues

1. **Missing dependencies**: Run `sudo apt-get install -f` after installation
2. **systemd service fails**: Check if user systemd is running
3. **udev rules not applied**: Run `sudo udevadm control --reload && sudo udevadm trigger`

## Support

For packaging-related issues:
- Open an issue on the [GitHub repository](https://github.com/DarthMarino/Linux-Arctis-7-Manager)
- Check the existing documentation in the main README
- Test the original install script first to ensure the application works

## License

These packaging files are distributed under the same GPL-3.0+ license as the main project.