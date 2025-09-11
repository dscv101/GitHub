# Development Environments with devenv

This repository provides multiple development environments using [devenv](https://devenv.sh/) integrated with flake-parts.

## Quick Start

### Using Nix Flakes (Recommended)

```bash
# Default development shell with common tools
nix develop --no-pure-eval

# Language-specific environments
nix develop --no-pure-eval .#python   # Python with uv, ruff, mypy
nix develop --no-pure-eval .#rust     # Rust with cargo, clippy, rustfmt
nix develop --no-pure-eval .#zig      # Zig with zls, debugging tools
nix develop --no-pure-eval .#julia    # Julia with Jupyter, scientific libs
```

### Using devenv CLI

If you have devenv installed globally:

```bash
# Language-specific shells (flake-based)
devenv shell python
devenv shell rust
devenv shell zig
devenv shell julia
```

**Note**: The standalone `devenv.nix` file has been removed. All development environments are now unified under the flake-based approach for consistency and to eliminate duplication.

## Available Environments

### Default Shell

The default shell includes:
- **Version Control**: git, jujutsu
- **Nix Tooling**: alejandra, statix, deadnix, nixfmt-rfc-style
- **Development Tools**: direnv, just, sops, age
- **Linting & Formatting**: shellcheck, shfmt, markdownlint, yamllint, actionlint
- **Additional Tools**: treefmt, keep-sorted, taplo, stylua

### Python Environment

Features:
- **Python 3.12** with uv package manager
- **Linting**: ruff, mypy, bandit
- **Testing**: pytest, pytest-cov, coverage
- **Development**: ipython, jupyterlab, black, isort
- **Package Management**: pip-tools, virtualenv, pipx

Available commands:
- `py-init` - Initialize new Python project
- `py-install` - Install dependencies with uv
- `py-test` - Run tests with coverage
- `py-lint` - Run linting (ruff, mypy, bandit)
- `py-format` - Format code with ruff
- `py-clean` - Clean Python artifacts

### Rust Environment

Features:
- **Rust stable** with full toolchain
- **Tools**: cargo-watch, cargo-edit, cargo-audit, cargo-nextest
- **Development**: bacon (background checker), sccache (compilation cache)
- **Documentation**: mdbook
- **System Dependencies**: pkg-config, openssl

Available commands:
- `rust-init` - Initialize new Rust project
- `rust-build` - Build the project
- `rust-test` - Run tests (with nextest if available)
- `rust-check` - Run checks (check, clippy, fmt)
- `rust-format` - Format code with rustfmt
- `rust-audit` - Security audit
- `rust-watch` - Watch files and run checks

### Zig Environment

Features:
- **Zig compiler** with Zig Language Server (zls)
- **Debugging**: gdb, lldb, valgrind
- **Build Tools**: cmake, ninja
- **Documentation**: doxygen

Available commands:
- `zig-init` - Initialize new Zig executable project
- `zig-init-lib` - Initialize new Zig library project
- `zig-build` - Build the project
- `zig-run` - Build and run the project
- `zig-test` - Run tests
- `zig-format` - Format code
- `zig-debug` - Build debug version
- `zig-release` - Build optimized release

### Julia Environment

Features:
- **Julia** with scientific computing libraries
- **System Dependencies**: gcc, gfortran, openblas, lapack
- **Graphics**: cairo, pango for plotting
- **Notebook**: Jupyter with Julia kernel
- **Documentation**: pandoc

Available commands:
- `julia-init` - Initialize new Julia project
- `julia-install` - Install dependencies
- `julia-test` - Run tests
- `julia-repl` - Start Julia REPL
- `julia-notebook` - Start Jupyter notebook
- `julia-add <pkg>` - Add package
- `julia-status` - Show package status

## Configuration

### Flake Integration

The devenv configuration is integrated with flake-parts in `modules/flake/devenvs/`:

- `default.nix` - Main configuration and default shell
- `python.nix` - Python-specific environment
- `rust.nix` - Rust-specific environment
- `zig.nix` - Zig-specific environment
- `julia.nix` - Julia-specific environment

### Shared Package Architecture

The development environments now use a shared package architecture to eliminate duplication:

- **Shared packages** are defined in `modules/flake/lib/packages.nix`
- **Common tools** (git, direnv, formatters, etc.) are shared across all environments
- **Language-specific packages** are added on top of the common base
- **Single source of truth** for all development dependencies

### Binary Cache

The flake is configured to use the devenv binary cache for faster builds:

```nix
nixConfig = {
  extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
  extra-substituters = "https://devenv.cachix.org";
};
```

## Troubleshooting

### Pure Evaluation Error

If you get pure evaluation errors, use the `--no-pure-eval` flag:

```bash
nix develop --no-pure-eval
```

This is required because devenv needs to query the working directory.

### Container Support

Container support is currently disabled in all environments for simplicity. This can be enabled later by setting `containers.enable = true` in the respective shell configurations.

### Path Issues

The devenv configuration automatically detects the flake root. If you encounter path-related issues, ensure you're running commands from the repository root.

## GitHub Actions Integration

For CI/CD, you can use the devenv environments in GitHub Actions:

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: cachix/install-nix-action@v26
  - uses: cachix/cachix-action@v14
    with:
      name: devenv
  - name: Install devenv
    run: nix profile install nixpkgs#devenv
  - name: Build and test
    run: devenv shell python py-test
```

## Further Reading

- [devenv Documentation](https://devenv.sh/)
- [Using devenv with Flakes](https://devenv.sh/guides/using-with-flakes/)
- [Using devenv with flake-parts](https://devenv.sh/guides/using-with-flake-parts/)
- [devenv Reference Options](https://devenv.sh/reference/options/)
- [devenv GitHub Actions Integration](https://devenv.sh/integrations/github-actions/)
