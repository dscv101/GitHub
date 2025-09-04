# nyx-fmt-fixed

Minimal flake with:

- **Working `nix fmt`** wrapper that formats/checks the repository root when no file paths are provided.
- A tiny `nixosConfigurations.blazar` that evaluates cleanly in CI.

## Usage

```sh
# enter dev shell
nix develop -c $SHELL

# format the repo (in place)
nix fmt

# check formatting without modifying files (CI-style)
nix fmt -- --check
```

## Notes

- The formatter is a small wrapper around `alejandra`. If you pass paths, those are used; if you pass only flags (like `--check`), it appends `.`.
