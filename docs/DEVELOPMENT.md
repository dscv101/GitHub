# Development Environments

This repository provides reproducible development environments for multiple programming languages using Nix, devenv, and direnv.

## Quick Start

### Prerequisites

1. **Nix** with flakes enabled
2. **direnv** for automatic environment activation
3. **devenv** for development environments

```bash
# Install direnv (if not already installed)
nix profile install nixpkgs#direnv

# Enable direnv in your shell
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc  # for bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc    # for zsh
```

### Available Environments

- **Python** - uv, ruff, mypy, bandit, coverage, pytest
- **Rust** - cargo, clippy, rustfmt, rust-analyzer + dev tools
- **Zig** - zig compiler, zls language server, debugging tools
- **Julia** - julia interpreter, package manager, jupyter

## Usage

### Method 1: Using devenv directly

```bash
# Enter specific development environment
devenv shell python   # Python environment
devenv shell rust     # Rust environment
devenv shell zig      # Zig environment
devenv shell julia    # Julia environment
```

### Method 2: Using just commands

```bash
# Quick access via just
just dev-python
just dev-rust
just dev-zig
just dev-julia
```

### Method 3: Project initialization

```bash
# Initialize new projects with proper .envrc
just init-python    # Creates Python project + .envrc
just init-rust      # Creates Rust project + .envrc
just init-zig       # Creates Zig project + .envrc
just init-julia     # Creates Julia project + .envrc

# Then allow direnv to activate automatically
direnv allow
```

## Language-Specific Features

### Python Environment

**Tools included:**
- `uv` - Fast Python package manager
- `ruff` - Fast linter and formatter
- `mypy` - Static type checker
- `bandit` - Security linter
- `pytest` + `coverage` - Testing and coverage
- `ipython`, `jupyterlab` - Interactive development

**Available commands:**
```bash
py-init      # Initialize new Python project
py-install   # Install dependencies with uv
py-test      # Run tests with coverage
py-lint      # Run linting (ruff, mypy, bandit)
py-format    # Format code with ruff
py-clean     # Clean Python artifacts
```

### Rust Environment

**Tools included:**
- Full Rust toolchain (rustc, cargo, clippy, rustfmt, rust-analyzer)
- `cargo-watch`, `cargo-edit`, `cargo-audit` - Development tools
- `cargo-nextest` - Fast test runner
- `bacon` - Background code checker
- `sccache` - Compilation cache

**Available commands:**
```bash
rust-init      # Initialize new Rust project
rust-build     # Build the project
rust-test      # Run tests (with nextest)
rust-check     # Run checks (check, clippy, fmt)
rust-format    # Format code with rustfmt
rust-audit     # Security audit
rust-clean     # Clean build artifacts
rust-watch     # Watch files and run checks
```

### Zig Environment

**Tools included:**
- `zig` compiler
- `zls` - Zig Language Server
- `gdb`, `lldb` - Debuggers
- Build tools (cmake, ninja)

**Available commands:**
```bash
zig-init       # Initialize executable project
zig-init-lib   # Initialize library project
zig-build      # Build the project
zig-run        # Build and run
zig-test       # Run tests
zig-format     # Format code
zig-clean      # Clean artifacts
```

### Julia Environment

**Tools included:**
- `julia` interpreter
- Package manager (Pkg)
- `jupyter` notebook support
- System libraries for common packages

**Available commands:**
```bash
julia-init       # Initialize new Julia project
julia-install    # Install dependencies
julia-test       # Run tests
julia-repl       # Start Julia REPL
julia-notebook   # Start Jupyter notebook
julia-add <pkg>  # Add package
julia-status     # Show package status
```

## Automatic Environment Detection

The main `.envrc` file automatically detects project types:

- **Python**: Looks for `pyproject.toml`, `requirements.txt`, `setup.py`
- **Rust**: Looks for `Cargo.toml`
- **Zig**: Looks for `build.zig`
- **Julia**: Looks for `Project.toml`

## Best Practices

1. **Use project-specific .envrc files** for automatic activation
2. **Keep dependencies in lock files** (requirements.txt, Cargo.lock, etc.)
3. **Use the provided scripts** for consistent workflows
4. **Clean artifacts regularly** using the `*-clean` commands

## Troubleshooting

### Environment not activating
```bash
# Reload direnv
direnv reload

# Check direnv status
direnv status
```

### Missing tools
```bash
# Rebuild development environment
nix develop --rebuild

# Or for specific environment
devenv shell python --rebuild
```

### Cache issues
```bash
# Clear Nix cache
nix-collect-garbage -d

# Clear language-specific caches
py-clean     # Python
rust-clean   # Rust
zig-clean    # Zig
julia-clean  # Julia
```
