{inputs, ...}: {
  imports = [
    inputs.devenv.flakeModule
    ./python.nix
    ./rust.nix
    ./zig.nix
    ./julia.nix
  ];

  # Set devenv root for flakes - use flake root
  # devenv.root = ./.; # Commented out to avoid infinite recursion - let devenv auto-detect

  perSystem = {pkgs, ...}: {
    # Base development shell with common tools
    devenv.shells.default = {
      name = "nix-blazar-dev";

      # Disable containers to avoid the current directory issue
      containers = {};

      packages = [
        # Version control
        pkgs.git
        pkgs.jujutsu

        # Development environment
        pkgs.direnv
        pkgs.devenv

        # Nix tooling
        pkgs.alejandra
        pkgs.statix
        pkgs.deadnix
        pkgs.nixfmt-rfc-style
        pkgs.nix-tree
        pkgs.nix-diff
        pkgs.nixpkgs-review
        pkgs.nurl

        # Shell script tooling
        pkgs.shellcheck
        pkgs.shfmt

        # Documentation and config linting
        pkgs.markdownlint-cli
        pkgs.yamllint
        pkgs.actionlint

        # Additional formatters and tools
        pkgs.keep-sorted
        pkgs.taplo
        pkgs.stylua
        pkgs.treefmt

        # Useful development tools
        pkgs.just
        pkgs.sops
        pkgs.age
        pkgs.curl
        pkgs.wget
        pkgs.jq
        pkgs.yq
      ];

      env = {
        # Remove DEVENV_ROOT as it's handled by devenv.root
      };

      enterShell = ''
        echo "🚀 Development shell ready!"
        echo ""
        echo "Available environments:"
        echo "  devenv shell python  - Python development (uv, ruff, mypy, etc.)"
        echo "  devenv shell rust    - Rust development (cargo, clippy, etc.)"
        echo "  devenv shell zig     - Zig development (zig, zls)"
        echo "  devenv shell julia   - Julia development"
        echo ""
        echo "General commands:"
        echo "  treefmt              - Format all files"
        echo "  just --list          - Show available recipes"
        echo "  nix flake check      - Validate flake"
        echo ""
      '';
    };
  };
}
