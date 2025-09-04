# nix-blazar

Modular NixOS flake (flake-parts) for **blazar** (Ryzen 7 5800X + NVIDIA GTX 970), Wayland-only **Niri**, Home Manager, JJ (Jujutsu) stacked-PR workflow, DuckDB + MotherDuck, Podman, sops-nix, Disko, and Impermanence.

## Highlights
- **Wayland/GBM** with NVIDIA (closed driver), Niri compositor, greetd+tuigreet login.
- **Home Manager** user `dscv`: zsh + Starship, VS Code (official), Ghostty, Waybar, Mako, fuzzel.
- **Dev toolchain**: uv/ruff/mypy/pytest, DuckDB + extensions, Postgres/SQLite clients, direnv+devenv.
- **Secrets** via **sops-nix**; **Tailscale** auto-join (SSH enabled); MotherDuck token ready.
- **Disk layout** via **Disko**: EFI 1.5GiB → LUKS2 → Btrfs (@, @home, @nix, @log, @persist, @snapshots).
- **Impermanence**: persist only curated paths under `/persist`.
- **Backups**: restic → rclone(B2) daily @ 03:30 (custom systemd unit).

## Install (from ISO, declarative Disko)
```bash
# 1) Boot official NixOS ISO, ensure internet
nix-shell -p git --run 'git clone <your-fork-or-local-path> nix-blazar && cd nix-blazar'

# 2) Partition/format/mount
sudo nix run github:nix-community/disko -- --mode disko ./hosts/blazar/disko.nix

# 3) Install
sudo nixos-install --flake .#blazar
reboot
```

## First boot checklist
1. Run `./scripts/init-secrets.sh` to generate the age key and create a placeholder `secrets.sops.yaml`.
2. Put your **Tailscale** auth key, **B2** creds, **RESTIC_PASSWORD**, etc. in `secrets/sops/secrets.sops.yaml` and encrypt with:
   ```bash
   sops -e -i secrets/sops/secrets.sops.yaml
   ```
3. (Optional) Add an rclone config as a SOPS file/secret if you prefer a standalone config file.
4. Login as **dscv**; greetd will present a TUI; select the **niri** session.
5. Verify Wayland: `echo $XDG_SESSION_TYPE` → `wayland`.

## Common commands
- Rebuild: `sudo nixos-rebuild switch --flake .#blazar`
- Check: `nix flake check`
- Dev shell: `nix develop`
- JJ status: `jj st`

## Notes
- This repo is a **skeleton**: adjust as needed (Waybar style, Niri output names, etc.).
- For NVIDIA Wayland quirks, `WLR_NO_HARDWARE_CURSORS=1` is set; you can remove if not needed.
- Impermanence binds from `/persist` to listed paths; see `hosts/blazar/default.nix`.
