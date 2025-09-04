#!/usr/bin/env bash
set -euo pipefail

# Run from NixOS live ISO after networking is up.
# Usage:
#   nix shell nixpkgs#git -c git clone https://github.com/dscv101/nix-blazar.git
#   cd nix-blazar
#   bash scripts/install-blazar.sh

export NIX_CONFIG="experimental-features = nix-command flakes"

# Partition & format via disko
sudo nix run github:nix-community/disko -- --mode disko ./systems/blazar/disko.nix

# Mount is handled by disko; verify mounts:
mount | grep -E '/boot| / ' || true

# Install system
sudo nixos-install --flake .#blazar

echo "Installation complete. Reboot when ready."
echo "Post-boot:"
echo "  - Run ./scripts/init-secrets.sh and encrypt secrets with sops"
echo "  - Set Tailscale auth key (sops) and machine will auto-join"
