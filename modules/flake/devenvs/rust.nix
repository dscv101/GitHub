_: {
  perSystem = {pkgs, ...}: {
    devenv.shells.rust = {
      name = "rust-dev";

      # Disable containers to avoid the current directory issue
      containers = {};

      languages.rust = {
        enable = true;
        channel = "stable";
        components = ["rustc" "cargo" "clippy" "rustfmt" "rust-analyzer"];
      };

      packages = with pkgs; [
        # Rust toolchain (additional tools)
        cargo-watch
        cargo-edit
        cargo-audit
        cargo-outdated
        cargo-tree
        cargo-expand
        cargo-bloat
        cargo-deny
        cargo-nextest

        # Development tools
        bacon # Background rust code checker
        sccache # Compilation cache

        # System dependencies commonly needed
        pkg-config
        openssl

        # Documentation
        mdbook
      ];

      env = {
        RUST_BACKTRACE = "1";
        CARGO_HOME = "$PWD/.cargo";
        RUSTUP_HOME = "$PWD/.rustup";
        SCCACHE_DIR = "$PWD/.sccache";
      };

      scripts = {
        # Rust project management
        rust-init.exec = ''
          echo "🦀 Initializing Rust project..."
          cargo init
          echo "✅ Rust project initialized!"
        '';

        rust-build.exec = ''
          echo "🔨 Building Rust project..."
          cargo build
        '';

        rust-test.exec = ''
          echo "🧪 Running Rust tests..."
          cargo nextest run || cargo test
        '';

        rust-check.exec = ''
          echo "🔍 Running Rust checks..."
          cargo check
          cargo clippy -- -D warnings
          cargo fmt --check
        '';

        rust-format.exec = ''
          echo "🎨 Formatting Rust code..."
          cargo fmt
        '';

        rust-audit.exec = ''
          echo "🔒 Running security audit..."
          cargo audit
        '';

        rust-outdated.exec = ''
          echo "📦 Checking for outdated dependencies..."
          cargo outdated
        '';

        rust-clean.exec = ''
          echo "🧹 Cleaning Rust artifacts..."
          cargo clean
          echo "✅ Rust artifacts cleaned!"
        '';

        rust-watch.exec = ''
          echo "👀 Starting Rust file watcher..."
          cargo watch -x check -x test
        '';
      };

      enterShell = ''
        echo "🦀 Rust development environment ready!"
        echo ""
        echo "Rust version: $(rustc --version)"
        echo "Cargo version: $(cargo --version)"
        echo ""
        echo "Available commands:"
        echo "  rust-init      - Initialize new Rust project"
        echo "  rust-build     - Build the project"
        echo "  rust-test      - Run tests (with nextest if available)"
        echo "  rust-check     - Run checks (check, clippy, fmt)"
        echo "  rust-format    - Format code with rustfmt"
        echo "  rust-audit     - Security audit"
        echo "  rust-outdated  - Check outdated dependencies"
        echo "  rust-clean     - Clean build artifacts"
        echo "  rust-watch     - Watch files and run checks"
        echo ""
        echo "Direct tools:"
        echo "  cargo          - Rust package manager"
        echo "  rustc          - Rust compiler"
        echo "  clippy         - Rust linter"
        echo "  rustfmt        - Rust formatter"
        echo "  bacon          - Background code checker"
        echo ""
      '';
    };
  };
}
