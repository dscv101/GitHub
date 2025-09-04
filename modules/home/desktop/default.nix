{pkgs, ...}: {
  imports = [
    ./niri.nix
    ./waybar.nix
    ./terminal.nix
    ./launcher.nix
    ./notifications.nix
    ./lockscreen.nix
    ./portals.nix
  ];

  home.packages = [
    # Wayland desktop helpers
    pkgs.waybar
    pkgs.swaylock-effects
    pkgs.swww
    pkgs.swappy
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.cliphist
  ];
}
