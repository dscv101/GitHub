# Direnv integration for automatic environment switching
# Provides seamless integration with direnv for project-based environments
{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    # Direnv configuration templates
    direnvTemplates = {
      # Basic .envrc template
      basic = ''
        # Basic direnv configuration
        use flake
        
        # Optional: Set specific shell profile
        # export DEVENV_PROFILE=python-focused
        
        # Optional: Enable lazy loading
        # export DEVENV_LAZY_LOADING=true
        
        # Optional: Set cache directory
        # export DEVENV_CACHE_DIR="$PWD/.devenv-cache"
      '';
      
      # Python project .envrc
      python = ''
        # Python project direnv configuration
        use flake .#python-focused
        
        # Python-specific environment variables
        export PYTHONPATH="$PWD"
        export UV_CACHE_DIR="$PWD/.uv-cache"
        export PYREFLY_CACHE_DIR="$PWD/.pyrefly_cache"
        export PYTEST_CACHE_DIR="$PWD/.pytest_cache"
        
        # Enable lazy loading for other languages
        export DEVENV_LAZY_LOADING=true
        
        # Auto-activate virtual environment if it exists
        if [[ -d .venv ]]; then
          source .venv/bin/activate
        fi
      '';
      
      # Rust project .envrc
      rust = ''
        # Rust project direnv configuration
        use flake .#rust-focused
        
        # Rust-specific environment variables
        export RUST_BACKTRACE=1
        export CARGO_HOME="$PWD/.cargo"
        export RUSTUP_HOME="$PWD/.rustup"
        export SCCACHE_DIR="$PWD/.sccache"
        
        # Enable lazy loading for other languages
        export DEVENV_LAZY_LOADING=true
      '';
      
      # Zig project .envrc
      zig = ''
        # Zig project direnv configuration
        use flake .#zig-focused
        
        # Zig-specific environment variables
        export ZIG_GLOBAL_CACHE_DIR="$PWD/.zig-cache"
        export ZIG_LOCAL_CACHE_DIR="$PWD/zig-cache"
        
        # Enable lazy loading for other languages
        export DEVENV_LAZY_LOADING=true
      '';
      
      # Julia project .envrc
      julia = ''
        # Julia project direnv configuration
        use flake .#julia-focused
        
        # Julia-specific environment variables
        export JULIA_DEPOT_PATH="$PWD/.julia"
        export JULIA_PROJECT="$PWD"
        export JULIA_NUM_THREADS="auto"
        
        # Enable lazy loading for other languages
        export DEVENV_LAZY_LOADING=true
      '';
      
      # Multi-language project .envrc
      polyglot = ''
        # Multi-language project direnv configuration
        use flake .#standard
        
        # Enable lazy loading for all languages
        export DEVENV_LAZY_LOADING=true
        
        # Project-specific cache directory
        export DEVENV_CACHE_DIR="$PWD/.devenv-cache"
        
        # Language-specific environment variables
        export PYTHONPATH="$PWD"
        export RUST_BACKTRACE=1
        export JULIA_PROJECT="$PWD"
        
        # Auto-detect and set primary language based on files
        if [[ -f pyproject.toml || -f requirements.txt || -f setup.py ]]; then
          export DEVENV_PRIMARY_LANG=python
        elif [[ -f Cargo.toml ]]; then
          export DEVENV_PRIMARY_LANG=rust
        elif [[ -f build.zig ]]; then
          export DEVENV_PRIMARY_LANG=zig
        elif [[ -f Project.toml ]]; then
          export DEVENV_PRIMARY_LANG=julia
        fi
      '';
    };
    
    # Direnv helper functions
    direnvHelpers = {
      # Generate .envrc for a project
      generateEnvrc = template: ''
        if [[ -f .envrc ]]; then
          echo "⚠️  .envrc already exists. Backup created as .envrc.bak"
          cp .envrc .envrc.bak
        fi
        
        cat > .envrc << 'EOF'
        ${direnvTemplates.${template}}
        EOF
        
        echo "✅ Generated .envrc for ${template} project"
        echo "Run 'direnv allow' to activate the environment"
      '';
      
      # Auto-detect project type and generate appropriate .envrc
      autoGenerateEnvrc = ''
        local template="basic"
        
        # Detect project type
        if [[ -f pyproject.toml || -f requirements.txt || -f setup.py ]]; then
          template="python"
          echo "🐍 Detected Python project"
        elif [[ -f Cargo.toml ]]; then
          template="rust"
          echo "🦀 Detected Rust project"
        elif [[ -f build.zig ]]; then
          template="zig"
          echo "⚡ Detected Zig project"
        elif [[ -f Project.toml ]]; then
          template="julia"
          echo "🔬 Detected Julia project"
        elif [[ -f flake.nix ]]; then
          template="polyglot"
          echo "🌐 Detected multi-language Nix project"
        else
          echo "📁 Using basic template"
        fi
        
        ${direnvHelpers.generateEnvrc template}
      '';
      
      # Setup direnv for the current project
      setupDirenv = ''
        echo "🔧 Setting up direnv for this project..."
        
        # Check if direnv is installed
        if ! command -v direnv >/dev/null 2>&1; then
          echo "❌ direnv is not installed. Please install it first:"
          echo "  nix profile install nixpkgs#direnv"
          echo "  # or add it to your system configuration"
          return 1
        fi
        
        # Check if direnv is hooked into shell
        if [[ -z "$DIRENV_DIR" ]]; then
          echo "⚠️  direnv is not hooked into your shell."
          echo "Add this to your shell configuration:"
          echo "  eval \"\$(direnv hook bash)\"  # for bash"
          echo "  eval \"\$(direnv hook zsh)\"   # for zsh"
          echo "  direnv hook fish | source     # for fish"
        fi
        
        # Auto-generate .envrc
        ${direnvHelpers.autoGenerateEnvrc}
        
        # Allow the .envrc
        if [[ -f .envrc ]]; then
          direnv allow
          echo "✅ direnv setup complete!"
        fi
      '';
    };
    
    # Direnv integration scripts
    direnvScripts = {
      # Script to setup direnv for a project
      "direnv-setup" = {
        exec = direnvHelpers.setupDirenv;
        description = "Setup direnv for the current project";
      };
      
      # Script to generate .envrc templates
      "direnv-generate" = {
        exec = ''
          local template="$1"
          if [[ -z "$template" ]]; then
            echo "Usage: direnv-generate <template>"
            echo "Available templates:"
            ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: _: ''
              echo "  ${name}"
            '') direnvTemplates)}
            return 1
          fi
          
          case "$template" in
            ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: _: ''
              ${name})
                ${direnvHelpers.generateEnvrc name}
                ;;
            '') direnvTemplates)}
            *)
              echo "❌ Unknown template: $template"
              echo "Available templates: ${pkgs.lib.concatStringsSep ", " (pkgs.lib.attrNames direnvTemplates)}"
              return 1
              ;;
          esac
        '';
        description = "Generate .envrc from template";
      };
      
      # Script to show direnv status
      "direnv-status" = {
        exec = ''
          echo "📊 Direnv Status:"
          echo ""
          
          if command -v direnv >/dev/null 2>&1; then
            echo "✅ direnv installed: $(direnv version)"
          else
            echo "❌ direnv not installed"
          fi
          
          if [[ -n "$DIRENV_DIR" ]]; then
            echo "✅ direnv hooked into shell"
            echo "   Current directory: $DIRENV_DIR"
          else
            echo "❌ direnv not hooked into shell"
          fi
          
          if [[ -f .envrc ]]; then
            echo "✅ .envrc exists in current directory"
            if direnv status | grep -q "Found RC allowed"; then
              echo "✅ .envrc is allowed"
            else
              echo "⚠️  .envrc needs to be allowed (run 'direnv allow')"
            fi
          else
            echo "❌ No .envrc in current directory"
          fi
          
          echo ""
          echo "Environment variables:"
          env | grep -E "^(DEVENV_|DIRENV_)" | sort || echo "  None found"
        '';
        description = "Show direnv status and configuration";
      };
    };
  in {
    # Export direnv utilities
    _module.args.direnvIntegration = {
      inherit direnvTemplates direnvHelpers direnvScripts;
      
      # Add direnv scripts to shells that support it
      addDirenvSupport = shellConfig: shellConfig // {
        scripts = (shellConfig.scripts or {}) // direnvScripts;
        
        enterShell = (shellConfig.enterShell or "") + ''
          
          # Direnv integration info
          if [[ -f .envrc ]] && command -v direnv >/dev/null 2>&1; then
            echo "📁 direnv detected - environment auto-configured"
          fi
          
          echo "Direnv commands:"
          echo "  direnv-setup     - Setup direnv for this project"
          echo "  direnv-generate  - Generate .envrc template"
          echo "  direnv-status    - Show direnv status"
          echo ""
        '';
      };
    };
  };
}
