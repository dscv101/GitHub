# Shared package sets for development environments
# This eliminates duplication between devenv.nix and flake development shells
{pkgs, ...}: let
  inherit (pkgs.lib) concatLists;
in rec {
  # Base development tools that every environment should have
  base = [
    # Version control
    pkgs.git
    pkgs.jujutsu

    # Development environment
    pkgs.direnv

    # Useful development tools
    pkgs.just
    pkgs.curl
    pkgs.wget
    pkgs.jq
    pkgs.yq
  ];

  # Nix-specific tooling for Nix development
  nix = [
    pkgs.alejandra
    pkgs.statix
    pkgs.deadnix
    pkgs.nixfmt-rfc-style
    pkgs.nix-tree
    pkgs.nix-diff
    pkgs.nixpkgs-review
    pkgs.nurl
  ];

  # Shell script development tools
  shell = [
    pkgs.shellcheck
    pkgs.shfmt
  ];

  # Documentation and configuration linting tools
  linting = [
    pkgs.markdownlint-cli
    pkgs.yamllint
    pkgs.actionlint
  ];

  # Code formatters and additional tools
  formatters = [
    pkgs.keep-sorted
    pkgs.taplo
    pkgs.stylua
    pkgs.treefmt
  ];

  # Security and secrets management
  security = [
    pkgs.sops
    pkgs.age
  ];

  # Flake-specific tools (for flake-based environments)
  flake = [
    pkgs.devenv
  ];

  # Combined package sets for common use cases
  common = concatLists [
    base
    shell
    linting
    formatters
    security
  ];

  # Full development environment (everything except language-specific tools)
  full = concatLists [
    common
    nix
    flake
  ];

  # Traditional devenv.nix compatible set (without flake tools)
  traditional = concatLists [
    common
    nix
  ];
}
