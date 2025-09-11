# Justfile for nix-blazar

# Show available recipes
default:
    @just --list

# Format all files with treefmt (recommended)
fmt:
    treefmt

# Format only Nix files
fmt-nix:
    nix fmt

# Run all quality checks
check:
    nix flake check

# Run all linting checks
lint-all:
    @echo "🔍 Running all linting checks..."
    treefmt --check
    statix check
    deadnix
    shellcheck scripts/*.sh
    @just markdownlint
    yamllint .
    actionlint
    @echo "✅ All linting checks completed!"

# Run individual checks
lint:
    statix check

# Find dead code
deadnix:
    deadnix

# Check shell scripts
shellcheck:
    shellcheck scripts/*.sh

# Format shell scripts
shfmt:
    shfmt -w scripts/*.sh

# Check Markdown files
markdownlint:
    #!/usr/bin/env bash
    if find . -name "*.md" -not -path "./.git/*" | head -1 | read -r; then
        find . -name "*.md" -not -path "./.git/*" -exec markdownlint {} +
    else
        echo "No markdown files found"
    fi

# Check YAML files
yamllint:
    yamllint .

# Check GitHub Actions
actionlint:
    actionlint

# Sort imports and lists
keep-sorted:
    keep-sorted

# Format TOML files
taplo:
    taplo fmt

# Format Lua files
stylua:
    stylua .

# Initialize Python project in current directory
init-python:
    devenv shell python -c py-init
    cp examples/python/.envrc .envrc
    @echo "🐍 Python project initialized! Run 'direnv allow' to activate."

# Initialize Rust project in current directory
init-rust:
    devenv shell rust -c rust-init
    cp examples/rust/.envrc .envrc
    @echo "🦀 Rust project initialized! Run 'direnv allow' to activate."

# Initialize Zig project in current directory
init-zig:
    devenv shell zig -c zig-init
    cp examples/zig/.envrc .envrc
    @echo "⚡ Zig project initialized! Run 'direnv allow' to activate."

# Initialize Julia project in current directory
init-julia:
    devenv shell julia -c julia-init
    cp examples/julia/.envrc .envrc
    @echo "🔬 Julia project initialized! Run 'direnv allow' to activate."

# Build the system configuration
build:
    sudo nixos-rebuild build --flake .#blazar

# Test the system configuration
test:
    sudo nixos-rebuild test --flake .#blazar

# Switch to the new system configuration
switch:
    sudo nixos-rebuild switch --flake .#blazar

# Enter default development shell
dev:
    nix develop

# Enter Python development environment
dev-python:
    devenv shell python

# Enter Rust development environment
dev-rust:
    devenv shell rust

# Enter Zig development environment
dev-zig:
    devenv shell zig

# Enter Julia development environment
dev-julia:
    devenv shell julia

# Update flake inputs
update:
    nix flake update

# Show flake info
info:
    nix flake show

# Clean up old generations (keep last 3)
clean:
    sudo nix-collect-garbage -d --delete-older-than 7d
    nix-collect-garbage -d --delete-older-than 7d

# Show system generations
generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# ============================================================================
# Jujutsu SCM Integration
# ============================================================================

# Check if jujutsu is installed and available
_jj-check-install:
    #!/usr/bin/env bash
    if ! command -v jj &> /dev/null; then
        echo "❌ Error: Jujutsu (jj) is not installed or not in PATH"
        echo "💡 Install jujutsu: https://github.com/martinvonz/jj#installation"
        exit 1
    fi

# Check if current directory is a jujutsu repository
_jj-check-repo:
    #!/usr/bin/env bash
    if ! jj root &> /dev/null; then
        echo "❌ Error: Not in a jujutsu repository"
        echo "💡 Initialize with: just jj-init"
        echo "💡 Or navigate to a jujutsu repository directory"
        exit 1
    fi

# Show help for all jujutsu commands
jj-help:
    @echo "🔧 Jujutsu SCM Commands Available:"
    @echo ""
    @echo "Repository Management:"
    @echo "  jj-init           Initialize a new jujutsu repository"
    @echo "  jj-add [pattern]  Add files to working copy (default: all files)"
    @echo "  jj-commit [msg]   Create a commit with optional message"
    @echo ""
    @echo "Navigation & History:"
    @echo "  jj-checkout <rev> Switch to a different revision"
    @echo "  jj-branch         Manage branches (create/list)"
    @echo "  jj-status         Show working copy status"
    @echo "  jj-log [limit]    Display commit history (default: 10 commits)"
    @echo "  jj-diff [rev]     Show differences (default: working copy)"
    @echo ""
    @echo "Remote Operations:"
    @echo "  jj-push [remote]  Push to remote repository"
    @echo "  jj-pull [remote]  Pull from remote repository"
    @echo ""
    @echo "💡 Use 'just --show <command>' for detailed help on any command"

# Initialize a new jujutsu repository
jj-init:
    @just _jj-check-install
    @echo "🚀 Initializing jujutsu repository..."
    jj init
    @echo "✅ Jujutsu repository initialized successfully!"

# Add files to working copy with optional pattern
jj-add pattern="." :
    @just _jj-check-install
    @just _jj-check-repo
    @echo "📁 Adding files: {{pattern}}"
    jj add "{{pattern}}"
    @echo "✅ Files added to working copy"

# Create a commit with optional message
jj-commit message="":
    @just _jj-check-install
    @just _jj-check-repo
    #!/usr/bin/env bash
    if [ -z "{{message}}" ]; then
    echo "💬 Creating commit (editor will open for message)..."
    jj commit
    else
    echo "💬 Creating commit with message: {{message}}"
    jj commit -m "{{message}}"
    fi
    echo "✅ Commit created successfully!"

# Switch to a different revision with validation
jj-checkout revision:
    @just _jj-check-install
    @just _jj-check-repo
    @echo "🔄 Switching to revision: {{revision}}"
    jj checkout "{{revision}}"
    @echo "✅ Switched to revision: {{revision}}"

# Manage branches (create new or list existing)
jj-branch action="list" name="":
    @just _jj-check-install
    @just _jj-check-repo
    #!/usr/bin/env bash
    case "{{action}}" in
    "create")
    if [ -z "{{name}}" ]; then
    echo "❌ Error: Branch name required for create action"
    echo "💡 Usage: just jj-branch create my-branch-name"
    exit 1
    fi
    echo "🌿 Creating branch: {{name}}"
    jj branch create "{{name}}"
    echo "✅ Branch '{{name}}' created successfully!"
    ;;
    "list"|"")
    echo "🌿 Listing branches:"
    jj branch list
    ;;
    *)
    echo "❌ Error: Unknown action '{{action}}'"
    echo "💡 Usage: just jj-branch [list|create] [name]"
    exit 1
    ;;
    esac

# Show working copy status (enhanced version of original)
jj-status:
    @just _jj-check-install
    @just _jj-check-repo
    @echo "📊 Working copy status:"
    jj status

# Display formatted commit history with optional limit
jj-log limit="10":
    @just _jj-check-install
    @just _jj-check-repo
    @echo "📜 Commit history (last {{limit}} commits):"
    jj log --limit {{limit}}

# Show differences with optional revision parameter
jj-diff revision="":
    @just _jj-check-install
    @just _jj-check-repo
    #!/usr/bin/env bash
    if [ -z "{{revision}}" ]; then
    echo "🔍 Showing working copy differences:"
    jj diff
    else
    echo "🔍 Showing differences for: {{revision}}"
    jj diff -r "{{revision}}"
    fi

# Push to remote repository with validation
jj-push remote="origin" branch="":
    @just _jj-check-install
    @just _jj-check-repo
    #!/usr/bin/env bash
    if [ -z "{{branch}}" ]; then
    echo "🚀 Pushing to {{remote}}..."
    jj git push --remote "{{remote}}"
    else
    echo "🚀 Pushing branch '{{branch}}' to {{remote}}..."
    jj git push --remote "{{remote}}" --branch "{{branch}}"
    fi
    echo "✅ Push completed successfully!"

# Pull from remote repository with conflict detection
jj-pull remote="origin":
    @just _jj-check-install
    @just _jj-check-repo
    @echo "⬇️ Pulling from {{remote}}..."
    jj git fetch --remote "{{remote}}"
    @echo "✅ Pull completed successfully!"
    @echo "💡 Use 'just jj-status' to check for any conflicts"

# Legacy aliases for backward compatibility
# Git status with jujutsu (legacy - use jj-status instead)
status:
    @echo "⚠️  'just status' is deprecated, use 'just jj-status' instead"
    @just jj-status

# Git log with jujutsu (legacy - use jj-log instead)  
log:
    @echo "⚠️  'just log' is deprecated, use 'just jj-log' instead"
    @just jj-log

# Git diff with jujutsu (legacy - use jj-diff instead)
diff:
    @echo "⚠️  'just diff' is deprecated, use 'just jj-diff' instead"
    @just jj-diff

# Initialize secrets (run once after install)
init-secrets:
    ./scripts/init-secrets.sh

# Edit secrets file
edit-secrets:
    sops secrets/sops/secrets.sops.yaml

# Backup manually (test backup configuration)
backup:
    sudo systemctl start restic-backup.service

# Check backup status
backup-status:
    sudo systemctl status restic-backup.service

# Show backup logs
backup-logs:
    sudo journalctl -u restic-backup.service -f

# ============================================================================
# Cache Management
# ============================================================================

# Setup Cachix cache (run once)
cache-setup:
    #!/usr/bin/env bash
    echo "🗄️ Setting up Cachix cache..."
    if ! command -v cachix &> /dev/null; then
        echo "Installing cachix..."
        nix profile install nixpkgs#cachix
    fi

    echo "Creating cache 'nix-blazar'..."
    cachix create nix-blazar
    echo "✅ Cache setup complete!"
    echo "💡 Add the auth token to your secrets: just edit-secrets"

# Push custom packages to cache
cache-push-packages:
    #!/usr/bin/env bash
    echo "📦 Building and pushing custom packages to cache..."
    if nix eval --json .#packages.x86_64-linux >/dev/null 2>&1; then
        packages=$(nix eval --json .#packages.x86_64-linux | nix run nixpkgs#jq -- -r 'keys[]')
        for package in $packages; do
            echo "Building and pushing: $package"
            nix build ".#packages.x86_64-linux.$package" --print-build-logs
            cachix push nix-blazar result
        done
    else
        echo "No custom packages found"
    fi

# Push development shells to cache
cache-push-devshells:
    #!/usr/bin/env bash
    echo "🧪 Building and pushing development shells to cache..."

    # Default shell
    echo "Building default devShell..."
    nix develop --command true

    # Language-specific shells
    for shell in python rust zig julia; do
        echo "Building $shell devShell..."
        if nix develop ".#$shell" --command true; then
            echo "✅ $shell shell cached"
        else
            echo "❌ $shell shell failed"
        fi
    done

# Push system configuration to cache
cache-push-system:
    #!/usr/bin/env bash
    echo "🏗️ Building and pushing system configuration to cache..."
    if nix eval --json .#nixosConfigurations >/dev/null 2>&1; then
        configs=$(nix eval --json .#nixosConfigurations | nix run nixpkgs#jq -- -r 'keys[]')
        for config in $configs; do
            echo "Building and pushing: $config"
            nix build ".#nixosConfigurations.$config.config.system.build.toplevel" --print-build-logs
            cachix push nix-blazar result
        done
    else
        echo "No NixOS configurations found"
    fi

# Push everything to cache
cache-push-all:
    @echo "🚀 Pushing all builds to cache..."
    @just cache-push-packages
    @just cache-push-devshells
    @just cache-push-system
    @echo "✅ All builds pushed to cache!"

# Check cache status
cache-status:
    #!/usr/bin/env bash
    echo "📊 Cache status for nix-blazar:"
    if command -v cachix &> /dev/null; then
        cachix info nix-blazar
    else
        echo "❌ Cachix not installed. Run: nix profile install nixpkgs#cachix"
    fi

# Use cache for builds (configure substituters)
cache-use:
    #!/usr/bin/env bash
    echo "🔧 Configuring cache usage..."
    if command -v cachix &> /dev/null; then
        cachix use nix-blazar
        echo "✅ Cache configured for use"
    else
        echo "❌ Cachix not installed. Run: nix profile install nixpkgs#cachix"
    fi
