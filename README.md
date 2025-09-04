# nix-blazar: Modular NixOS Configuration

A modular NixOS flake configuration using flake-parts for **blazar** (Ryzen 7 5800X + NVIDIA GTX 970), featuring Wayland-only **Niri**, Home Manager, JJ (Jujutsu) stacked-PR workflow, DuckDB + MotherDuck, Podman, sops-nix, Disko, and Impermanence.

Refactored to use a modular architecture inspired by [Isabel Roses' dotfiles](https://github.com/isabelroses/dotfiles).

## Features

- **Modular Architecture**: Clean separation of concerns with organized modules
- **Flake-parts Integration**: Leverages flake-parts for better organization
- **Wayland/GBM** with NVIDIA (closed driver), Niri compositor, greetd+tuigreet login
- **Home Manager** user `dscv`: zsh + Starship, VS Code (official), Ghostty, Waybar, Mako, fuzzel
- **Dev toolchain**: uv/ruff/mypy/pytest, DuckDB + extensions, Postgres/SQLite clients, direnv+devenv
- **Secrets** via **sops-nix**; **Tailscale** auto-join (SSH enabled); MotherDuck token ready
- **Disk layout** via **Disko**: EFI 1.5GiB → LUKS2 → Btrfs (@, @home, @nix, @log, @persist, @snapshots)
- **Impermanence**: persist only curated paths under `/persist`
- **Backups**: restic → rclone(B2) daily @ 03:30 (custom systemd unit)
- **Quality Assurance**: Automated formatting, linting, and dead code detection

## Structure

```text
├── flake.nix                 # Main flake entry point
├── modules/
│   ├── flake/                # Flake-parts modules
│   │   ├── args.nix          # Base arguments and system configuration
│   │   ├── lib/              # Helper functions
│   │   ├── packages/         # Custom packages
│   │   ├── programs/         # Development shell and tools
│   │   └── checks/           # Quality checks (formatting, linting)
│   ├── base/                 # Base system modules
│   ├── nixos/                # NixOS-specific modules
│   │   ├── desktop/          # Desktop environment (Niri, fonts, etc.)
│   │   ├── hardware/         # Hardware configuration
│   │   ├── networking/       # Network configuration
│   │   ├── security/         # Security configuration
│   │   ├── services/         # System services
│   │   └── virtualization/   # Container and VM support
│   └── home/                 # Home Manager modules
│       ├── shell/            # Shell configuration
│       ├── development/      # Development tools
│       ├── desktop/          # Desktop applications
│       └── theming/          # GTK themes and appearance
├── systems/
│   ├── default.nix           # System definitions
│   └── blazar/               # Host-specific configuration
├── home/dscv/                # User-specific configuration
└── secrets/sops/             # SOPS secrets configuration
```

## Install (from ISO, declarative Disko)

```bash
# 1) Boot official NixOS ISO, ensure internet
nix-shell -p git --run 'git clone <your-fork-or-local-path> nix-blazar && cd nix-blazar'

# 2) Partition/format/mount
sudo nix run github:nix-community/disko -- --mode disko ./systems/blazar/disko.nix

# 3) Install
sudo nixos-install --flake .#blazar
reboot
```

## First boot checklist

1. Run `./scripts/init-secrets.sh` to generate the age key and create a placeholder `secrets.sops.yaml`.
2. Put your **Tailscale** auth key, **B2** creds, **RESTIC_PASSWORD**, etc. in `secrets/sops/secrets.sops.yaml` and encrypt with:

   ```bash
   sops -e -i secrets/sops/secrets.sops.yaml
   ```

3. (Optional) Add an rclone config as a SOPS file/secret if you prefer a standalone config file.
4. Login as **dscv**; greetd will present a TUI; select the **niri** session.
5. Verify Wayland: `echo $XDG_SESSION_TYPE` → `wayland`.

## Usage

### Building the System

```bash
# Build and switch to the new configuration
sudo nixos-rebuild switch --flake .#blazar

# Test the configuration without switching
sudo nixos-rebuild test --flake .#blazar
```

### Development

```bash
# Enter development shell with all tools
nix develop

# Format all Nix files
nix fmt

# Run all quality checks
nix flake check

# Individual checks
statix check    # Lint for anti-patterns
deadnix         # Find dead code
```

### Common Commands

The justfile includes comprehensive Jujutsu SCM integration with error handling and validation:

```bash
# Show all available jj commands
just jj-help

# Repository management
just jj-init                    # Initialize jujutsu repository
just jj-add [pattern]           # Add files (default: all)
just jj-commit [message]        # Create commit

# Navigation and history
just jj-status                  # Show working copy status
just jj-log [limit]             # Show commit history (default: 10)
just jj-diff [revision]         # Show differences
just jj-checkout <revision>     # Switch revisions
just jj-branch [action] [name]  # Manage branches

# Remote operations
just jj-push [remote] [branch]  # Push to remote
just jj-pull [remote]           # Pull from remote
```

**Legacy commands** (deprecated, use jj-* versions instead):

- `just status` → `just jj-status`
- `just log` → `just jj-log`  
- `just diff` → `just jj-diff`

📖 **Full documentation**: [docs/jujutsu_integration.md](docs/jujutsu_integration.md)

### Claude Code Integration

This repository includes comprehensive Claude Code integration for AI-assisted development:

```bash
# Quick setup - copy global config template
cp templates/claude-global-config.md ~/.claude/CLAUDE.md

# Enable in your devenv.nix
echo '{ claude.code.enable = true; }' >> devenv.nix

# Use templates for advanced features
cp templates/devenv/claude/with-hooks.nix devenv.nix    # Git hooks + formatting
cp templates/devenv/claude/commands.nix devenv.nix     # Custom /commands
cp templates/devenv/claude/agents.nix devenv.nix       # Specialized agents
```

**Features:**
- 🤖 **Automatic devenv shell integration** - Claude executes all commands in proper environment
- 🔒 **Security hooks** - Protects sensitive files (*.env, *.secret, *.key, etc.)
- 🧪 **Automated testing** - Runs tests after Claude makes changes
- 🎨 **Auto-formatting** - Runs nixfmt, black, prettier, rustfmt after edits
- ⚡ **Custom commands** - /test, /build, /deploy, /db-migrate slash commands
- 👥 **Specialized agents** - code-reviewer, test-writer, docs-updater, security-auditor

📖 **Full documentation**: [docs/devenv/claude-code.md](docs/devenv/claude-code.md)

## Migration from Old Structure

This configuration was refactored from a monolithic structure to a modular one:

### Key Changes

- `profiles/common` → `modules/base` + `modules/nixos`
- `profiles/desktop-niri` → `modules/nixos/desktop`
- `profiles/devtoolchain` → `modules/nixos/services/development`
- `profiles/nvidia` → `modules/nixos/hardware/graphics`
- `hosts/blazar` → `systems/blazar`

### Benefits

- **Easier Maintenance**: Changes are localized to specific modules
- **Better Organization**: Related configuration is grouped together
- **Improved Reusability**: Modules can be shared between systems
- **Enhanced Testing**: Individual modules can be tested independently

## Notes

- This repo is a **skeleton**: adjust as needed (Waybar style, Niri output names, etc.)
- For NVIDIA Wayland quirks, `WLR_NO_HARDWARE_CURSORS=1` is set; you can remove if not needed
- Impermanence binds from `/persist` to listed paths; see `systems/blazar/default.nix`
