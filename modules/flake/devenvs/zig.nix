{inputs, ...}: {
  perSystem = {pkgs, sharedPackages, ...}: let
    # Zig-specific packages
    zigPackages = [
      # Zig toolchain
      pkgs.zig
      pkgs.zls # Zig Language Server

      # Development tools
      pkgs.gdb
      pkgs.lldb
      pkgs.valgrind

      # Build tools
      pkgs.cmake
      pkgs.ninja

      # System dependencies
      pkgs.pkg-config

      # Documentation
      pkgs.doxygen
    ];
  in {
    devenv.shells.zig = {
      name = "zig-dev";

      # Containers disabled for simplicity - can be enabled later if needed
      # containers.enable = false; # Commented out due to type mismatch

      languages.zig = {
        enable = true;
      };

      packages = inputs.self.lib.devenv.mkPackages {
        base = sharedPackages.common;
        language = zigPackages;
      };

      env = {
        ZIG_GLOBAL_CACHE_DIR = "$PWD/.zig-cache";
        ZIG_LOCAL_CACHE_DIR = "$PWD/zig-cache";
      };

      scripts = {
        # Zig project management
        zig-init.exec = ''
          echo "⚡ Initializing Zig project..."
          zig init-exe
          echo "✅ Zig executable project initialized!"
        '';

        zig-init-lib.exec = ''
          echo "⚡ Initializing Zig library..."
          zig init-lib
          echo "✅ Zig library project initialized!"
        '';

        zig-build.exec = ''
          echo "🔨 Building Zig project..."
          zig build
        '';

        zig-run.exec = ''
          echo "🚀 Running Zig project..."
          zig build run
        '';

        zig-test.exec = ''
          echo "🧪 Running Zig tests..."
          zig build test
        '';

        zig-check.exec = ''
          echo "🔍 Checking Zig code..."
          zig fmt --check .
          zig build test
        '';

        zig-format.exec = ''
          echo "🎨 Formatting Zig code..."
          zig fmt .
        '';

        zig-clean.exec = ''
          echo "🧹 Cleaning Zig artifacts..."
          rm -rf zig-cache zig-out .zig-cache
          echo "✅ Zig artifacts cleaned!"
        '';

        zig-debug.exec = ''
          echo "🐛 Building debug version..."
          zig build -Doptimize=Debug
        '';

        zig-release.exec = ''
          echo "🚀 Building release version..."
          zig build -Doptimize=ReleaseFast
        '';
      };

      enterShell = ''
        echo "⚡ Zig development environment ready!"
        echo ""
        echo "Zig version: $(zig version)"
        echo "ZLS available: $(which zls >/dev/null && echo "Yes" || echo "No")"
        echo ""
        echo "Available commands:"
        echo "  zig-init       - Initialize new Zig executable project"
        echo "  zig-init-lib   - Initialize new Zig library project"
        echo "  zig-build      - Build the project"
        echo "  zig-run        - Build and run the project"
        echo "  zig-test       - Run tests"
        echo "  zig-check      - Check formatting and run tests"
        echo "  zig-format     - Format code"
        echo "  zig-clean      - Clean build artifacts"
        echo "  zig-debug      - Build debug version"
        echo "  zig-release    - Build optimized release"
        echo ""
        echo "Direct tools:"
        echo "  zig            - Zig compiler"
        echo "  zls            - Zig Language Server"
        echo "  gdb/lldb       - Debuggers"
        echo ""
      '';
    };
  };
}
