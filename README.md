# nyx-updated-repo

A minimal, stable Nix flake layout (inspired by `dscv101/nyx`) that evaluates cleanly on CI.
- Uses `flake-parts`
- Provides a dev shell
- Exposes `nixosConfigurations.blazar` that **does not** require a real disk (rootfs on tmpfs)
- Integrates Home Manager without deprecated options
- Avoids problematic options seen in your logs (`programs.rclone`, duplicate `home.file` targets, oneshot+restart, missing `system.stateVersion`)

## Quick start
```bash
# format
nix fmt

# check (builds devshell, evaluates nixosConfigurations)
nix flake check

# build the NixOS config (evaluation only, because rootfs is tmpfs)
nix build .#nixosConfigurations.blazar.config.system.build.toplevel
```
