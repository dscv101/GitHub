# Claude Code Integration with Git Hooks for devenv
#
# This template shows how to enable Claude Code integration with automatic
# formatting via git hooks. When Claude makes edits, pre-commit formatters
# will automatically run to ensure code quality.
#
# Usage: Add this to your devenv.nix file for Claude Code with formatting support.

{ pkgs, lib, config, ... }:

{
  # Claude Code integration is enabled via environment variables and git hooks
  # No special devenv configuration needed - Claude works with any devenv shell

  # Enhanced development packages for formatting and linting
  packages = with pkgs; [
    # Version control
    git
    
    # Text processing
    jq
    yq
    
    # Formatters (language-specific)
    nixfmt-classic  # Nix formatting
    black           # Python formatting
    prettier        # JavaScript/TypeScript/JSON/YAML formatting
    rustfmt         # Rust formatting
    
    # Linters
    shellcheck      # Shell script linting
    yamllint        # YAML linting
    
    # Development tools
    curl
    wget
    bash
    coreutils
    
    # Pre-commit framework
    pre-commit
  ];

  # Environment variables for Claude Code integration
  env = {
    # Indicate that Claude Code is enabled with hooks
    CLAUDE_CODE_ENABLED = "true";
    CLAUDE_CODE_HOOKS_ENABLED = "true";
    
    # Set the project root for Claude context
    CLAUDE_PROJECT_ROOT = config.env.DEVENV_ROOT or (builtins.toString ./.);
    
    # Hook configuration
    CLAUDE_HOOKS_DIR = "${config.env.DEVENV_ROOT or (builtins.toString ./.)}/hooks";
  };

  # Git hooks configuration for automatic formatting
  git-hooks = {
    enable = true;
    
    # Pre-commit hooks that run after Claude edits
    hooks = {
      # Nix formatting
      nixfmt = {
        enable = true;
        name = "nixfmt";
        entry = "${pkgs.nixfmt-classic}/bin/nixfmt";
        files = "\\.nix$";
        language = "system";
      };
      
      # Python formatting
      black = {
        enable = true;
        name = "black";
        entry = "${pkgs.black}/bin/black";
        files = "\\.py$";
        language = "system";
      };
      
      # JavaScript/TypeScript/JSON/YAML formatting
      prettier = {
        enable = true;
        name = "prettier";
        entry = "${pkgs.prettier}/bin/prettier --write";
        files = "\\.(js|ts|jsx|tsx|json|yaml|yml|md)$";
        language = "system";
      };
      
      # Rust formatting
      rustfmt = {
        enable = true;
        name = "rustfmt";
        entry = "${pkgs.rustfmt}/bin/rustfmt";
        files = "\\.rs$";
        language = "system";
      };
      
      # Shell script checking
      shellcheck = {
        enable = true;
        name = "shellcheck";
        entry = "${pkgs.shellcheck}/bin/shellcheck";
        files = "\\.(sh|bash)$";
        language = "system";
      };
      
      # YAML linting
      yamllint = {
        enable = true;
        name = "yamllint";
        entry = "${pkgs.yamllint}/bin/yamllint";
        files = "\\.ya?ml$";
        language = "system";
      };
    };
  };

  # Claude Code specific hooks
  claude.code.hooks = {
    # Pre-tool use hook for security
    preToolUse = {
      enable = true;
      script = ''
        #!/usr/bin/env bash
        # Protect sensitive files from Claude edits
        
        # Check if Claude is trying to edit sensitive files
        if echo "$CLAUDE_TOOL_ARGS" | jq -r '.file_path // empty' | grep -E '\.(env|secret|key|pem|p12)$' > /dev/null; then
          echo "🚫 Claude Code: Blocked edit to sensitive file"
          echo "   Files matching *.env, *.secret, *.key, *.pem, *.p12 are protected"
          exit 1
        fi
        
        # Allow the operation
        exit 0
      '';
    };
    
    # Post-tool use hook for testing and validation
    postToolUse = {
      enable = true;
      script = ''
        #!/usr/bin/env bash
        # Run after Claude makes changes
        
        echo "🔍 Claude Code: Running post-edit validation..."
        
        # Run formatters if files were modified
        if [ -n "$CLAUDE_MODIFIED_FILES" ]; then
          echo "📝 Formatting modified files..."
          devenv shell -- pre-commit run --files $CLAUDE_MODIFIED_FILES || true
        fi
        
        # Run quick tests if test files exist
        if [ -f "package.json" ] && [ -d "test" ]; then
          echo "🧪 Running quick tests..."
          devenv shell -- npm test -- --passWithNoTests || true
        elif [ -f "Cargo.toml" ]; then
          echo "🧪 Running Rust tests..."
          devenv shell -- cargo test --quiet || true
        elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
          echo "🧪 Running Python tests..."
          devenv shell -- python -m pytest --quiet || true
        fi
        
        echo "✅ Claude Code: Post-edit validation complete"
      '';
    };
  };

  # Enhanced welcome message
  enterShell = ''
    echo "🤖 Claude Code integration is enabled with git hooks!"
    echo "   • Automatic formatting: nixfmt, black, prettier, rustfmt"
    echo "   • Security hooks: Protects *.env, *.secret, *.key files"
    echo "   • Post-edit validation: Runs tests after changes"
    
    # Check if Claude Code CLI is available
    if command -v claude &> /dev/null; then
      echo "✅ Claude Code CLI detected"
    else
      echo "⚠️  Claude Code CLI not found in PATH"
      echo "   Install from: https://claude.ai/code"
    fi
    
    # Check if pre-commit is configured
    if [ -f ".pre-commit-config.yaml" ]; then
      echo "✅ Pre-commit configuration found"
    else
      echo "💡 Consider adding .pre-commit-config.yaml for additional hooks"
    fi
    
    echo ""
  '';

  # Shell configuration optimized for Claude operations
  shell = pkgs.bash;
}
