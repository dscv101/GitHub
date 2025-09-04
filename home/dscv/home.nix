{ config, lib, pkgs, ... }:
{
  home.username = "dscv";
  home.homeDirectory = "/home/dscv";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # De-duplicate home.file by declaring each target once here.
  home.file = {
    ".editorconfig".text = ''
      root = true
      [*]
      end_of_line = lf
      insert_final_newline = true
    '';
  };

  programs.git.enable = true;

  programs.vscode = {
    enable = true;
    # Keep this list conservative with extensions that are known to exist in nixpkgs.
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
    ];
    userSettings = {
      "editor.formatOnSave" = true;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
    };
  };

  home.packages = with pkgs; [
    nil
    # rclone  # add here if you prefer user scope
  ];
}
