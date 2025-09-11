{inputs, ...}: {
  imports = [
    inputs.devenv.flakeModule
    ./python.nix
    ./rust.nix
    ./zig.nix
    ./julia.nix
  ];

  perSystem = {pkgs, sharedPackages, ...}: {
    # Base development shell with common tools
    devenv.shells.default = {
      name = "nix-blazar-dev";

      # Containers disabled for simplicity - can be enabled later if needed
      # containers.enable = false; # Commented out due to type mismatch

      packages = sharedPackages.full;

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

      # Git hooks for code quality (disabled for now to focus on package consolidation)
      # git-hooks.hooks = {
      #   # Nix
      #   alejandra.enable = true;
      #   statix.enable = true;
      #   deadnix.enable = true;
      #
      #   # Shell scripts
      #   shellcheck.enable = true;
      #   shfmt.enable = true;
      #
      #   # Documentation
      #   markdownlint.enable = true;
      #
      #   # General
      #   check-yaml.enable = true;
      #   check-toml.enable = true;
      #   end-of-file-fixer.enable = true;
      #   trailing-whitespace.enable = true;
      # };
    };
  };
}
