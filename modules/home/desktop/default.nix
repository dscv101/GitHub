{pkgs, ...}: {
  imports = [
    ./niri.nix
    ./waybar.nix
    ./terminal.nix
    ./launcher.nix
    ./notifications.nix
    ./lockscreen.nix
    ./portals.nix
    ./quickshell
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
    
    # Waybar module dependencies
    pkgs.btop                    # System monitor (CPU/Memory click action)
    pkgs.baobab                  # Disk usage analyzer (Disk click action)
    pkgs.pavucontrol             # PulseAudio volume control
    pkgs.pamixer                 # PulseAudio mixer (volume scroll)
    pkgs.networkmanagerapplet    # Network manager GUI
    pkgs.blueman                 # Bluetooth manager
  ];
}
