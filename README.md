# nix-blazar (fixed2)

This version fixes:
- `programs.fzf` defined at system level (moved to Home Manager)
- Removed redundant manual `/persist` mount (Disko mounts it)
- Prior `loginctl.linger` option issue already resolved

## Install (ISO + Disko)
```bash
nix-shell -p git --run 'git clone <your repo> nix-blazar && cd nix-blazar'
sudo nix run github:nix-community/disko -- --mode disko ./hosts/blazar/disko.nix
sudo nixos-install --flake .#blazar
reboot
```
After boot:
```bash
./scripts/init-secrets.sh
sops -e -i secrets/sops/secrets.sops.yaml
```
Fill Tailscale/B2/Restic secrets and rebuild: `sudo nixos-rebuild switch --flake .#blazar`.
