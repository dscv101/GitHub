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
    markdownlint *.md
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
    markdownlint *.md

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

# Git status with jujutsu
status:
    jj st

# Git log with jujutsu
log:
    jj ls

# Git diff with jujutsu
diff:
    jj d

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
