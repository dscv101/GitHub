{pkgs, ...}: {
  imports = [
    ./git.nix
    ./jujutsu.nix
    ./vscode.nix
    ./python.nix
    ./databases.nix
  ];

  home.packages = with pkgs; [
    # Development tools
    uv
    ruff
    mypy
    python3Packages.ipython
    python3Packages.jupyterlab
  ];
}
