{pkgs, ...}: {
  imports = [
    ./git.nix
    ./sapling.nix
    ./watchman.nix
    ./vscode.nix
    ./python.nix
    ./databases.nix
  ];

  home.packages = [
    # Development tools
    pkgs.uv
    pkgs.ruff
    # Note: pyrefly installed via uv/pip (not in nixpkgs yet)
    # pkgs.pyrefly
    pkgs.python3Packages.ipython
    pkgs.python3Packages.jupyterlab
    # Version control and file watching
    pkgs.sapling
    pkgs.watchman
  ];
}
