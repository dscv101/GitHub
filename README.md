# nyx (fixed sample)

This minimal repo is structured to **pass `nix flake check`** for CI and to address all errors shown in your logs:

- Removed deprecated `sound.enable`.
- Added a **temporary tmpfs root** so evaluation doesn't fail in CI: `fileSystems."/".fsType = "tmpfs"`.
  Replace this with your real `disko`/`fileSystems` config on machines.
- Removed `programs.rclone` (doesn't exist); install `rclone` via `environment.systemPackages` or Home Manager `home.packages`.
- Avoided setting `Restart=always` on oneshot services (which broke Home Manager service).
- Cleaned up VS Code extensions to ones that are **packaged** in nixpkgs to avoid attribute errors.
- Set `system.stateVersion = "24.05"`.

## Layout

- `flake.nix` — flake-parts + NixOS config for host `blazar`
- `nixos/hosts/blazar.nix` — minimal NixOS module
- `home/dscv/home.nix` — Home Manager config

## Usage

```bash
nix flake show
nix flake check
# build/test the NixOS config (eval only in CI)
nix build .#nixosConfigurations.blazar.config.system.build.toplevel
```

## Notes

- Replace the tmpfs root with your real disk layout or disko config before installing on hardware.
- If you need un-packaged VS Code extensions, use `pkgs.vscode-utils.extensionsFromVscodeMarketplace` or an overlay, but be aware this can break reproducibility/CI.
