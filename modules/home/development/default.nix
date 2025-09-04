{pkgs, ...}: {
  imports = [
    ./git.nix
    ./jujutsu.nix
    ./vscode.nix
    ./python.nix
    ./databases.nix
  ];

  home.packages = [
    # Development tools
    pkgs.uv
    pkgs.ruff
    pkgs.mypy
    pkgs.python3Packages.ipython
    pkgs.python3Packages.jupyterlab
  ];
}
