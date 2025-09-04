{ lib ? import <nixpkgs/lib> {}, ... }:
{
  # Example host module (not imported by the flake)
  networking.hostName = "blazar";
  system.stateVersion = "24.05";
}
