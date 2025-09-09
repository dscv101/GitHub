# GitHub Actions Workflows - Jujitsu & Nix

This document describes the GitHub Actions workflows for this repository, which are designed to work with Jujitsu SCM and follow NixOS/flake-parts patterns.

## Overview

The workflows have been completely rebuilt from scratch to support:
- **Jujitsu SCM** instead of Git for version control operations
- **NixOS flake-parts** patterns as required by organization rules
- **Security-first** approach with minimal permissions
- **Multi-system** builds and testing
- **Comprehensive** validation and quality checks

## Workflow Files

### 1. CI Workflow (`ci.yml`)

**Purpose**: Core continuous integration with Jujitsu and Nix validation

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests
- Manual dispatch

**Key Features**:
- Jujitsu SCM setup and validation
- Nix flake health checking with flake-parts compliance
- Formatting and linting (alejandra, statix, deadnix)
- Development shell validation
- Comprehensive CI summary

**Jobs**:
1. `jujitsu-setup` - Install and configure Jujitsu SCM
2. `nix-validation` - Validate flake structure and compliance
3. `nix-formatting` - Check Nix code formatting and linting
4. `dev-shell-validation` - Test development shells
5. `nix-checks` - Run flake checks
6. `ci-summary` - Provide comprehensive status summary

### 2. Build Workflow (`build.yml`)

**Purpose**: Multi-system builds and flake-parts compliance validation

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests
- Manual dispatch

**Key Features**:
- Dynamic system detection from flake outputs
- Multi-system package builds
- Development shell builds across systems
- Flake-parts compliance validation
- Directory structure compliance checking

**Jobs**:
1. `detect-matrix` - Detect available systems and packages
2. `build-packages` - Build packages across systems
3. `build-devshells` - Build development shells
4. `system-checks` - Run system-specific checks
5. `flake-parts-compliance` - Validate organization compliance
6. `build-summary` - Provide build status summary

### 3. Security Workflow (`security.yml`)

**Purpose**: Security scanning adapted for Jujitsu SCM and Nix

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests
- Daily schedule (2 AM UTC)
- Manual dispatch

**Key Features**:
- CodeQL analysis for Nix code
- Nix-specific security pattern scanning
- Flake input security validation
- Jujitsu repository integrity checks
- OSSF Scorecard integration

**Jobs**:
1. `codeql-analysis` - Static code analysis
2. `nix-security-scan` - Nix-specific security checks
3. `dependency-scan` - Dependency vulnerability scanning
4. `jujitsu-security` - Jujitsu repository security validation
5. `scorecard` - OSSF Scorecard analysis
6. `security-summary` - Security status summary

### 4. Dependencies Workflow (`dependencies.yml`)

**Purpose**: Nix flake dependency management and updates

**Triggers**:
- Weekly schedule (Sundays at 3 AM UTC)
- Manual dispatch with options

**Key Features**:
- Automated flake input updates
- Jujitsu-based commit and PR creation
- Dependency health monitoring
- Security update detection
- Comprehensive validation before updates

**Manual Dispatch Options**:
- `update_type`: all, nixpkgs, inputs, security
- `create_pr`: Create PR for updates (boolean)

**Jobs**:
1. `analyze-dependencies` - Analyze current dependency state
2. `update-inputs` - Update flake inputs using Jujitsu
3. `dependency-health` - Check dependency health metrics
4. `dependencies-summary` - Dependency status summary

### 5. Development Workflow (`development.yml`)

**Purpose**: Development shell validation and testing

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests
- Manual dispatch

**Key Features**:
- Development shell detection and validation
- Multi-system shell testing
- Jujitsu workflow integration testing
- Tool availability validation
- Reproducibility testing

**Jobs**:
1. `validate-devshells` - Detect and validate development shells
2. `test-devshells` - Test shells across systems
3. `test-dev-workflows` - Test development workflows with Jujitsu
4. `validate-dev-consistency` - Check environment consistency
5. `development-summary` - Development status summary

## Key Differences from Git-based Workflows

### Jujitsu SCM Integration

1. **Installation**: Each workflow installs Jujitsu via Rust/Cargo
2. **Configuration**: Sets up Jujitsu user configuration
3. **Repository Operations**: Uses `jj` commands instead of `git`
4. **Co-location**: Initializes co-located repositories when needed

### Nix/Flake-parts Focus

1. **Organization Compliance**: Validates flake-parts usage
2. **Directory Structure**: Checks for required directories (modules/, systems/, home/, etc.)
3. **perSystem Usage**: Validates perSystem patterns for devShells and checks
4. **Multi-system**: Supports building across multiple systems

### Security Enhancements

1. **Minimal Permissions**: Each job has explicit, minimal permissions
2. **Nix Sandboxing**: Uses secure Nix evaluation settings
3. **Input Validation**: Validates flake inputs for security
4. **Secret Scanning**: Checks for potential secrets in Nix files

## Usage Examples

### Running Workflows Locally

Since these workflows use Jujitsu, you can test similar operations locally:

```bash
# Install Jujitsu
cargo install --locked jj-cli

# Configure Jujitsu
jj config set --user user.name "Your Name"
jj config set --user user.email "your.email@domain.com"

# Initialize co-located repository
jj git init --colocate

# Test Nix operations
nix flake check
nix develop
nix build
```

### Manual Dependency Updates

```bash
# Trigger dependency update workflow
gh workflow run dependencies.yml \
  -f update_type=all \
  -f create_pr=true
```

### Development Shell Testing

```bash
# Test development shell locally
nix develop --command bash -c "
  echo 'Testing development environment...'
  jj status
  nix flake check --no-build
"
```

## Troubleshooting

### Common Issues

1. **Jujitsu Installation Failures**
   - Check Rust installation
   - Verify cargo is in PATH
   - Try manual installation

2. **Flake-parts Compliance Failures**
   - Ensure flake.nix uses flake-parts
   - Check for perSystem usage
   - Validate directory structure

3. **Development Shell Issues**
   - Verify devShells are defined in perSystem
   - Check tool availability in shells
   - Test shell reproducibility

### Debugging Workflows

1. **Enable Debug Logging**:
   - Set `JJ_LOG=debug` for Jujitsu operations
   - Use `--print-build-logs` for Nix builds

2. **Check Workflow Logs**:
   - Review job summaries for quick status
   - Examine individual step logs for details
   - Look for security scan results

3. **Local Testing**:
   - Run equivalent commands locally
   - Test with same Nix and Jujitsu versions
   - Validate flake structure manually

## Organization Compliance

These workflows enforce the following organization rules:

1. **Flake-parts Usage**: Required for all Nix flakes
2. **Directory Structure**: modules/, systems/, home/, overlays/, docs/
3. **perSystem Patterns**: devShells and checks in perSystem
4. **Security Standards**: Encrypted secrets, secure inputs
5. **Development Standards**: Formatting, linting, documentation

## Maintenance

### Updating Workflows

1. **Version Updates**: Update action versions regularly
2. **Security Patches**: Monitor for security updates
3. **Tool Updates**: Keep Jujitsu and Nix tools current
4. **Compliance Changes**: Adapt to organization rule changes

### Monitoring

1. **Workflow Status**: Monitor workflow success rates
2. **Performance**: Track build times and resource usage
3. **Security Alerts**: Review security scan results
4. **Dependency Health**: Monitor dependency update frequency

## Migration Notes

This represents a complete rebuild of the GitHub Actions infrastructure:

- **Removed**: All previous Git-based workflows
- **Added**: Jujitsu SCM support throughout
- **Enhanced**: Security scanning and compliance validation
- **Improved**: Multi-system builds and testing
- **Standardized**: Organization rule compliance

The new workflows provide better security, compliance, and functionality while supporting the unique requirements of Jujitsu SCM and NixOS patterns.
