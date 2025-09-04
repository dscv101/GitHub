{inputs, ...}: {
  imports = [
    inputs.devenv.flakeModule
    ./python.nix
    ./rust.nix
    ./zig.nix
    ./julia.nix
  ];

  perSystem = {pkgs, ...}: {
    # Base development shell with common tools
    devenv.shells.default = {
      name = "nix-blazar-dev";

      # Disable containers to avoid the current directory issue
      containers = {};

      packages = with pkgs; [
        # Version control
        git
        jujutsu

        # Development environment
        direnv
        devenv

        # Nix tooling
        alejandra
        statix
        deadnix
        nixfmt-rfc-style
        nix-tree
        nix-diff
        nixpkgs-review
        nurl

        # Shell script tooling
        shellcheck
        shfmt

        # Documentation and config linting
        markdownlint-cli
        yamllint
        actionlint

        # Additional formatters and tools
        keep-sorted
        taplo
        stylua
        treefmt

        # Useful development tools
        just
        sops
        age
        curl
        wget
        jq
        yq
      ];

      env = {
        DEVENV_ROOT = "$PWD";
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
