{ config, pkgs, ... }:
{
  home.username = "dscv";
  home.homeDirectory = "/home/dscv";

  programs.git.enable = true;
  programs.zsh.enable = true;

  # Keep home.file empty to avoid duplicate targets assertion.
  home.file = { };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
    ];
  };

  # Helpful language servers/tools
  home.packages = with pkgs; [
    nil
    alejandra
  ];

  home.stateVersion = "24.05";
}
