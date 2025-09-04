{pkgs, ...}: {
  # Generic development environment
  packages = with pkgs; [
    git
    direnv
    devenv
  ];
}
