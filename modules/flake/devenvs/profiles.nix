# Shell profiles for different development scenarios
# Provides predefined configurations for various use cases
{inputs, ...}: {
  perSystem = {pkgs, sharedPackages, lazyLoader, ...}: let
    inherit (lazyLoader) mkLazyShell;
    
    # Profile definitions
    profiles = {
      # Minimal profile - only essential tools
      minimal = {
        name = "minimal-dev";
        description = "Minimal development environment with only essential tools";
        packages = sharedPackages.base;
        lazyPackages = [];
        features = {
          lazyLoading = false;
          caching = false;
          hooks = false;
        };
        enterShell = ''
          echo "⚡ Minimal development environment ready!"
          echo "Profile: minimal"
          echo "Essential tools: git, direnv, just, curl, jq"
          echo ""
          echo "To switch profiles: devenv shell <profile-name>"
          echo "Available profiles: minimal, standard, full, python, rust, zig, julia"
          echo ""
        '';
      };
      
      # Standard profile - common tools with lazy loading
      standard = {
        name = "standard-dev";
        description = "Standard development environment with lazy loading";
        packages = sharedPackages.common;
        lazyPackages = ["python" "cargo" "zig" "julia"];
        features = {
          lazyLoading = true;
          caching = true;
          hooks = true;
        };
        enterShell = ''
          echo "🚀 Standard development environment ready!"
          echo "Profile: standard"
          echo "Lazy loading enabled for: ${pkgs.lib.concatStringsSep ", " profiles.standard.lazyPackages}"
          echo ""
          echo "Commands:"
          echo "  devenv-status     - Show environment status"
          echo "  devenv-preload    - Preload specific tools"
          echo "  devenv-clear-cache - Clear cache"
          echo ""
        '';
      };
      
      # Full profile - everything available
      full = {
        name = "full-dev";
        description = "Full development environment with all tools";
        packages = sharedPackages.full;
        lazyPackages = [];
        features = {
          lazyLoading = false;
          caching = true;
          hooks = true;
        };
        enterShell = ''
          echo "🔥 Full development environment ready!"
          echo "Profile: full"
          echo "All tools loaded immediately"
          echo ""
          echo "Available tools:"
          echo "  Nix: alejandra, statix, deadnix, nixfmt"
          echo "  Shell: shellcheck, shfmt"
          echo "  Linting: markdownlint, yamllint, actionlint"
          echo "  Formatters: keep-sorted, taplo, stylua, treefmt"
          echo "  Security: sops, age"
          echo ""
        '';
      };
      
      # Language-specific profiles
      python-focused = {
        name = "python-focused";
        description = "Python-focused development with minimal overhead";
        packages = sharedPackages.base ++ (with pkgs; [
          python3 uv ruff mypy bandit
          python3Packages.pytest python3Packages.pytest-cov
          python3Packages.ipython python3Packages.black python3Packages.isort
        ]);
        lazyPackages = ["cargo" "zig" "julia"];
        features = {
          lazyLoading = true;
          caching = true;
          hooks = true;
        };
        enterShell = ''
          echo "🐍 Python-focused development environment ready!"
          echo "Profile: python-focused"
          echo "Python tools loaded, other languages lazy-loaded"
          echo ""
          echo "Python version: $(python --version)"
          echo "UV version: $(uv --version)"
          echo ""
        '';
      };
      
      rust-focused = {
        name = "rust-focused";
        description = "Rust-focused development with minimal overhead";
        packages = sharedPackages.base ++ (with pkgs; [
          rustc cargo clippy rustfmt rust-analyzer
          cargo-watch cargo-edit cargo-audit cargo-nextest
        ]);
        lazyPackages = ["python" "zig" "julia"];
        features = {
          lazyLoading = true;
          caching = true;
          hooks = true;
        };
        enterShell = ''
          echo "🦀 Rust-focused development environment ready!"
          echo "Profile: rust-focused"
          echo "Rust tools loaded, other languages lazy-loaded"
          echo ""
          echo "Rust version: $(rustc --version)"
          echo "Cargo version: $(cargo --version)"
          echo ""
        '';
      };
      
      zig-focused = {
        name = "zig-focused";
        description = "Zig-focused development with minimal overhead";
        packages = sharedPackages.base ++ (with pkgs; [
          zig zls gdb lldb valgrind cmake ninja
        ]);
        lazyPackages = ["python" "cargo" "julia"];
        features = {
          lazyLoading = true;
          caching = true;
          hooks = true;
        };
        enterShell = ''
          echo "⚡ Zig-focused development environment ready!"
          echo "Profile: zig-focused"
          echo "Zig tools loaded, other languages lazy-loaded"
          echo ""
          echo "Zig version: $(zig version)"
          echo ""
        '';
      };
      
      julia-focused = {
        name = "julia-focused";
        description = "Julia-focused development with minimal overhead";
        packages = sharedPackages.base ++ (with pkgs; [
          julia-bin gcc gfortran openblas lapack
          cairo pango glib jupyter pandoc
        ]);
        lazyPackages = ["python" "cargo" "zig"];
        features = {
          lazyLoading = true;
          caching = true;
          hooks = true;
        };
        enterShell = ''
          echo "🔬 Julia-focused development environment ready!"
          echo "Profile: julia-focused"
          echo "Julia tools loaded, other languages lazy-loaded"
          echo ""
          echo "Julia version: $(julia --version)"
          echo ""
        '';
      };
    };
    
    # Helper function to create a profile shell
    mkProfileShell = profileName: profile: let
      baseShell = if profile.features.lazyLoading then
        mkLazyShell {
          name = profile.name;
          basePackages = profile.packages;
          lazyPackages = profile.lazyPackages;
          extraHooks = profile.enterShell;
        }
      else {
        name = profile.name;
        packages = profile.packages;
        enterShell = profile.enterShell;
      };
    in baseShell // {
      # Add profile metadata
      meta = {
        inherit (profile) description features;
        profileName = profileName;
      };
    };
  in {
    # Export profiles for use in devenv shells
    devenv.shells = pkgs.lib.mapAttrs mkProfileShell profiles;
    
    # Export profile utilities
    _module.args.profiles = {
      inherit profiles;
      
      # List available profiles
      listProfiles = ''
        echo "📋 Available Development Profiles:"
        echo ""
        ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: profile: ''
          echo "  ${name} - ${profile.description}"
        '') profiles)}
        echo ""
        echo "Usage: devenv shell <profile-name>"
      '';
      
      # Profile switching helper
      switchProfile = profileName: ''
        if [[ -z "${profileName}" ]]; then
          ${profiles.listProfiles}
          return 1
        fi
        
        echo "🔄 Switching to profile: ${profileName}"
        devenv shell ${profileName}
      '';
      
      # Profile information
      profileInfo = profileName: let
        profile = profiles.${profileName} or null;
      in if profile != null then ''
        echo "📊 Profile Information: ${profileName}"
        echo "Description: ${profile.description}"
        echo "Features:"
        echo "  Lazy loading: ${if profile.features.lazyLoading then "enabled" else "disabled"}"
        echo "  Caching: ${if profile.features.caching then "enabled" else "disabled"}"
        echo "  Hooks: ${if profile.features.hooks then "enabled" else "disabled"}"
        echo "Package count: ${toString (builtins.length profile.packages)}"
        echo "Lazy packages: ${pkgs.lib.concatStringsSep ", " profile.lazyPackages}"
      '' else ''
        echo "❌ Profile '${profileName}' not found"
        ${profiles.listProfiles}
      '';
    };
  };
}
