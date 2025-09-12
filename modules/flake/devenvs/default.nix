{inputs, ...}: {
  imports = [
    inputs.devenv.flakeModule
    ./lazy-loader.nix
    ./profiles.nix
    ./direnv.nix
    ./python.nix
    ./rust.nix
    ./zig.nix
    ./julia.nix
  ];

  perSystem = {pkgs, sharedPackages, lazyLoader, direnvIntegration, ...}: {
    # Minimal base development shell with optional extensions
    devenv.shells.default = direnvIntegration.addDirenvSupport (lazyLoader.mkLazyShell {
      name = "nix-blazar-dev";
      basePackages = sharedPackages.base; # Only essential tools by default
      lazyPackages = ["python" "cargo" "zig" "julia"];
      extraHooks = ''
        echo "🚀 Streamlined development shell ready!"
        echo ""
        echo "🎯 Optimized Features:"
        echo "  ⚡ Lazy loading - Tools load only when needed"
        echo "  💾 Caching - Compiled environments cached for speed"
        echo "  📁 Direnv integration - Auto environment switching"
        echo "  🎨 Shell profiles - Different configurations available"
        echo ""
        echo "📋 Available Profiles:"
        echo "  devenv shell minimal        - Essential tools only"
        echo "  devenv shell standard       - Common tools with lazy loading"
        echo "  devenv shell full           - All tools loaded immediately"
        echo "  devenv shell python-focused - Python development optimized"
        echo "  devenv shell rust-focused   - Rust development optimized"
        echo "  devenv shell zig-focused    - Zig development optimized"
        echo "  devenv shell julia-focused  - Julia development optimized"
        echo ""
        echo "🛠️  Management Commands:"
        echo "  devenv-status        - Show environment status"
        echo "  devenv-preload <tool> - Preload specific tools"
        echo "  devenv-clear-cache   - Clear environment cache"
        echo "  direnv-setup         - Setup direnv for project"
        echo ""
        echo "🔧 Legacy Commands (still available):"
        echo "  devenv shell python - Python development (full load)"
        echo "  devenv shell rust   - Rust development (full load)"
        echo "  devenv shell zig    - Zig development (full load)"
        echo "  devenv shell julia  - Julia development (full load)"
        echo ""
        echo "💡 Tip: Use 'devenv shell standard' for the best balance of speed and functionality"
        echo ""
      '';
    });

    # Git hooks for code quality (can be enabled per profile)
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
}
