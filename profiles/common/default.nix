{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    firefox thunar zathura imv mpv
    grim slurp sway-contrib.grimshot swappy swww
    wl-clipboard cliphist
    papirus-icon-theme
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    inter noto-fonts noto-fonts-emoji jetbrains-mono
  ];
}
