{pkgs, ...}: {
  # Common base apps
  environment.systemPackages = with pkgs; [
    # GUI
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

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    inter
    noto-fonts
    noto-fonts-emoji
    jetbrains-mono
  ];
}
