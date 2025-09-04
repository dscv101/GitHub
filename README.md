# nyx-updated skeleton

This repo skeleton is fully formatted for Alejandra and includes:
- `formatter` output for `nix fmt` that accepts `-- --check`.
- A minimal, eval-safe NixOS config (`nixos/hosts/blazar.nix`) that uses a tmpfs `/`.
- Placeholder modules/files matching your paths so the formatter sees them.

## Commands

```bash
nix fmt -- --check     # verify formatting
nix fmt                # apply formatting
nix flake check        # eval NixOS config (safe minimal config)
```
