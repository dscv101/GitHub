# Fixed flake skeleton

This is a minimal, working skeleton that addresses the errors you saw:

- Replaced `programs.rclone` (doesn't exist) with installing `rclone` as a package.
- Moved `programs.fzf` and `programs.gh` into **Home Manager** (they are HM modules, not NixOS modules).
- Corrected zsh autosuggestions to `programs.zsh.enableAutosuggestions = true;`.
- Fixed VS Code extensions to use `pkgs.vscode-extensions.<publisher>.<name>`.
- Removed deprecated `sound.enable` and added a minimal root filesystem so evaluation succeeds in CI.

## Try it

```bash
nix flake check
# or build the system:
# sudo nixos-rebuild switch --flake .#blazar
```

Integrate pieces back into your real repo as needed.