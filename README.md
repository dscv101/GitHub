# nix-blazar (fixed)

This fixes the CI error (`loginctl` option) and avoids building Marketplace-only VS Code extensions during `flake check`.

**Highlights:** Wayland/Niri, NVIDIA (GBM), HM user `dscv`, sops-nix, Disko, Impermanence, DuckDB + Postgres/SQLite clients, Podman, JJ.

## Install (ISO + Disko)
```bash
nix-shell -p git --run 'git clone <your repo> nix-blazar && cd nix-blazar'
sudo nix run github:nix-community/disko -- --mode disko ./hosts/blazar/disko.nix
sudo nixos-install --flake .#blazar
reboot
```

## After boot
```bash
./scripts/init-secrets.sh
sops -e -i secrets/sops/secrets.sops.yaml
```
Fill Tailscale/B2/Restic secrets and rebuild: `sudo nixos-rebuild switch --flake .#blazar`.
