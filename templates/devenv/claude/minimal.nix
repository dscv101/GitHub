# Minimal Claude Code Integration for devenv
#
# This template shows the simplest way to enable Claude Code integration
# in your devenv.nix configuration.
#
# Usage: Add this to your devenv.nix file to enable basic Claude Code support.
{pkgs, ...}: {
  # Claude Code integration is enabled via environment variables and shell setup
  # No special devenv configuration needed - Claude works with any devenv shell

  # Basic development packages that work well with Claude
  packages = with pkgs; [
    # Version control
    git

    # Text processing (useful for Claude operations)
    jq
    yq

    # Basic development tools
    curl
    wget

    # Shell utilities
    bash
    coreutils
  ];

  # Environment variables for Claude Code integration
  env = {
    # Indicate that Claude Code is enabled
    CLAUDE_CODE_ENABLED = "true";

    # Set the project root for Claude context
    CLAUDE_PROJECT_ROOT = builtins.toString ./.;
  };

  # Welcome message that indicates Claude Code is available
  enterShell = ''
    echo "🤖 Claude Code integration is enabled!"
    echo "   Use Claude to interact with this development environment."
    echo "   All commands will run within this devenv shell context."

    # Check if Claude Code CLI is available
    if command -v claude &> /dev/null; then
      echo "✅ Claude Code CLI detected"
    else
      echo "⚠️  Claude Code CLI not found in PATH"
      echo "   Install from: https://claude.ai/code"
    fi

    echo ""
  '';

  # Basic shell configuration for Claude compatibility
  shell = pkgs.bash;

  # Git configuration for Claude operations
  # Note: git-hooks are not part of devenv core, use pre-commit-hooks.nix instead
  # See with-hooks.nix template for git hooks integration
}
