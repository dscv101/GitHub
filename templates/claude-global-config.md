# Claude Code Global Configuration for devenv

This is a template for your global `~/.claude/CLAUDE.md` configuration that enables Claude to work seamlessly with devenv-based development environments.

## Global Configuration

Place this content in `~/.claude/CLAUDE.md`:

```markdown
# Claude Code Configuration for devenv Integration

## Command Execution Strategy

When working in repositories with devenv integration:

1. **For projects with devenv.nix**: Always execute commands within the devenv shell
2. **For projects without devenv.nix**: Use ad-hoc devenv shells when appropriate
3. **For system commands**: Execute directly when devenv context isn't needed

## Shell Detection and Usage

### Primary Method: devenv shell
```bash
# Check if devenv.nix exists and use devenv shell
if [ -f "devenv.nix" ]; then
    devenv shell -- your-command-here
else
    # Fallback to direct execution or ad-hoc shell
    your-command-here
fi
```

### Ad-hoc devenv shells
For repositories without devenv.nix but where development tools are needed:
```bash
# Create temporary devenv shell with common tools
devenv shell --impure --expr '{
  packages = with pkgs; [ git nodejs python3 rustc cargo ];
}' -- your-command-here
```

## Language-Specific Patterns

### Nix/NixOS Projects
- Always use `devenv shell` for nix commands
- Use `nix develop` as fallback if devenv unavailable
- Prefer `nixfmt` for formatting Nix files

### Python Projects
```bash
devenv shell -- python -m pytest
devenv shell -- black .
devenv shell -- mypy .
```

### Rust Projects
```bash
devenv shell -- cargo test
devenv shell -- cargo build --release
devenv shell -- rustfmt src/**/*.rs
```

### Node.js Projects
```bash
devenv shell -- npm test
devenv shell -- npm run build
devenv shell -- prettier --write .
```

## Git Integration

When making commits, ensure pre-commit hooks run in the devenv context:
```bash
devenv shell -- git commit -m "your message"
```

## Environment Variables

Key environment variables to be aware of:
- `DEVENV_ROOT`: Points to the project root
- `DEVENV_STATE`: Points to the devenv state directory
- Language-specific variables set by devenv modules

## Best Practices

1. **Always check for devenv.nix first** before executing commands
2. **Use devenv shell for all development commands** in devenv projects
3. **Respect existing git hooks** and formatting configurations
4. **Prefer project-specific tool versions** over global ones
5. **Use ad-hoc shells sparingly** and only when necessary

## Troubleshooting

### Common Issues
- **Command not found**: Ensure the tool is available in the devenv configuration
- **Permission denied**: Check if devenv shell has proper permissions
- **Environment conflicts**: Use `devenv shell --pure` for isolated environment

### Debug Commands
```bash
# Check devenv status
devenv info

# List available packages
devenv shell -- which -a your-tool

# Debug environment
devenv shell -- env | grep -E "(PATH|DEVENV)"
```

## Integration with Claude Code Features

This configuration works with:
- ✅ Automatic formatting via git hooks
- ✅ Custom slash commands (/test, /build, etc.)
- ✅ Specialized agents (code-reviewer, test-writer, docs-updater)
- ✅ Security hooks (secrets protection)
- ✅ Project-specific tool configurations

For more information, see the project-specific Claude Code documentation.
```

## Usage Instructions

1. Copy the content above to `~/.claude/CLAUDE.md`
2. Customize the language-specific patterns for your workflow
3. Test with a devenv project to ensure proper integration
4. Adjust the ad-hoc shell configuration as needed

## Notes

- This configuration assumes Claude Code CLI is installed and configured
- The devenv binary must be available in your PATH
- Some commands may require additional permissions or network access
- Always test in a safe environment before using in production projects
