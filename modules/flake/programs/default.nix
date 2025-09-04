_: {
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
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
        nix-tree # Visualize Nix dependencies
        nix-diff # Compare Nix derivations
        nixpkgs-review # Review nixpkgs PRs
        nurl # Generate Nix fetcher expressions

        # Shell script tooling
        shellcheck # Shell script linter
        shfmt # Shell script formatter

        # Documentation and config linting
        markdownlint-cli # Markdown linter
        yamllint # YAML linter
        actionlint # GitHub Actions linter

        # Additional formatters and tools
        keep-sorted # Keep imports and lists sorted
        taplo # TOML formatter
        stylua # Lua formatter
        treefmt # Unified formatter

        # Additional useful tools
        just
        sops
        age
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
