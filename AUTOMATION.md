# Automated Building and Release

This document explains the automated CI/CD pipeline for Linux-Arctis-7-Manager using GitHub Actions.

## Overview

The project uses a fully automated approach to version management and package building:

- **Version Management**: Semantic versioning with automated version bumping
- **Package Building**: Automatic builds for Flatpak, Debian (.deb), and RPM packages
- **Release Management**: Automatic GitHub releases with downloadable binaries
- **Quality Control**: Version validation prevents downgrades

## Workflow Triggers

The build pipeline triggers on:

1. **Push to main branch** when:
   - `VERSION.ini` file changes
   - Source code changes (`arctis_manager.py`, `arctis_manager/**`)
   - Packaging files change (`debian/**`, `*.yml`, `*.spec`)
   - System integration files change (`systemd/**`, `udev/**`)

2. **Manual trigger** via GitHub Actions UI:
   - Can force build even without version changes
   - Useful for testing or rebuilding

## Version Management

### Automatic Version Bumping

Use the provided script to bump versions:

```bash
# Patch version (1.6.1 → 1.6.2)
./bump-version.sh patch

# Minor version (1.6.1 → 1.7.0)  
./bump-version.sh minor

# Major version (1.6.1 → 2.0.0)
./bump-version.sh major

# Specific version
./bump-version.sh 1.8.0
```

### Version File Structure

The `VERSION.ini` file contains:
```ini
# Version file for Linux-Arctis-7-Manager
# This file is used by the build system and GitHub Actions
version=1.6.1
```

## Build Process

When triggered, the workflow:

1. **Version Check**: Compares current version with latest release
2. **Multi-format Build**: Builds packages in parallel
3. **Quality Assurance**: Validates all packages build successfully
4. **Release Creation**: Creates GitHub release with all packages

### Supported Package Formats

#### Flatpak Package
- **Target**: Universal Linux distribution
- **Runtime**: KDE Platform 6.7
- **Features**: Sandboxed with proper permissions
- **Size**: ~15-20 MB (including dependencies)

#### Debian Package (.deb)
- **Target**: Ubuntu, Debian, and derivatives
- **Dependencies**: System packages only
- **Integration**: systemd services, udev rules
- **Size**: ~5-10 MB

#### RPM Package (.rpm)
- **Target**: Fedora, RHEL, openSUSE, and derivatives  
- **Features**: Native RPM integration
- **Services**: systemd user services
- **Size**: ~5-10 MB

## Release Workflow

### Automatic Release Process

1. **Developer Action**:
   ```bash
   ./bump-version.sh patch
   git add VERSION.ini debian/changelog
   git commit -m "Bump version to 1.6.2"
   git push origin main
   ```

2. **GitHub Actions**:
   - Detects version change
   - Builds all package formats
   - Runs quality checks
   - Creates GitHub release
   - Tags commit with `v1.6.2`

3. **Release Assets**:
   - `arctis-manager-1.6.2.flatpak`
   - `arctis-manager_1.6.2-1_amd64.deb`
   - `arctis-manager-1.6.2-1.fc39.x86_64.rpm`

### Manual Release Process

For emergency releases or testing:

1. Go to GitHub Actions tab
2. Select "Build and Release Packages"
3. Click "Run workflow"
4. Check "Force build even if version unchanged"
5. Click "Run workflow"

## Quality Control

### Version Validation
- **No Downgrades**: New version must be higher than previous
- **Semantic Versioning**: Enforces X.Y.Z format
- **Build Requirements**: All packages must build successfully

### Build Matrix
The workflow tests across:
- **Flatpak**: Fedora 39 container with KDE Platform
- **Debian**: Ubuntu latest with all dependencies
- **RPM**: Fedora 39 with RPM build tools

## Distribution Channels

### GitHub Releases
- **Primary Distribution**: All packages available as release assets
- **Installation Instructions**: Included in release notes
- **Automatic Notifications**: GitHub followers get notified

### Future Channels
- **Flathub**: Manual submission required (see workflow notification)
- **Debian Repository**: Can be set up with additional automation
- **Fedora COPR**: Can be automated with additional setup

## Troubleshooting

### Common Issues

1. **Build Failure**:
   - Check GitHub Actions logs
   - Verify dependencies in requirements.txt
   - Test local build with `./build-deb.sh` or `./build-flatpak.sh`

2. **Version Not Detected**:
   - Ensure VERSION.ini format is correct
   - Check file is committed and pushed
   - Verify workflow trigger paths in `.github/workflows/`

3. **Package Installation Issues**:
   - Test packages locally before pushing version bump
   - Check dependency lists in debian/control
   - Verify systemd service files are correct

### Debug Mode

Enable debug mode by:
1. Adding `ACTIONS_STEP_DEBUG=true` to repository secrets
2. Re-running failed workflow
3. Check detailed logs in GitHub Actions

## Security Considerations

### Repository Secrets
No sensitive secrets required - workflow uses:
- `GITHUB_TOKEN`: Automatically provided by GitHub
- Public repositories and standard build tools

### Package Signing
Currently packages are unsigned. To add signing:
1. Generate GPG keys
2. Add private key to repository secrets
3. Update workflow to sign packages during build

## Monitoring

### Build Status
- **GitHub Actions Badge**: Add to README for build status
- **Release History**: Track via GitHub releases page
- **Download Statistics**: Available in repository insights

### Notifications
- **Successful Builds**: Create GitHub release
- **Failed Builds**: GitHub sends email to repository owner
- **Flathub Submission**: Manual notification in workflow

## Best Practices

### Version Management
- **Patch**: Bug fixes, minor improvements
- **Minor**: New features, significant improvements  
- **Major**: Breaking changes, major rewrites

### Commit Messages
- Use clear, descriptive commit messages
- Reference issues when applicable
- Separate version bumps from feature commits

### Testing
- Test locally before version bumps
- Use manual workflow trigger for testing
- Verify packages install correctly on target systems

## Example Workflow

Complete example of releasing version 1.6.2:

```bash
# 1. Make your changes
git add .
git commit -m "Fix ChatMix volume control issue"

# 2. Test locally
./build-deb.sh  # Test Debian build
sudo dpkg -i ../arctis-manager*.deb  # Test installation

# 3. Bump version
./bump-version.sh patch  # 1.6.1 → 1.6.2

# 4. Commit and push
git add VERSION.ini debian/changelog
git commit -m "Bump version to 1.6.2"
git push origin main

# 5. GitHub Actions automatically:
#    - Builds all packages
#    - Creates release v1.6.2
#    - Uploads binaries
```

## Support

For automation-related issues:
- Check GitHub Actions logs first
- Open issue with workflow run URL
- Test local builds to isolate problems