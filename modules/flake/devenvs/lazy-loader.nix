# Lazy loading utilities for development shells
# Provides functions to load packages and tools only when needed
{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    # Cache directory for compiled environments
    cacheDir = "$HOME/.cache/nix-devenv";
    
    # Lazy loading function generator
    mkLazyLoader = {
      name,
      packages ? [],
      setupScript ? "",
      checkCommand ? "command -v ${name}",
    }: ''
      ${name}() {
        # Check if already loaded
        if ${checkCommand} >/dev/null 2>&1; then
          command ${name} "$@"
          return $?
        fi
        
        # Check cache first
        local cache_file="${cacheDir}/${name}.env"
        if [[ -f "$cache_file" && -r "$cache_file" ]]; then
          echo "🔄 Loading ${name} from cache..."
          source "$cache_file"
        else
          echo "📦 Loading ${name} for first use..."
          
          # Create cache directory
          mkdir -p "${cacheDir}"
          
          # Load packages into environment
          ${pkgs.lib.concatMapStringsSep "\n" (pkg: ''
            export PATH="${pkg}/bin:$PATH"
          '') packages}
          
          # Run setup script if provided
          ${setupScript}
          
          # Cache the environment
          {
            echo "# Cached environment for ${name}"
            ${pkgs.lib.concatMapStringsSep "\n" (pkg: ''
              echo 'export PATH="${pkg}/bin:$PATH"'
            '') packages}
            echo "${setupScript}"
          } > "$cache_file"
        fi
        
        # Execute the actual command
        command ${name} "$@"
      }
    '';

    # Pre-defined lazy loaders for common tools
    lazyLoaders = {
      # Python tools
      python = mkLazyLoader {
        name = "python";
        packages = with pkgs; [python3 uv ruff mypy];
        setupScript = ''
          export PYTHONPATH="$PWD"
          export UV_CACHE_DIR="$PWD/.uv-cache"
          export MYPY_CACHE_DIR="$PWD/.mypy_cache"
        '';
      };
      
      uv = mkLazyLoader {
        name = "uv";
        packages = with pkgs; [uv];
        checkCommand = "command -v uv";
      };
      
      ruff = mkLazyLoader {
        name = "ruff";
        packages = with pkgs; [ruff];
        checkCommand = "command -v ruff";
      };
      
      mypy = mkLazyLoader {
        name = "mypy";
        packages = with pkgs; [mypy];
        checkCommand = "command -v mypy";
      };
      
      # Rust tools
      cargo = mkLazyLoader {
        name = "cargo";
        packages = with pkgs; [rustc cargo clippy rustfmt];
        setupScript = ''
          export RUST_BACKTRACE="1"
          export CARGO_HOME="$PWD/.cargo"
          export RUSTUP_HOME="$PWD/.rustup"
        '';
      };
      
      clippy = mkLazyLoader {
        name = "clippy";
        packages = with pkgs; [clippy];
        checkCommand = "command -v cargo-clippy";
      };
      
      # Zig tools
      zig = mkLazyLoader {
        name = "zig";
        packages = with pkgs; [zig zls];
        setupScript = ''
          export ZIG_GLOBAL_CACHE_DIR="$PWD/.zig-cache"
          export ZIG_LOCAL_CACHE_DIR="$PWD/zig-cache"
        '';
      };
      
      # Julia tools
      julia = mkLazyLoader {
        name = "julia";
        packages = with pkgs; [julia-bin];
        setupScript = ''
          export JULIA_DEPOT_PATH="$PWD/.julia"
          export JULIA_PROJECT="$PWD"
          export JULIA_NUM_THREADS="auto"
        '';
      };
    };

    # Shell hook system
    shellHooks = {
      # Pre-initialization hook
      preInit = ''
        # Create cache directory
        mkdir -p "${cacheDir}"
        
        # Clean old cache entries (older than 7 days)
        find "${cacheDir}" -name "*.env" -mtime +7 -delete 2>/dev/null || true
        
        echo "🚀 Lazy loading system initialized"
      '';
      
      # Post-initialization hook
      postInit = ''
        # Set up lazy loading aliases
        ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: loader: loader) lazyLoaders)}
        
        # Add helpful functions
        devenv-status() {
          echo "📊 Development Environment Status:"
          echo "Cache directory: ${cacheDir}"
          echo "Cached tools: $(ls -1 ${cacheDir}/*.env 2>/dev/null | wc -l)"
          echo ""
          echo "Available lazy loaders:"
          ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: _: ''
            echo "  ${name} - $(command -v ${name} >/dev/null && echo "loaded" || echo "not loaded")"
          '') lazyLoaders)}
        }
        
        devenv-clear-cache() {
          echo "🧹 Clearing development environment cache..."
          rm -rf "${cacheDir}"
          mkdir -p "${cacheDir}"
          echo "✅ Cache cleared!"
        }
        
        devenv-preload() {
          local tool="$1"
          if [[ -z "$tool" ]]; then
            echo "Usage: devenv-preload <tool>"
            echo "Available tools: ${pkgs.lib.concatStringsSep " " (pkgs.lib.attrNames lazyLoaders)}"
            return 1
          fi
          
          echo "⚡ Preloading $tool..."
          $tool --version >/dev/null 2>&1 || true
          echo "✅ $tool preloaded!"
        }
      '';
    };
  in {
    # Export lazy loading utilities for use in other shells
    _module.args.lazyLoader = {
      inherit mkLazyLoader lazyLoaders shellHooks;
      
      # Convenience function to create a lazy shell
      mkLazyShell = {
        name,
        basePackages ? [],
        lazyPackages ? [],
        extraHooks ? "",
      }: {
        inherit name;
        
        packages = basePackages;
        
        enterShell = ''
          ${shellHooks.preInit}
          ${extraHooks}
          ${shellHooks.postInit}
        '';
      };
    };
  };
}
