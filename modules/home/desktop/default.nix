{ pkgs, ... }:
{
  imports = [
    ./niri.nix
    ./waybar.nix
    ./terminal.nix
    ./launcher.nix
    ./notifications.nix
    ./lockscreen.nix
    ./portals.nix
  ];

  home.packages = with pkgs; [
    # Wayland desktop helpers
    waybar
    swaylock-effects
    swww
    swappy
    grim
    slurp
    wl-clipboard
    cliphist
  ];
}
