# Claude Code Custom Commands for devenv
#
# This template shows how to define custom slash commands that Claude can
# discover and use. Commands appear as /test, /build, /deploy, etc. in Claude.
#
# Usage: Add this to your devenv.nix file for custom Claude commands.

{
  pkgs,
  lib,
  config,
  ...
}: {
  # Claude Code integration with custom commands
  # Commands are defined as devenv scripts that Claude can discover and use
  
  # Define custom commands that Claude can use via devenv scripts
  scripts = {
    # Test command - runs project tests
    test = {
      description = "Run the project test suite";
      exec = ''
        echo "🧪 Running tests..."
        
        # Detect project type and run appropriate tests
        if [ -f "package.json" ]; then
          if [ -f "yarn.lock" ]; then
            yarn test
          else
            npm test
          fi
        elif [ -f "Cargo.toml" ]; then
          cargo test
        elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
          if command -v pytest &> /dev/null; then
            pytest
          else
            python -m unittest discover
          fi
        elif [ -f "flake.nix" ]; then
          nix flake check
        else
          echo "❌ No recognized test configuration found"
          exit 1
        fi
        
        echo "✅ Tests completed"
      '';
    };
    
    # Build command - builds the project
    build = {
      description = "Build the project in release/production mode";
      exec = ''
        echo "🔨 Building project..."
        
        # Detect project type and run appropriate build
        if [ -f "package.json" ]; then
          if [ -f "yarn.lock" ]; then
            yarn build
          else
            npm run build
          fi
        elif [ -f "Cargo.toml" ]; then
          cargo build --release
        elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
          python -m build
        elif [ -f "flake.nix" ]; then
          nix build
        else
          echo "❌ No recognized build configuration found"
          exit 1
        fi
        
        echo "✅ Build completed"
      '';
    };
    
    # Deploy command - deploys the project
    deploy = {
      description = "Deploy the project to the configured environment";
      exec = ''
        echo "🚀 Deploying project..."
        
        # Check for deployment methods in order of preference
        if [ -f "Dockerfile" ]; then
          echo "📦 Docker deployment detected"
          docker build -t $(basename $(pwd)) .
          echo "💡 Built Docker image: $(basename $(pwd))"
          echo "   Run: docker push $(basename $(pwd)) to deploy"
        elif [ -f "flake.nix" ] && grep -q "nixosConfigurations\|deploy" flake.nix; then
          echo "❄️  NixOS deployment detected"
          nixos-rebuild switch --flake .
        elif [ -f "package.json" ] && grep -q '"deploy"' package.json; then
          if [ -f "yarn.lock" ]; then
            yarn deploy
          else
            npm run deploy
          fi
        elif [ -f "deploy.sh" ]; then
          echo "📜 Custom deployment script detected"
          ./deploy.sh
        else
          echo "❌ No deployment method found"
          echo "💡 Consider adding a Dockerfile, deploy script, or package.json deploy command"
          exit 1
        fi
        
        echo "✅ Deployment completed"
      '';
    };
    
    # Database migration command
    db-migrate = {
      description = "Run database migrations";
      exec = ''
        echo "🗄️  Running database migrations..."
        
        # Detect migration method
        if [ -f "manage.py" ]; then
          echo "🐍 Django migrations detected"
          python manage.py migrate
        elif [ -f "Gemfile" ] && grep -q "rails" Gemfile; then
          echo "💎 Rails migrations detected"
          rails db:migrate
        elif [ -f "package.json" ] && grep -q '"migrate"' package.json; then
          if [ -f "yarn.lock" ]; then
            yarn migrate
          else
            npm run migrate
          fi
        elif [ -f "migrate.sh" ]; then
          echo "📜 Custom migration script detected"
          ./migrate.sh
        else
          echo "❌ No migration method found"
          echo "💡 Consider adding a migrate script to package.json or creating migrate.sh"
          exit 1
        fi
        
        echo "✅ Migrations completed"
        '';
    };
    
    # Format command - format all code
    format = {
      description = "Format all code using configured formatters";
      exec = ''
        echo "🎨 Formatting code..."
        
        # Run formatters based on file presence
        if find . -name "*.nix" -type f | head -1 | grep -q .; then
          echo "❄️  Formatting Nix files..."
          find . -name "*.nix" -exec nixfmt {} \;
        fi
        
        if find . -name "*.py" -type f | head -1 | grep -q .; then
          echo "🐍 Formatting Python files..."
          black .
        fi
        
        if find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -type f | head -1 | grep -q .; then
          echo "📜 Formatting JavaScript/TypeScript files..."
          prettier --write "**/*.{js,ts,jsx,tsx,json,yaml,yml,md}"
        fi
        
        if find . -name "*.rs" -type f | head -1 | grep -q .; then
          echo "🦀 Formatting Rust files..."
          cargo fmt
        fi
        
        if find . -name "*.sh" -type f | head -1 | grep -q .; then
          echo "🐚 Formatting shell scripts..."
          shfmt -w .
        fi
        
        echo "✅ Code formatting completed"
      '';
    };
    
    # Lint command - run all linters
    lint = {
      description = "Run all configured linters and static analysis tools";
      exec = ''
        echo "🔍 Running linters..."
        
        # Run linters based on file presence
        if find . -name "*.py" -type f | head -1 | grep -q .; then
          echo "🐍 Linting Python files..."
          if command -v mypy &> /dev/null; then
            mypy . || true
          fi
          if command -v flake8 &> /dev/null; then
            flake8 . || true
          fi
        fi
        
        if find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -type f | head -1 | grep -q .; then
          echo "📜 Linting JavaScript/TypeScript files..."
          if command -v eslint &> /dev/null; then
            eslint . || true
          fi
        fi
        
        if find . -name "*.rs" -type f | head -1 | grep -q .; then
          echo "🦀 Linting Rust files..."
          cargo clippy || true
        fi
        
        if find . -name "*.sh" -type f | head -1 | grep -q .; then
          echo "🐚 Linting shell scripts..."
          shellcheck **/*.sh || true
        fi
        
        if find . -name "*.nix" -type f | head -1 | grep -q .; then
          echo "❄️  Linting Nix files..."
          if command -v statix &> /dev/null; then
            statix check . || true
          fi
          if command -v deadnix &> /dev/null; then
            deadnix . || true
          fi
        fi
        
        echo "✅ Linting completed"
      '';
      };
    };
  };

  # Include packages needed for the commands
  packages = with pkgs; [
    # Version control
    git
    
    # Build tools
    gnumake
    
    # Formatters
    nixfmt-classic
    black
    prettier
    rustfmt
    shfmt
    
    # Linters
    shellcheck
    
    # Development tools
    curl
    wget
    jq
    yq
    
    # Shell utilities
    bash
    coreutils
    findutils
  ];

  # Environment variables for command execution
  env = {
    CLAUDE_CODE_ENABLED = "true";
    CLAUDE_CODE_COMMANDS_ENABLED = "true";
    CLAUDE_PROJECT_ROOT = builtins.toString ./.;
  };

  # Enhanced welcome message showing available commands
  enterShell = ''
    echo "🤖 Claude Code integration is enabled with custom commands!"
    echo "   Available commands:"
    echo "   • /test     - Run project tests"
    echo "   • /build    - Build the project"
    echo "   • /deploy   - Deploy the project"
    echo "   • /db-migrate - Run database migrations"
    echo "   • /format   - Format all code"
    echo "   • /lint     - Run all linters"
    echo ""
    echo "   Use these commands in Claude to perform common development tasks."
    echo ""
  '';
}
