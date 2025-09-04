_: {
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      buildInputs = [
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
        pkgs.nix-tree # Visualize Nix dependencies
        pkgs.nix-diff # Compare Nix derivations
        pkgs.nixpkgs-review # Review nixpkgs PRs
        pkgs.nurl # Generate Nix fetcher expressions

        # Shell script tooling
        pkgs.shellcheck # Shell script linter
        pkgs.shfmt # Shell script formatter

        # Documentation and config linting
        pkgs.markdownlint-cli # Markdown linter
        pkgs.yamllint # YAML linter
        pkgs.actionlint # GitHub Actions linter

        # Additional formatters and tools
        pkgs.keep-sorted # Keep imports and lists sorted
        pkgs.taplo # TOML formatter
        pkgs.stylua # Lua formatter
        pkgs.treefmt # Unified formatter

        # Additional useful tools
        pkgs.just
        pkgs.sops
        pkgs.age
      ];

      shellHook = ''
        echo "🚀 Development shell ready!"
        echo ""
        echo "Development environments:"
        echo "  devenv shell python  - Python (uv, ruff, mypy, pytest)"
        echo "  devenv shell rust    - Rust (cargo, clippy, rustfmt)"
        echo "  devenv shell zig     - Zig (zig, zls)"
        echo "  devenv shell julia   - Julia (julia, jupyter)"
        echo ""
        echo "Project initialization:"
        echo "  just init-python     - Initialize Python project"
        echo "  just init-rust       - Initialize Rust project"
        echo "  just init-zig        - Initialize Zig project"
        echo "  just init-julia      - Initialize Julia project"
        echo ""
        echo "Available commands:"
        echo "  treefmt              - Format all files (unified)"
        echo "  nix fmt              - Format Nix files (alejandra)"
        echo "  statix check         - Check for Nix anti-patterns"
        echo "  deadnix              - Find dead Nix code"
        echo "  nix flake check      - Validate flake"
        echo "  keep-sorted          - Sort imports and lists"
        echo "  shellcheck scripts/* - Check shell scripts"
        echo "  shfmt -w scripts/*   - Format shell scripts"
        echo "  markdownlint *.md    - Lint Markdown files"
        echo "  yamllint .           - Lint YAML files"
        echo "  actionlint           - Lint GitHub Actions"
        echo "  taplo fmt            - Format TOML files"
        echo "  stylua .             - Format Lua files"
        echo "  just --list          - Show available just recipes"
        echo ""
      '';
    };
  };
}
