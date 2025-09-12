{inputs, ...}: {
  perSystem = {pkgs, sharedPackages, ...}: let
    # Python-specific packages
    pythonPackages = [
      # Python package manager and tools
      pkgs.uv

      # Linting and formatting
      pkgs.ruff
      # Note: pyrefly will be installed via uv/pip as it's not in nixpkgs yet
      # pkgs.pyrefly  # TODO: Add when available in nixpkgs
      pkgs.bandit

      # Testing and coverage
      pkgs.python3Packages.pytest
      pkgs.python3Packages.pytest-cov
      pkgs.python3Packages.coverage

      # Development tools
      pkgs.python3Packages.ipython
      pkgs.python3Packages.jupyterlab
      pkgs.python3Packages.black
      pkgs.python3Packages.isort

      # Additional useful packages
      pkgs.python3Packages.pip-tools
      pkgs.python3Packages.virtualenv
      pkgs.python3Packages.pipx
    ];
  in {
    devenv.shells.python = {
      name = "python-dev";

      # Containers disabled for simplicity - can be enabled later if needed
      # containers.enable = false; # Commented out due to type mismatch

      languages.python = {
        enable = true;
        # Note: Using default Python version from nixpkgs
        # To use specific versions, add nixpkgs-python input to flake.nix
        uv = {
          enable = true;
          sync.enable = true;
        };
      };

      packages = inputs.self.lib.devenv.mkPackages {
        base = sharedPackages.common;
        language = pythonPackages;
      };

      env = {
        PYTHONPATH = "$PWD";
        UV_CACHE_DIR = "$PWD/.uv-cache";
        PYREFLY_CACHE_DIR = "$PWD/.pyrefly_cache";
        PYTEST_CACHE_DIR = "$PWD/.pytest_cache";
      };

      scripts = {
        # Python project management
        py-init.exec = ''
          echo "🐍 Initializing Python project..."
          uv init
          uv add --dev pytest pytest-cov pyrefly ruff bandit
          echo "✅ Python project initialized!"
        '';

        py-install.exec = ''
          echo "📦 Installing Python dependencies..."
          uv sync
        '';

        py-test.exec = ''
          echo "🧪 Running Python tests..."
          uv run pytest --cov=. --cov-report=html --cov-report=term
        '';

        py-lint.exec = ''
          echo "🔍 Running Python linting..."
          uv run ruff check .
          uv run pyrefly .
          uv run bandit -r .
        '';

        py-format.exec = ''
          echo "🎨 Formatting Python code..."
          uv run ruff format .
          uv run ruff check --fix .
        '';

        py-clean.exec = ''
          echo "🧹 Cleaning Python artifacts..."
          find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
          find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
          find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
          find . -type d -name ".pyrefly_cache" -exec rm -rf {} + 2>/dev/null || true
          find . -type d -name ".coverage" -exec rm -rf {} + 2>/dev/null || true
          find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
          echo "✅ Python artifacts cleaned!"
        '';
      };

      enterShell = ''
        echo "🐍 Python development environment ready!"
        echo ""
        echo "Python version: $(python --version)"
        echo "UV version: $(uv --version)"
        echo ""
        echo "Available commands:"
        echo "  py-init      - Initialize new Python project"
        echo "  py-install   - Install dependencies with uv"
        echo "  py-test      - Run tests with coverage"
        echo "  py-lint      - Run linting (ruff, pyrefly, bandit)"
        echo "  py-format    - Format code with ruff"
        echo "  py-clean     - Clean Python artifacts"
        echo ""
        echo "Direct tools:"
        echo "  uv           - Python package manager"
        echo "  ruff         - Fast Python linter/formatter"
        echo "  pyrefly      - Static type checker"
        echo "  bandit       - Security linter"
        echo "  pytest       - Testing framework"
        echo ""
      '';
    };
  };
}
