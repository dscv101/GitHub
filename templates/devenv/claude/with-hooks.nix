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
    CLAUDE_PROJECT_ROOT = builtins.toString ./.;
    
    # Hook configuration
    CLAUDE_HOOKS_DIR = "${builtins.toString ./.}/hooks";
  };

  # Pre-commit hooks are configured via external .pre-commit-config.yaml
  # The pre-commit package is available in the shell for manual setup
  # Example .pre-commit-config.yaml:
  #
  # repos:
  #   - repo: https://github.com/psf/black
  #     rev: 23.3.0
  #     hooks:
  #       - id: black
  #   - repo: https://github.com/nix-community/nixfmt
  #     rev: v1.2.0
  #     hooks:
  #       - id: nixfmt
  #
  # Run: pre-commit install to set up hooks

  # Claude Code specific hooks are implemented via external scripts
  # See hooks/protect-secrets.sh and hooks/run-tests.sh for Claude integration
  # These can be configured in your Claude Code settings to run automatically

  # Enhanced welcome message
  enterShell = ''
    echo "🤖 Claude Code integration is enabled with formatting tools!"
    echo "   • Formatters available: nixfmt, black, prettier, rustfmt"
    echo "   • Security hooks: See hooks/protect-secrets.sh"
    echo "   • Test automation: See hooks/run-tests.sh"
    
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
