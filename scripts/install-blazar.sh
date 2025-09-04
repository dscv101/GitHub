#!/usr/bin/env bash
set -euo pipefail
export NIX_CONFIG="experimental-features = nix-command flakes"
sudo nix run github:nix-community/disko -- --mode disko ./hosts/blazar/disko.nix
sudo nixos-install --flake .#blazar
echo "Reboot, then run ./scripts/init-secrets.sh"
