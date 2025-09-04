_: {
  perSystem = { pkgs, ... }: {
    devenv.shells.python = {
      name = "python-dev";
      
      languages.python = {
        enable = true;
        version = "3.12";
        uv = {
          enable = true;
          sync.enable = true;
        };
      };
      
      packages = with pkgs; [
        # Python package manager and tools
        uv
        
        # Linting and formatting
        ruff
        mypy
        bandit
        
        # Testing and coverage
        python3Packages.pytest
        python3Packages.pytest-cov
        python3Packages.coverage
        
        # Development tools
        python3Packages.ipython
        python3Packages.jupyterlab
        python3Packages.black
        python3Packages.isort
        
        # Additional useful packages
        python3Packages.pip-tools
        python3Packages.virtualenv
        python3Packages.pipx
      ];
      
      env = {
        PYTHONPATH = "$PWD";
        UV_CACHE_DIR = "$PWD/.uv-cache";
        MYPY_CACHE_DIR = "$PWD/.mypy_cache";
        PYTEST_CACHE_DIR = "$PWD/.pytest_cache";
      };
      
      scripts = {
        # Python project management
        py-init.exec = ''
          echo "🐍 Initializing Python project..."
          uv init
          uv add --dev pytest pytest-cov mypy ruff bandit
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
          uv run mypy .
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
          find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
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
        echo "  py-lint      - Run linting (ruff, mypy, bandit)"
        echo "  py-format    - Format code with ruff"
        echo "  py-clean     - Clean Python artifacts"
        echo ""
        echo "Direct tools:"
        echo "  uv           - Python package manager"
        echo "  ruff         - Fast Python linter/formatter"
        echo "  mypy         - Static type checker"
        echo "  bandit       - Security linter"
        echo "  pytest       - Testing framework"
        echo ""
      '';
    };
  };
}
