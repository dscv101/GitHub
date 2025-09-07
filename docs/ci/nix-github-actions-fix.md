# Fix for Nix GitHub Actions CI Issues

## Problem

If you're seeing errors like:

```
Warning: Unexpected input(s) 'github_token', valid inputs are ['extra_nix_config', 'github_access_token', 'install_url', 'install_options', 'nix_path', 'enable_kvm']
```

Or:

```
sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper
sudo: a password is required
```

This is caused by using the deprecated `cachix/install-nix-action` in your GitHub Actions workflows.

## Solution

Replace the old action with the modern `DeterminateSystems/determinate-nix-action`:

### ❌ Old (Deprecated)
```yaml
- name: Install Nix
  uses: cachix/install-nix-action@v31
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}  # This parameter causes issues
    install_url: https://releases.nixos.org/nix/nix-2.31.0/install
    extra_nix_config: |
      experimental-features = nix-command flakes
```

### ✅ New (Recommended)
```yaml
- name: Install Determinate Nix
  uses: DeterminateSystems/determinate-nix-action@v3.5.2
  # No additional parameters needed - it handles everything automatically

- name: Setup Magic Nix Cache (Optional)
  uses: DeterminateSystems/magic-nix-cache-action@v13
```

## Why This Fixes the Issue

1. **No sudo required**: The Determinate Systems installer doesn't require sudo permissions in CI environments
2. **No github_token conflicts**: The modern action doesn't use the problematic `github_token` parameter
3. **Better defaults**: Automatically enables flakes and other modern Nix features
4. **Faster builds**: Includes built-in caching and optimization
5. **Active maintenance**: The Determinate Systems actions are actively maintained

## Additional Benefits

- **Magic Nix Cache**: Automatic binary caching for faster CI runs
- **Better error messages**: More helpful debugging information
- **Security**: Follows modern GitHub Actions security best practices
- **Reliability**: More stable installation process

## Migration Checklist

- [ ] Replace `cachix/install-nix-action` with `DeterminateSystems/determinate-nix-action`
- [ ] Remove `github_token` parameter
- [ ] Remove `install_url` parameter (uses latest stable by default)
- [ ] Simplify `extra_nix_config` (flakes enabled by default)
- [ ] Add `DeterminateSystems/magic-nix-cache-action` for faster builds
- [ ] Test the updated workflow

## Example Complete Workflow

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  nix-build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install Determinate Nix
        uses: DeterminateSystems/determinate-nix-action@v3.5.2

      - name: Setup Magic Nix Cache
        uses: DeterminateSystems/magic-nix-cache-action@v13

      - name: Check flake
        run: nix flake check

      - name: Build system
        run: nix build .#nixosConfigurations.myhost.config.system.build.toplevel
```

## References

- [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/determinate-nix-action)
- [Magic Nix Cache Action](https://github.com/DeterminateSystems/magic-nix-cache-action)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
