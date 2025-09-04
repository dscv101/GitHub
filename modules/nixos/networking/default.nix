{ ... }:
{
  imports = [
    ./firewall.nix
    ./tailscale.nix
  ];

  # NetworkManager
  networking.networkmanager.enable = true;
}
