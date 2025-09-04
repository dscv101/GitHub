# Updated Nix Flake Template

This repo demonstrates the fixes discussed:
- Escapes Bash `${…}` expansions in the flake `formatter` script (`''${1-}`).
- Provides an **eval-safe NixOS** configuration (`blazar`) with a tmpfs `/` so `nix flake check` can evaluate in CI without host disks.
- Uses a minimal Home Manager user `dscv` and avoids problematic VS Code extension attribute names.

## Quick use

```bash
nix fmt -- --check
nix flake check
nix develop
```

To adapt to your real host, replace the `fileSystems."/"` tmpfs with your actual root filesystem or your disko config, and extend `home/dscv/default.nix` as needed.
