{ pkgs, ... }:
{
  # Common base apps
  environment.systemPackages = with pkgs; [
    # GUI
    firefox thunar zathura imv mpv
    # Screenshots / wayland tools
    grim slurp grimshot swappy swww
    wl-clipboard cliphist
    # Theming
    papirus-icon-theme
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    inter noto-fonts noto-fonts-emoji
    jetbrains-mono
  ];
}
