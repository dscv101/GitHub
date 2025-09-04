{ config, pkgs, lib, ... }:
{
  home.username = "dscv";
  home.homeDirectory = "/home/dscv";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Valid Home Manager modules
  programs.fzf.enable = true;
  programs.gh.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true; # correct option name (vs nonexistent programs.zsh.autosuggestions.enable)
  };

  # Per-user packages
  home.packages = with pkgs; [
    rclone
  ];

  # VS Code with extensions (correct attr path)
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
      ms-ossdata.vscode-postgresql
      ms-mssql.mssql
      ziglang.vscode-zig
    ];
  };
}