#!/usr/bin/env bash
# Claude Code PostToolUse Hook: Run Tests
#
# This hook runs appropriate tests after Claude makes changes to ensure
# that modifications don't break existing functionality.
#
# Usage: This script is called automatically after Claude uses editing tools.

set -euo pipefail

# Configuration
MAX_TEST_TIME=300  # Maximum time to run tests (5 minutes)
QUICK_TEST_TIME=60 # Time limit for quick tests (1 minute)

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[Claude Test Runner]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[Claude Test Runner]${NC} $1" >&2
}

error() {
    echo -e "${RED}[Claude Test Runner]${NC} $1" >&2
}

info() {
    echo -e "${BLUE}[Claude Test Runner]${NC} $1" >&2
}

# Function to run command with timeout
run_with_timeout() {
    local timeout_duration="$1"
    shift
    local cmd=("$@")
    
    info "Running: ${cmd[*]}"
    info "Timeout: ${timeout_duration}s"
    
    if timeout "$timeout_duration" "${cmd[@]}"; then
        return 0
    else
        local exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            warn "Command timed out after ${timeout_duration}s"
        else
            warn "Command failed with exit code $exit_code"
        fi
        return $exit_code
    fi
}

# Function to detect and run Node.js tests
run_nodejs_tests() {
    if [[ ! -f "package.json" ]]; then
        return 1
    fi
    
    log "Node.js project detected"
    
    # Check if there are test scripts defined
    if ! grep -q '"test"' package.json; then
        warn "No test script found in package.json"
        return 1
    fi
    
    # Determine package manager
    local pm_cmd
    if [[ -f "yarn.lock" ]]; then
        pm_cmd="yarn"
    elif [[ -f "pnpm-lock.yaml" ]]; then
        pm_cmd="pnpm"
    else
        pm_cmd="npm"
    fi
    
    # Run tests in devenv shell
    if [[ "${CLAUDE_QUICK_TESTS:-false}" == "true" ]]; then
        run_with_timeout "$QUICK_TEST_TIME" devenv shell -- "$pm_cmd" test -- --passWithNoTests --bail
    else
        run_with_timeout "$MAX_TEST_TIME" devenv shell -- "$pm_cmd" test
    fi
}

# Function to detect and run Rust tests
run_rust_tests() {
    if [[ ! -f "Cargo.toml" ]]; then
        return 1
    fi
    
    log "Rust project detected"
    
    # Run tests in devenv shell
    if [[ "${CLAUDE_QUICK_TESTS:-false}" == "true" ]]; then
        run_with_timeout "$QUICK_TEST_TIME" devenv shell -- cargo test --quiet --lib
    else
        run_with_timeout "$MAX_TEST_TIME" devenv shell -- cargo test
    fi
}

# Function to detect and run Python tests
run_python_tests() {
    if [[ ! -f "pyproject.toml" ]] && [[ ! -f "setup.py" ]] && [[ ! -f "requirements.txt" ]]; then
        return 1
    fi
    
    log "Python project detected"
    
    # Try pytest first, then unittest
    if command -v pytest >/dev/null 2>&1 || devenv shell -- which pytest >/dev/null 2>&1; then
        if [[ "${CLAUDE_QUICK_TESTS:-false}" == "true" ]]; then
            run_with_timeout "$QUICK_TEST_TIME" devenv shell -- pytest --quiet --tb=short -x
        else
            run_with_timeout "$MAX_TEST_TIME" devenv shell -- pytest
        fi
    elif [[ -d "tests" ]] || find . -name "*test*.py" -type f | head -1 | grep -q .; then
        if [[ "${CLAUDE_QUICK_TESTS:-false}" == "true" ]]; then
            run_with_timeout "$QUICK_TEST_TIME" devenv shell -- python -m unittest discover -s . -p "*test*.py" --quiet
        else
            run_with_timeout "$MAX_TEST_TIME" devenv shell -- python -m unittest discover -s . -p "*test*.py"
        fi
    else
        warn "No Python test framework or test files found"
        return 1
    fi
}

# Function to detect and run Nix tests
run_nix_tests() {
    if [[ ! -f "flake.nix" ]]; then
        return 1
    fi
    
    log "Nix flake project detected"
    
    # Run flake check
    if [[ "${CLAUDE_QUICK_TESTS:-false}" == "true" ]]; then
        run_with_timeout "$QUICK_TEST_TIME" devenv shell -- nix flake check --no-build
    else
        run_with_timeout "$MAX_TEST_TIME" devenv shell -- nix flake check
    fi
}

# Function to detect and run Go tests
run_go_tests() {
    if [[ ! -f "go.mod" ]]; then
        return 1
    fi
    
    log "Go project detected"
    
    # Run Go tests
    if [[ "${CLAUDE_QUICK_TESTS:-false}" == "true" ]]; then
        run_with_timeout "$QUICK_TEST_TIME" devenv shell -- go test -short ./...
    else
        run_with_timeout "$MAX_TEST_TIME" devenv shell -- go test ./...
    fi
}

# Function to run custom test script
run_custom_tests() {
    local test_scripts=("test.sh" "run-tests.sh" "scripts/test.sh" "bin/test")
    
    for script in "${test_scripts[@]}"; do
        if [[ -x "$script" ]]; then
            log "Custom test script found: $script"
            run_with_timeout "$MAX_TEST_TIME" devenv shell -- "./$script"
            return $?
        fi
    done
    
    return 1
}

# Function to run linting/formatting checks
run_quality_checks() {
    log "Running code quality checks..."
    
    local checks_run=false
    
    # Run pre-commit hooks if available
    if [[ -f ".pre-commit-config.yaml" ]] && command -v pre-commit >/dev/null 2>&1; then
        info "Running pre-commit hooks..."
        if devenv shell -- pre-commit run --all-files; then
            log "✅ Pre-commit hooks passed"
        else
            warn "⚠️  Pre-commit hooks found issues (non-blocking)"
        fi
        checks_run=true
    fi
    
    # Run language-specific linting
    if [[ -f "package.json" ]] && grep -q '"lint"' package.json; then
        info "Running JavaScript/TypeScript linting..."
        local pm_cmd
        if [[ -f "yarn.lock" ]]; then
            pm_cmd="yarn"
        else
            pm_cmd="npm"
        fi
        
        if devenv shell -- "$pm_cmd" run lint; then
            log "✅ Linting passed"
        else
            warn "⚠️  Linting found issues (non-blocking)"
        fi
        checks_run=true
    fi
    
    # Run Rust clippy if available
    if [[ -f "Cargo.toml" ]]; then
        info "Running Rust clippy..."
        if devenv shell -- cargo clippy -- -D warnings; then
            log "✅ Clippy passed"
        else
            warn "⚠️  Clippy found issues (non-blocking)"
        fi
        checks_run=true
    fi
    
    if [[ "$checks_run" == "false" ]]; then
        info "No quality checks configured"
    fi
}

# Main test execution logic
main() {
    log "Starting post-edit test execution..."
    
    # Check if we're in a devenv project
    if [[ ! -f "devenv.nix" ]] && [[ ! -f ".envrc" ]]; then
        warn "Not in a devenv project, skipping tests"
        exit 0
    fi
    
    # Get information about what files were modified
    local modified_files="${CLAUDE_MODIFIED_FILES:-}"
    if [[ -n "$modified_files" ]]; then
        info "Modified files: $modified_files"
    fi
    
    # Check if tests should be skipped
    if [[ "${CLAUDE_SKIP_TESTS:-false}" == "true" ]]; then
        info "Tests skipped (CLAUDE_SKIP_TESTS=true)"
        exit 0
    fi
    
    # Set quick test mode if requested or if many files were modified
    if [[ "${CLAUDE_QUICK_TESTS:-}" == "" ]]; then
        # Auto-enable quick tests if many files were modified
        local file_count
        file_count=$(echo "$modified_files" | wc -w)
        if [[ $file_count -gt 5 ]]; then
            export CLAUDE_QUICK_TESTS=true
            info "Auto-enabling quick test mode (many files modified)"
        fi
    fi
    
    # Track test results
    local test_results=()
    local overall_success=true
    
    # Try to run tests for detected project types
    local test_runners=(
        "run_nodejs_tests"
        "run_rust_tests"
        "run_python_tests"
        "run_go_tests"
        "run_nix_tests"
        "run_custom_tests"
    )
    
    local tests_run=false
    for runner in "${test_runners[@]}"; do
        if $runner; then
            test_results+=("$runner: ✅ PASSED")
            tests_run=true
            log "✅ Tests passed for $runner"
        else
            local exit_code=$?
            if [[ $exit_code -ne 1 ]]; then  # 1 means "not applicable", other codes are failures
                test_results+=("$runner: ❌ FAILED")
                overall_success=false
                error "❌ Tests failed for $runner"
            fi
        fi
    done
    
    # Run quality checks (non-blocking)
    run_quality_checks
    
    # Report results
    if [[ "$tests_run" == "false" ]]; then
        warn "No tests were run (no test configuration found)"
        info "Consider adding tests to improve code quality"
    else
        log "Test execution completed"
        for result in "${test_results[@]}"; do
            info "$result"
        done
        
        if [[ "$overall_success" == "true" ]]; then
            log "🎉 All tests passed!"
        else
            error "💥 Some tests failed!"
            if [[ "${CLAUDE_FAIL_ON_TEST_FAILURE:-false}" == "true" ]]; then
                error "Failing due to test failures (CLAUDE_FAIL_ON_TEST_FAILURE=true)"
                exit 1
            else
                warn "Continuing despite test failures (set CLAUDE_FAIL_ON_TEST_FAILURE=true to fail)"
            fi
        fi
    fi
    
    log "Post-edit validation complete"
    exit 0
}

# Handle script being sourced vs executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
