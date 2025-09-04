{ pkgs, ... }: {
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  # Keep VS Code minimal to avoid extension attr mismatches during CI.
  programs.vscode.enable = true;

  # If you need rclone, prefer adding the package to avoid unknown NixOS option errors.
  home.packages = [ pkgs.rclone ];
}
