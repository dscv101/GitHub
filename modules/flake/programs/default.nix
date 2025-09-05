_: {
  perSystem = {pkgs, ...}: {
    # Basic development shell (devenv temporarily disabled due to flake check issues)
    devShells.default = pkgs.mkShell {
      buildInputs = [
        # Version control
        pkgs.git
        pkgs.jujutsu

        # Development environment
        pkgs.direnv

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

        # Additional useful tools
        pkgs.just
        pkgs.sops
        pkgs.age
        pkgs.curl
        pkgs.wget
        pkgs.jq
        pkgs.yq
      ];

      shellHook = ''
        echo "🚀 Development shell ready!"
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
