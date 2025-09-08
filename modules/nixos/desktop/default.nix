{pkgs, ...}: {
  imports = [
    ./niri.nix
    ./fonts.nix
    ./wayland.nix
    ./sddm.nix
  ];

  # Common desktop applications
  environment.systemPackages = [
    # GUI applications
    pkgs.firefox
    pkgs.xfce.thunar
    pkgs.zathura
    pkgs.imv
    pkgs.mpv

    # Screenshots / wayland tools
    pkgs.grim
    pkgs.slurp
    pkgs.swappy
    pkgs.swww
    pkgs.wl-clipboard
    pkgs.cliphist

    # Theming
    pkgs.papirus-icon-theme
  ];

  # XDG portals for Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  # Wayland session variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron/Chromium on Wayland
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
