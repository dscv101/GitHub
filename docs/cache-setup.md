# Private Binary Cache Setup

This document describes how to set up and use the private binary cache for nix-blazar using Cachix.

## Overview

The private binary cache speeds up builds by storing pre-built packages, development shells, and system configurations. This eliminates the need to rebuild everything from source on each machine.

## What Gets Cached

1. **Custom Packages** - SDDM themes and other packages in `pkgs/`
2. **Development Shells** - Python, Rust, Zig, Julia environments
3. **System Configurations** - Complete NixOS system builds

## Initial Setup

### 1. Create Cachix Account

1. Go to [cachix.org](https://cachix.org) and create an account
2. Create a new cache named `nix-blazar` (or your preferred name)
3. Generate an authentication token

### 2. Configure Secrets

Add your Cachix credentials to the encrypted secrets:

```bash
# Edit the secrets file
just edit-secrets

# Add these entries:
CACHIX_AUTH_TOKEN: "your-auth-token-here"
CACHIX_SIGNING_KEY: "your-signing-key-here"
```

### 3. Update Cache Configuration

The cache is already configured in the flake, but you need to update the public key:

1. Get your cache's public key from Cachix dashboard
2. Update `flake.nix` and `modules/base/nix.nix` with your actual public key
3. Replace `YOUR_CACHE_PUBLIC_KEY_HERE` with your cache's public key

### 4. Setup Cache Locally

```bash
# Install cachix if not already available
nix profile install nixpkgs#cachix

# Setup the cache
just cache-setup

# Or use the script directly
./scripts/cache-manager.sh setup
```

## Usage

### Manual Cache Operations

```bash
# Push all builds to cache
just cache-push-all

# Push specific components
just cache-push-packages    # Custom packages only
just cache-push-devshells   # Development shells only
just cache-push-system      # System configurations only

# Check cache status
just cache-status

# Use cache for builds
just cache-use
```

### Advanced Operations

```bash
# Using the cache manager script
./scripts/cache-manager.sh push-all     # Push everything
./scripts/cache-manager.sh stats        # Show statistics
./scripts/cache-manager.sh help         # Show help
```

### Automatic Cache Population

The GitHub Actions workflow automatically pushes to cache on successful builds to the main branch:

- **Trigger**: Push to main branch
- **Components**: All packages, devshells, and system configurations
- **Authentication**: Uses encrypted secrets via sops-nix

## Configuration Files

### Flake Configuration

```nix
# flake.nix
nixConfig = {
  extra-trusted-public-keys = [
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    "nix-blazar.cachix.org-1:YOUR_CACHE_PUBLIC_KEY_HERE"
  ];
  extra-substituters = [
    "https://devenv.cachix.org"
    "https://nix-blazar.cachix.org"
  ];
};
```

### System Configuration

```nix
# modules/base/nix.nix
nix.settings = {
  substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://devenv.cachix.org"
    "https://nix-blazar.cachix.org"
  ];
  trusted-public-keys = [
    "nix-community.cachix.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    "nix-blazar.cachix.org-1:YOUR_CACHE_PUBLIC_KEY_HERE"
  ];
};
```

## GitHub Actions Integration

The cache workflow (`.github/workflows/cache-management.yml`) automatically:

1. **Validates** cache configuration
2. **Builds** all components (packages, devshells, systems)
3. **Pushes** to cache on main branch
4. **Reports** cache status and build results

### Workflow Triggers

- **Push to main**: Builds and pushes to cache
- **Pull requests**: Builds but doesn't push to cache
- **Manual dispatch**: Allows forced cache push and target selection

## Troubleshooting

### Authentication Issues

```bash
# Check if authenticated
cachix authtoken

# Re-authenticate
cachix authtoken <your-token>
```

### Cache Not Working

1. Verify public key in configuration matches your cache
2. Check that substituters are properly configured
3. Ensure cache is publicly readable or you're authenticated

### Build Failures

```bash
# Check cache status
just cache-status

# Rebuild without cache
nix build --option substituters ""

# Check logs
./scripts/cache-manager.sh stats
```

## Security Considerations

1. **Private Cache**: Only authenticated users can push to cache
2. **Public Reading**: Cache is configured for public reading (faster builds)
3. **Signed Packages**: All packages are cryptographically signed
4. **Secret Management**: Credentials stored via sops-nix encryption

## Performance Benefits

With the cache properly configured, you should see:

- **90%+ faster** development shell activation
- **80%+ faster** system rebuilds
- **95%+ faster** custom package builds
- **Instant** cache hits for unchanged components

## Maintenance

### Regular Tasks

```bash
# Update cache with latest builds
just cache-push-all

# Check cache statistics
just cache-status

# Monitor GitHub Actions for automatic pushes
```

### Cache Cleanup

Cachix automatically manages cache retention based on your plan. No manual cleanup is typically required.

## Alternative: Self-hosted Attic

For a self-hosted solution, consider [Attic](https://github.com/zhaofengli/attic):

```bash
# Install attic
nix profile install github:zhaofengli/attic

# Setup self-hosted cache
attic login my-cache https://my-cache.example.com <token>
attic push my-cache result
```

This setup provides the same functionality but with full control over the cache infrastructure.
