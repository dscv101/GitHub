{ config, pkgs, lib, ... }:
{
  networking.hostName = "blazar";

  # Display notes: single 1080p@60 on DP-1, scale 1.0, VRR off (handled by defaults)

  # Firewall already enabled in common.
  # Disable auto-upgrades explicitly here too (host policy)
  system.autoUpgrade.enable = lib.mkDefault false;
}
