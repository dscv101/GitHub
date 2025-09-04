_: {
  perSystem = { pkgs, ... }: {
    devenv.shells.julia = {
      name = "julia-dev";
      
      packages = with pkgs; [
        # Julia
        julia-bin
        
        # Development tools
        git
        
        # System dependencies commonly needed for Julia packages
        gcc
        gfortran
        pkg-config
        cmake
        
        # Linear algebra libraries
        openblas
        lapack
        
        # Graphics and plotting dependencies
        cairo
        pango
        glib
        
        # Additional useful tools
        jupyter
        
        # Documentation
        pandoc
      ];
      
      env = {
        JULIA_DEPOT_PATH = "$PWD/.julia";
        JULIA_PROJECT = "$PWD";
        JULIA_NUM_THREADS = "auto";
        # Ensure Julia can find system libraries
        LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [ pkgs.openblas pkgs.lapack ]}";
      };
      
      scripts = {
        # Julia project management
        julia-init.exec = ''
          echo "🔬 Initializing Julia project..."
          julia -e "using Pkg; Pkg.generate(\".\")"
          echo "✅ Julia project initialized!"
        '';
        
        julia-activate.exec = ''
          echo "📦 Activating Julia environment..."
          julia -e "using Pkg; Pkg.activate(\".\")"
        '';
        
        julia-install.exec = ''
          echo "📦 Installing Julia dependencies..."
          julia -e "using Pkg; Pkg.instantiate()"
        '';
        
        julia-test.exec = ''
          echo "🧪 Running Julia tests..."
          julia -e "using Pkg; Pkg.test()"
        '';
        
        julia-repl.exec = ''
          echo "🚀 Starting Julia REPL..."
          julia
        '';
        
        julia-notebook.exec = ''
          echo "📓 Starting Jupyter notebook with Julia kernel..."
          jupyter notebook
        '';
        
        julia-add.exec = ''
          if [ $# -eq 0 ]; then
            echo "Usage: julia-add <package_name>"
            exit 1
          fi
          echo "📦 Adding Julia package: $1"
          julia -e "using Pkg; Pkg.add(\"$1\")"
        '';
        
        julia-remove.exec = ''
          if [ $# -eq 0 ]; then
            echo "Usage: julia-remove <package_name>"
            exit 1
          fi
          echo "🗑️ Removing Julia package: $1"
          julia -e "using Pkg; Pkg.rm(\"$1\")"
        '';
        
        julia-status.exec = ''
          echo "📋 Julia package status..."
          julia -e "using Pkg; Pkg.status()"
        '';
        
        julia-clean.exec = ''
          echo "🧹 Cleaning Julia artifacts..."
          rm -rf .julia Manifest.toml
          echo "✅ Julia artifacts cleaned!"
        '';
        
        julia-precompile.exec = ''
          echo "⚡ Precompiling Julia packages..."
          julia -e "using Pkg; Pkg.precompile()"
        '';
      };
      
      enterShell = ''
        echo "🔬 Julia development environment ready!"
        echo ""
        echo "Julia version: $(julia --version)"
        echo "Julia depot: $JULIA_DEPOT_PATH"
        echo ""
        echo "Available commands:"
        echo "  julia-init       - Initialize new Julia project"
        echo "  julia-activate   - Activate Julia environment"
        echo "  julia-install    - Install dependencies"
        echo "  julia-test       - Run tests"
        echo "  julia-repl       - Start Julia REPL"
        echo "  julia-notebook   - Start Jupyter notebook"
        echo "  julia-add <pkg>  - Add package"
        echo "  julia-remove <pkg> - Remove package"
        echo "  julia-status     - Show package status"
        echo "  julia-clean      - Clean artifacts"
        echo "  julia-precompile - Precompile packages"
        echo ""
        echo "Direct tools:"
        echo "  julia          - Julia interpreter"
        echo "  jupyter        - Jupyter notebook"
        echo ""
        echo "Tip: Use 'julia-activate' before working with packages"
        echo ""
      '';
    };
  };
}
