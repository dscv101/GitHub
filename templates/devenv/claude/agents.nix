# Claude Code Specialized Agents for devenv
#
# This template shows how to configure specialized Claude agents with
# constrained tool access and best-practice prompts for specific tasks.
#
# Usage: Add this to your devenv.nix file for specialized Claude agents.

{ pkgs, lib, config, ... }:

{
  # Claude Code integration with specialized agents
  # Agents are configured via environment variables and documentation
  # No special devenv configuration needed - Claude works with any devenv shell
  
  # Environment variables to configure specialized agents behavior
  env = {
    CLAUDE_CODE_ENABLED = "true";
    CLAUDE_CODE_AGENTS_ENABLED = "true";
    
    # Available specialized agents
    CLAUDE_AVAILABLE_AGENTS = "code-reviewer,test-writer,docs-updater,security-auditor";
    
    # Agent descriptions for Claude to understand their roles
    CLAUDE_AGENT_CODE_REVIEWER = "Expert code review specialist focused on quality, security, and best practices";
    CLAUDE_AGENT_TEST_WRITER = "Comprehensive test suite creator with expertise in various testing frameworks";
    CLAUDE_AGENT_DOCS_UPDATER = "Documentation specialist for creating and maintaining project documentation";
    CLAUDE_AGENT_SECURITY_AUDITOR = "Security analysis expert for vulnerability detection and mitigation";
    
    # Project root for agent context
    CLAUDE_PROJECT_ROOT = config.env.DEVENV_ROOT or (builtins.toString ./.);
  };

  # Include packages needed for agent operations
  packages = with pkgs; [
    # Version control for diff operations
    git
    
    # Text processing for agents
    jq
    yq
    grep
    ripgrep
    
    # Development tools
    curl
    wget
    
    # Shell utilities
    bash
    coreutils
    findutils
  ];

  # Enhanced welcome message showing available agents
  enterShell = ''
    echo "🤖 Claude Code integration is enabled with specialized agents!"
    echo "   Available agents:"
    echo "   • code-reviewer    - Expert code review and quality analysis"
    echo "   • test-writer      - Comprehensive test suite creation"
    echo "   • docs-updater     - Documentation creation and maintenance"
    echo "   • security-auditor - Security analysis and vulnerability detection"
    echo ""
    echo "   Agents provide specialized expertise for different development tasks."
    echo "   Use @agent-name to interact with specific agents in Claude."
    echo ""
  '';
}
