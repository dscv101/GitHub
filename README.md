# Blazar NixOS Flake

Wayland-only desktop based on **Niri** with NVIDIA (GBM), Home Manager, `sops-nix`, `disko`, and impermanence.

> ⚠️ Replace the disk device in `hosts/blazar/disko.nix` before installing (`DEVICE_REPLACE_ME`).

## Quick start

```bash
# format/install (from NixOS installer ISO with flakes enabled)
nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- \
  --mode disko ./hosts/blazar/disko.nix

nixos-install --flake .#blazar
```

## Post-install
- Put your age key at `/var/lib/sops-nix/key.txt` and replace `secrets/secrets.yaml` with a real SOPS-encrypted file.
- Set `restic` repository and rclone remote, then `sudo systemctl enable --now restic-backups-home.timer`.
- Log into VS Code and install additional marketplace extensions (Claude Code, PostgreSQL) as desired.

## Notes
- HM service oneshot restart override included at `nixos/overrides/home-manager-service.nix`.
- Impermanence persists: `/var/lib/systemd/coredump`, `/var/lib/nixos`, `/var/lib/tailscale`, and key user dirs.
- Greetd + Tuigreet starts **Niri**; App launcher bound to **Super+Space** via Fuzzel.
```

