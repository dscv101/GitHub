# Traditional devenv.nix for users who prefer the devenv CLI
# This provides the same functionality as the flake-parts integration
# but can be used with `devenv shell` directly
{pkgs, ...}: {
  # Basic packages for development
  packages = [
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

    # Useful development tools
    pkgs.just
    pkgs.sops
    pkgs.age
    pkgs.curl
    pkgs.wget
    pkgs.jq
    pkgs.yq
  ];

  enterShell = ''
    echo "🚀 Development shell ready!"
    echo ""
    echo "This is the traditional devenv.nix shell."
    echo "For language-specific environments, use the flake:"
    echo ""
    echo "  nix develop --no-pure-eval                    # Default shell"
    echo "  nix develop --no-pure-eval .#python          # Python environment"
    echo "  nix develop --no-pure-eval .#rust            # Rust environment"
    echo "  nix develop --no-pure-eval .#zig             # Zig environment"
    echo "  nix develop --no-pure-eval .#julia           # Julia environment"
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

  # Git hooks for code quality
  pre-commit.hooks = {
    # Nix
    alejandra.enable = true;
    statix.enable = true;
    deadnix.enable = true;

    # Shell scripts
    shellcheck.enable = true;
    shfmt.enable = true;

    # Documentation
    markdownlint.enable = true;

    # General
    check-yaml.enable = true;
    check-toml.enable = true;
    end-of-file-fixer.enable = true;
    trailing-whitespace.enable = true;
  };
}
