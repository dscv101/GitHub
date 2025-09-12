# Module Import Optimization

This document describes the performance optimizations made to the module import system.

## Changes Made

### 1. Conditional Module Loading
- Added `modules/common.nix` with configuration options for enabling/disabling features
- Modified main modules to use `lib.optional` for conditional imports
- Desktop and development modules are now optional and can be disabled

### 2. Performance Benefits
- **Faster Evaluation**: Unused modules are not evaluated when disabled
- **Reduced Memory Usage**: Only load what's needed
- **Flexible Configuration**: Easy to create minimal configurations for different use cases

### 3. Configuration Options

```nix
{
  # Disable desktop environment for server/headless systems
  modules.desktop.enable = false;

  # Disable development tools for production systems
  modules.development.enable = false;

  # Enable virtualization only when needed
  modules.virtualization.enable = true;

  # Keep networking and security enabled (recommended)
  modules.networking.enable = true;
  modules.security.enable = true;
}
```

### 4. Optimized specialArgs
- Improved how data is passed between modules
- Only pass necessary inputs to reduce evaluation overhead

## Usage Examples

### Minimal Server Configuration
```nix
{
  modules.desktop.enable = false;
  modules.development.enable = false;
  modules.virtualization.enable = false;
}
```

### Development Workstation
```nix
{
  modules.desktop.enable = true;
  modules.development.enable = true;
  modules.virtualization.enable = false;
}
```

### Desktop-Only System
```nix
{
  modules.desktop.enable = true;
  modules.development.enable = false;
  modules.virtualization.enable = false;
}
```

## Migration Guide

Existing configurations will continue to work as all modules are enabled by default. To optimize performance:

1. Review which features you actually use
2. Add configuration options to disable unused features
3. Test your configuration after changes

## Files Modified

- `modules/common.nix` - New shared configuration options
- `modules/nixos/default.nix` - Conditional imports for NixOS modules
- `modules/home/default.nix` - Conditional imports for Home Manager modules
- `modules/nixos/services/default.nix` - Conditional development services
- `systems/default.nix` - Optimized specialArgs usage
- `modules/config-example.nix` - Example configurations

## Validation

To validate your configuration after changes:

```bash
# Check for syntax errors
nix flake check

# Build your system
sudo nixos-rebuild build

# Test in VM (if available)
nixos-rebuild build-vm
```

