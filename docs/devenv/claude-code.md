# Using Claude Code with devenv

This guide shows how to integrate Claude Code with devenv-based development environments for a seamless AI-assisted development workflow.

## Table of Contents

- [Quick Start](#quick-start)
- [Global Configuration](#global-configuration)
- [Project Configuration](#project-configuration)
- [Git Hooks Integration](#git-hooks-integration)
- [Custom Commands](#custom-commands)
- [Specialized Agents](#specialized-agents)
- [Security Features](#security-features)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)

## Quick Start

### 1. Install Claude Code CLI

First, install the Claude Code CLI from [claude.ai/code](https://claude.ai/code).

### 2. Set Up Global Configuration

Create or update your global Claude configuration at `~/.claude/CLAUDE.md`:

```bash
# Copy the template
cp templates/claude-global-config.md ~/.claude/CLAUDE.md

# Edit to customize for your workflow
$EDITOR ~/.claude/CLAUDE.md
```

### 3. Enable in Your Project

Add Claude Code integration to your `devenv.nix`:

```nix
# Minimal setup
{
  claude.code.enable = true;
}
```

### 4. Test the Integration

```bash
# Enter the devenv shell
devenv shell

# You should see a message about Claude Code being enabled
# Test that Claude can execute commands in the devenv context
```

## Global Configuration

The global configuration (`~/.claude/CLAUDE.md`) tells Claude how to work with devenv projects. Key features:

### Command Execution Strategy

Claude will automatically:
1. **Detect devenv projects** by looking for `devenv.nix`
2. **Use devenv shell** for all development commands
3. **Fall back to ad-hoc shells** when needed
4. **Execute system commands directly** when devenv context isn't needed

### Language-Specific Patterns

The global config includes patterns for:
- **Nix/NixOS**: `devenv shell -- nix build`, `nixfmt`
- **Python**: `devenv shell -- pytest`, `black .`
- **Rust**: `devenv shell -- cargo test`, `rustfmt`
- **Node.js**: `devenv shell -- npm test`, `prettier`

### Example Global Config

```markdown
# Claude Code Configuration for devenv Integration

## Command Execution Strategy
When working in repositories with devenv integration:
1. For projects with devenv.nix: Always execute commands within the devenv shell
2. For projects without devenv.nix: Use ad-hoc devenv shells when appropriate
3. For system commands: Execute directly when devenv context isn't needed

## Shell Detection and Usage
```bash
# Check if devenv.nix exists and use devenv shell
if [ -f "devenv.nix" ]; then
    devenv shell -- your-command-here
else
    your-command-here
fi
```
```

## Project Configuration

### Minimal Configuration

The simplest way to enable Claude Code in your project:

```nix
# devenv.nix
{ pkgs, lib, config, ... }:

{
  # Enable Claude Code integration
  claude.code.enable = true;
  
  # Basic packages that work well with Claude
  packages = with pkgs; [
    git
    jq
    curl
  ];
}
```

### Configuration Options

```nix
claude.code = {
  enable = true;
  
  # Optional: Configure hooks
  hooks = {
    preToolUse.enable = true;   # Security hooks
    postToolUse.enable = true;  # Test/validation hooks
  };
  
  # Optional: Custom commands
  commands = {
    test = { /* ... */ };
    build = { /* ... */ };
  };
  
  # Optional: Specialized agents
  agents = {
    code-reviewer = { /* ... */ };
    test-writer = { /* ... */ };
  };
};
```

## Git Hooks Integration

Enable automatic formatting and validation when Claude makes changes:

```nix
# Use the with-hooks template
{ pkgs, lib, config, ... }:

{
  claude.code.enable = true;
  
  # Enable git hooks for automatic formatting
  git-hooks = {
    enable = true;
    hooks = {
      nixfmt.enable = true;
      black.enable = true;
      prettier.enable = true;
      rustfmt.enable = true;
    };
  };
  
  # Claude-specific hooks
  claude.code.hooks = {
    preToolUse = {
      enable = true;
      script = ''
        # Protect sensitive files
        ./hooks/protect-secrets.sh "$@"
      '';
    };
    
    postToolUse = {
      enable = true;
      script = ''
        # Run tests after changes
        ./hooks/run-tests.sh "$@"
      '';
    };
  };
}
```

### Available Formatters

- **nixfmt**: Nix code formatting
- **black**: Python code formatting
- **prettier**: JavaScript/TypeScript/JSON/YAML formatting
- **rustfmt**: Rust code formatting
- **shellcheck**: Shell script linting
- **yamllint**: YAML linting

## Custom Commands

Define slash commands that Claude can discover and use:

```nix
claude.code.commands = {
  test = {
    description = "Run the project test suite";
    help = "Runs tests using the appropriate framework";
    script = ''
      #!/usr/bin/env bash
      if [ -f "package.json" ]; then
        devenv shell -- npm test
      elif [ -f "Cargo.toml" ]; then
        devenv shell -- cargo test
      fi
    '';
  };
  
  build = {
    description = "Build the project";
    script = ''
      #!/usr/bin/env bash
      # Auto-detect and build
      # ... build logic ...
    '';
  };
  
  deploy = {
    description = "Deploy the project";
    script = ''
      #!/usr/bin/env bash
      # Deployment logic
      # ... deploy logic ...
    '';
  };
};
```

### Available Commands

The templates include these commands:
- `/test` - Run project tests
- `/build` - Build the project
- `/deploy` - Deploy the project
- `/db-migrate` - Run database migrations
- `/format` - Format all code
- `/lint` - Run all linters

## Specialized Agents

Configure specialized Claude agents for specific tasks:

```nix
claude.code.agents = {
  code-reviewer = {
    description = "Expert code review specialist";
    proactive = true;  # Can suggest reviews
    tools = [ "Read" "Grep" "TodoWrite" "Diff" ];
    prompt = ''
      You are an expert code reviewer focused on quality,
      security, and best practices...
    '';
  };
  
  test-writer = {
    description = "Writes comprehensive test suites";
    proactive = false;  # Only when requested
    tools = [ "Read" "Write" "Edit" "Bash" "Grep" ];
    prompt = ''
      You are a test writing specialist...
    '';
  };
  
  docs-updater = {
    description = "Creates and maintains documentation";
    proactive = true;
    tools = [ "Read" "Write" "Edit" "Grep" ];
    prompt = ''
      You are a documentation specialist...
    '';
  };
};
```

### Available Agents

- **code-reviewer**: Code quality and security review
- **test-writer**: Comprehensive test suite creation
- **docs-updater**: Documentation creation and maintenance
- **security-auditor**: Security analysis and vulnerability detection

## Security Features

### Secrets Protection

The `protect-secrets.sh` hook prevents Claude from editing sensitive files:

**Protected Patterns:**
- `*.env`, `*.env.*`
- `*.secret`, `*.secrets`
- `*.key`, `*.pem`, `*.p12`
- SSH keys, AWS credentials, Docker configs

**Protected Directories:**
- `.ssh`, `.gnupg`, `.aws`, `.docker`
- `secrets`, `vault`, `keys`

### Configuration

```bash
# Enable strict mode (blocks potential secrets)
export CLAUDE_SECRETS_STRICT_MODE=true

# Configure custom patterns
export CLAUDE_PROTECTED_PATTERNS="*.custom,*.private"
```

### Content Scanning

The hook also scans file content for potential secrets:
- API keys, passwords, tokens
- Private keys and certificates
- SSH keys

## Best Practices

### 1. Start Simple

Begin with minimal configuration and add features as needed:

```nix
# Start here
{ claude.code.enable = true; }

# Then add hooks
{ claude.code = { enable = true; hooks.preToolUse.enable = true; }; }

# Then add commands and agents
```

### 2. Use Templates

Copy and customize the provided templates:

```bash
# Minimal setup
cp templates/devenv/claude/minimal.nix devenv.nix

# With git hooks
cp templates/devenv/claude/with-hooks.nix devenv.nix

# With custom commands
cp templates/devenv/claude/commands.nix devenv.nix

# With specialized agents
cp templates/devenv/claude/agents.nix devenv.nix
```

### 3. Configure Environment Variables

Set up environment variables for consistent behavior:

```bash
# In your shell profile or devenv.nix
export CLAUDE_CODE_ENABLED=true
export CLAUDE_QUICK_TESTS=true          # For faster feedback
export CLAUDE_SECRETS_STRICT_MODE=true  # For security
export CLAUDE_FAIL_ON_TEST_FAILURE=false # For development
```

### 4. Test Your Configuration

```bash
# Test devenv shell integration
devenv shell -- echo "Claude can execute commands"

# Test git hooks
git add . && git commit -m "test"

# Test custom commands (if configured)
# Use /test, /build, etc. in Claude
```

### 5. Monitor and Adjust

- Check hook execution logs
- Adjust timeout values for your project size
- Customize agent prompts for your domain
- Add project-specific protected patterns

## Troubleshooting

### Common Issues

#### Claude Commands Not Working

**Problem**: Claude doesn't execute commands in devenv shell

**Solution**: Check global configuration:
```bash
# Verify global config exists
cat ~/.claude/CLAUDE.md

# Test devenv detection
ls -la devenv.nix

# Test devenv shell
devenv shell -- echo "test"
```

#### Git Hooks Not Running

**Problem**: Formatters don't run after Claude edits

**Solution**: Check git hooks configuration:
```bash
# Verify hooks are enabled
grep -A 10 "git-hooks" devenv.nix

# Test pre-commit manually
devenv shell -- pre-commit run --all-files

# Check hook scripts
ls -la hooks/
```

#### Tests Not Running

**Problem**: PostToolUse hook doesn't run tests

**Solution**: Check test configuration:
```bash
# Verify test runner is available
devenv shell -- which pytest  # or npm, cargo, etc.

# Test manually
./hooks/run-tests.sh

# Check environment variables
echo $CLAUDE_SKIP_TESTS
echo $CLAUDE_QUICK_TESTS
```

#### Secrets Protection Too Strict

**Problem**: Hook blocks legitimate files

**Solution**: Adjust protection settings:
```bash
# Disable strict mode
export CLAUDE_SECRETS_STRICT_MODE=false

# Customize patterns
export CLAUDE_PROTECTED_PATTERNS="*.env,*.secret"

# Test protection
./hooks/protect-secrets.sh your-file.txt
```

### Debug Mode

Enable debug output for troubleshooting:

```bash
# Enable debug logging
export CLAUDE_DEBUG=true

# Verbose hook execution
export CLAUDE_VERBOSE=true

# Test with debug output
devenv shell
```

### Getting Help

1. **Check the logs**: Look for Claude Code messages in your terminal
2. **Test components individually**: Run hooks and commands manually
3. **Verify devenv setup**: Ensure devenv works without Claude
4. **Check global config**: Verify `~/.claude/CLAUDE.md` is correct
5. **Review templates**: Compare your config with the provided templates

## Advanced Configuration

### Custom Hook Scripts

Create your own hooks for specific needs:

```bash
#!/usr/bin/env bash
# hooks/custom-validation.sh

# Your custom validation logic
if [[ "$CLAUDE_TOOL_NAME" == "Edit" ]]; then
    echo "Running custom validation for file edits..."
    # Add your logic here
fi
```

### Environment-Specific Configuration

Configure different behavior for different environments:

```nix
claude.code = {
  enable = true;
  
  # Development environment
  hooks.postToolUse = {
    enable = true;
    script = if config.environment == "development" 
      then "./hooks/dev-validation.sh"
      else "./hooks/prod-validation.sh";
  };
};
```

### Integration with CI/CD

Test Claude Code integration in CI:

```yaml
# .github/workflows/claude-integration.yml
name: Claude Code Integration Test

on: [push, pull_request]

jobs:
  test-claude-integration:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v20
      - name: Test devenv shell
        run: |
          nix develop --command echo "devenv works"
      - name: Test hooks
        run: |
          ./hooks/protect-secrets.sh test-file.txt
          ./hooks/run-tests.sh
```

### Performance Optimization

Optimize for large projects:

```nix
claude.code = {
  enable = true;
  
  # Optimize for performance
  hooks.postToolUse = {
    enable = true;
    script = ''
      # Enable quick tests for large projects
      export CLAUDE_QUICK_TESTS=true
      export MAX_TEST_TIME=120
      ./hooks/run-tests.sh
    '';
  };
};
```

## Examples

### Full-Featured Configuration

```nix
{ pkgs, lib, config, ... }:

{
  # Enable Claude Code with all features
  claude.code = {
    enable = true;
    
    # Security and validation hooks
    hooks = {
      preToolUse = {
        enable = true;
        script = "./hooks/protect-secrets.sh";
      };
      postToolUse = {
        enable = true;
        script = "./hooks/run-tests.sh";
      };
    };
    
    # Custom commands
    commands = {
      test = {
        description = "Run comprehensive tests";
        script = "devenv shell -- just test";
      };
      deploy = {
        description = "Deploy to staging";
        script = "devenv shell -- just deploy staging";
      };
    };
    
    # Specialized agents
    agents = {
      code-reviewer.enable = true;
      test-writer.enable = true;
      docs-updater.enable = true;
    };
  };
  
  # Enhanced development environment
  packages = with pkgs; [
    # Core tools
    git jq yq curl wget
    
    # Formatters
    nixfmt-classic black prettier rustfmt
    
    # Linters
    shellcheck yamllint
    
    # Testing
    pre-commit
  ];
  
  # Git hooks for automatic formatting
  git-hooks = {
    enable = true;
    hooks = {
      nixfmt.enable = true;
      black.enable = true;
      prettier.enable = true;
      shellcheck.enable = true;
    };
  };
  
  # Environment variables
  env = {
    CLAUDE_CODE_ENABLED = "true";
    CLAUDE_QUICK_TESTS = "true";
    CLAUDE_SECRETS_STRICT_MODE = "true";
  };
}
```

This comprehensive configuration provides:
- ✅ Automatic formatting via git hooks
- ✅ Security protection for sensitive files
- ✅ Automated testing after changes
- ✅ Custom slash commands
- ✅ Specialized AI agents
- ✅ Performance optimization
- ✅ Comprehensive development tools

## Conclusion

Claude Code integration with devenv provides a powerful, secure, and efficient AI-assisted development workflow. Start with the minimal configuration and gradually add features as your team's needs grow.

For more examples and updates, see the [templates directory](../../templates/devenv/claude/) and the [hooks directory](../../hooks/).
