# Jujutsu SCM Integration

This document describes the comprehensive Jujutsu SCM integration available in the justfile.

## Overview

The justfile now includes a complete set of Jujutsu (jj) commands that provide a streamlined interface for version control operations. All commands include proper error handling, validation, and helpful feedback.

## Quick Start

```bash
# Show all available jj commands
just jj-help

# Initialize a new jujutsu repository
just jj-init

# Add files and create a commit
just jj-add
just jj-commit "Initial commit"

# View status and history
just jj-status
just jj-log
```

## Available Commands

### Repository Management

#### `just jj-init`
Initialize a new jujutsu repository in the current directory.

**Example:**
```bash
just jj-init
```

#### `just jj-add [pattern]`
Add files to the working copy. Defaults to adding all files if no pattern is specified.

**Examples:**
```bash
just jj-add              # Add all files
just jj-add "src/"       # Add files in src/ directory
just jj-add "*.rs"       # Add all Rust files
```

#### `just jj-commit [message]`
Create a commit. If no message is provided, opens an editor for the commit message.

**Examples:**
```bash
just jj-commit                           # Open editor for message
just jj-commit "Fix authentication bug"  # Commit with inline message
```

### Navigation & History

#### `just jj-checkout <revision>`
Switch to a different revision. The revision can be a commit hash, branch name, or other jj revision identifier.

**Examples:**
```bash
just jj-checkout main
just jj-checkout abc123
just jj-checkout @-      # Previous revision
```

#### `just jj-branch [action] [name]`
Manage branches. Default action is `list`.

**Examples:**
```bash
just jj-branch                    # List all branches
just jj-branch list              # List all branches (explicit)
just jj-branch create feature-x  # Create new branch
```

#### `just jj-status`
Show the current working copy status, including modified files and current revision.

**Example:**
```bash
just jj-status
```

#### `just jj-log [limit]`
Display commit history. Defaults to showing the last 10 commits.

**Examples:**
```bash
just jj-log      # Show last 10 commits
just jj-log 5    # Show last 5 commits
just jj-log 20   # Show last 20 commits
```

#### `just jj-diff [revision]`
Show differences. If no revision is specified, shows working copy changes.

**Examples:**
```bash
just jj-diff           # Show working copy changes
just jj-diff main      # Show changes compared to main
just jj-diff abc123    # Show changes in specific revision
```

### Remote Operations

#### `just jj-push [remote] [branch]`
Push changes to a remote repository. Defaults to pushing to `origin`.

**Examples:**
```bash
just jj-push                    # Push to origin
just jj-push upstream           # Push to upstream remote
just jj-push origin feature-x   # Push specific branch to origin
```

#### `just jj-pull [remote]`
Pull changes from a remote repository. Defaults to pulling from `origin`.

**Examples:**
```bash
just jj-pull           # Pull from origin
just jj-pull upstream  # Pull from upstream remote
```

## Error Handling

All commands include comprehensive error handling:

- **Installation Check**: Commands verify that jujutsu is installed before executing
- **Repository Validation**: Commands that require a jj repository check that you're in one
- **Parameter Validation**: Commands validate required parameters and provide helpful usage messages
- **Clear Error Messages**: All errors include helpful suggestions for resolution

### Common Error Scenarios

1. **Jujutsu Not Installed**
   ```
   ❌ Error: Jujutsu (jj) is not installed or not in PATH
   💡 Install jujutsu: https://github.com/martinvonz/jj#installation
   ```

2. **Not in a Jujutsu Repository**
   ```
   ❌ Error: Not in a jujutsu repository
   💡 Initialize with: just jj-init
   💡 Or navigate to a jujutsu repository directory
   ```

3. **Missing Required Parameters**
   ```
   ❌ Error: Branch name required for create action
   💡 Usage: just jj-branch create my-branch-name
   ```

## Legacy Command Support

For backward compatibility, the original `status`, `log`, and `diff` commands are still available but show deprecation warnings:

```bash
just status  # Shows warning, then runs jj-status
just log     # Shows warning, then runs jj-log  
just diff    # Shows warning, then runs jj-diff
```

**Migration Path:**
- Replace `just status` with `just jj-status`
- Replace `just log` with `just jj-log`
- Replace `just diff` with `just jj-diff`

## Advanced Usage

### Workflow Examples

**Basic Development Workflow:**
```bash
# Start working on a feature
just jj-branch create feature-auth
just jj-checkout feature-auth

# Make changes and commit
just jj-add "src/auth.rs"
just jj-commit "Add OAuth authentication"

# Check status and push
just jj-status
just jj-push origin feature-auth
```

**Review Changes:**
```bash
# See what's changed
just jj-status
just jj-diff

# Review recent history
just jj-log 5

# Compare with main branch
just jj-diff main
```

**Sync with Remote:**
```bash
# Pull latest changes
just jj-pull

# Check for conflicts
just jj-status

# Push your changes
just jj-push
```

## Integration with Existing Workflow

The jj commands integrate seamlessly with the existing justfile recipes:

```bash
# Format code and commit
just fmt
just jj-add
just jj-commit "Format code with treefmt"

# Run checks before pushing
just check
just jj-push
```

## Troubleshooting

### Command Not Found
If you get "command not found" errors, ensure jujutsu is installed:

```bash
# Check if jj is installed
command -v jj

# Install jujutsu (example for different systems)
# macOS with Homebrew:
brew install jj

# Arch Linux:
pacman -S jujutsu

# From source:
cargo install --git https://github.com/martinvonz/jj jj-cli
```

### Repository Issues
If commands fail with repository errors:

1. Ensure you're in a jujutsu repository: `jj root`
2. Initialize if needed: `just jj-init`
3. Check repository status: `just jj-status`

### Getting Help
- Use `just jj-help` to see all available commands
- Use `just --show <command>` to see detailed help for any command
- Check the [Jujutsu documentation](https://github.com/martinvonz/jj/blob/main/docs/README.md) for advanced usage

## Performance Notes

- Commands include startup time for validation checks (~100ms)
- Repository validation is cached by jj for subsequent operations
- All commands complete within 30 seconds timeout limit
- Help text display is instantaneous

## Testing

Run the test suite to validate the integration:

```bash
python3 tests/test_justfile_jj.py
```

The test suite validates:
- Command availability and help text
- Error handling for missing installations
- Repository validation outside jj repos
- Parameter validation
- Legacy command deprecation warnings
