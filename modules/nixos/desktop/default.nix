{pkgs, ...}: {
  imports = [
    ./niri.nix
    ./fonts.nix
    ./wayland.nix
  ];

  # Common desktop applications
  environment.systemPackages = with pkgs; [
    # GUI applications
    firefox
    xfce.thunar
    zathura
    imv
    mpv

    # Screenshots / wayland tools
    grim
    slurp
    swappy
    swww
    wl-clipboard
    cliphist

    # Theming
    papirus-icon-theme
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
