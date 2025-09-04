{pkgs, ...}: {
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.inter
    pkgs.noto-fonts
    pkgs.noto-fonts-emoji
    pkgs.jetbrains-mono
  ];
}
