#!/usr/bin/env bash
# Cache management script for nix-blazar
# Provides advanced cache operations and monitoring

set -euo pipefail

# Configuration
CACHE_NAME="nix-blazar"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v nix &> /dev/null; then
        missing_deps+=("nix")
    fi
    
    if ! command -v cachix &> /dev/null; then
        missing_deps+=("cachix")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Install missing dependencies and try again"
        exit 1
    fi
}

# Check if we're in the project root
check_project_root() {
    if [[ ! -f "$PROJECT_ROOT/flake.nix" ]]; then
        log_error "Not in project root or flake.nix not found"
        exit 1
    fi
}

# Get cache authentication status
check_cache_auth() {
    if cachix authtoken --help &> /dev/null; then
        if cachix authtoken 2>&1 | grep -q "not authenticated"; then
            return 1
        else
            return 0
        fi
    else
        return 1
    fi
}

# Setup cache
setup_cache() {
    log_info "Setting up Cachix cache: $CACHE_NAME"
    
    if ! check_cache_auth; then
        log_warning "Not authenticated with Cachix"
        log_info "Please run: cachix authtoken <your-token>"
        log_info "Or configure authentication via sops-nix secrets"
        return 1
    fi
    
    # Create cache if it doesn't exist
    if ! cachix info "$CACHE_NAME" &> /dev/null; then
        log_info "Creating cache: $CACHE_NAME"
        cachix create "$CACHE_NAME"
        log_success "Cache created successfully"
    else
        log_info "Cache already exists: $CACHE_NAME"
    fi
    
    # Configure cache usage
    cachix use "$CACHE_NAME"
    log_success "Cache configured for use"
}

# Build and push packages
push_packages() {
    log_info "Building and pushing custom packages..."
    
    cd "$PROJECT_ROOT"
    
    if nix eval --json .#packages.x86_64-linux &> /dev/null; then
        local packages
        packages=$(nix eval --json .#packages.x86_64-linux | jq -r 'keys[]')
        
        for package in $packages; do
            log_info "Building package: $package"
            if nix build ".#packages.x86_64-linux.$package" --print-build-logs; then
                log_info "Pushing $package to cache..."
                cachix push "$CACHE_NAME" result
                log_success "Package $package cached successfully"
            else
                log_error "Failed to build package: $package"
            fi
        done
    else
        log_warning "No custom packages found"
    fi
}

# Build and push development shells
push_devshells() {
    log_info "Building and pushing development shells..."
    
    cd "$PROJECT_ROOT"
    
    # Default shell
    log_info "Building default devShell..."
    if nix develop --command true; then
        log_success "Default devShell cached"
    else
        log_error "Failed to build default devShell"
    fi
    
    # Language-specific shells
    local shells=("python" "rust" "zig" "julia")
    for shell in "${shells[@]}"; do
        log_info "Building $shell devShell..."
        if nix develop ".#$shell" --command true; then
            log_success "$shell devShell cached"
        else
            log_warning "Failed to build $shell devShell (may not exist)"
        fi
    done
}

# Build and push system configurations
push_system() {
    log_info "Building and pushing system configurations..."
    
    cd "$PROJECT_ROOT"
    
    if nix eval --json .#nixosConfigurations &> /dev/null; then
        local configs
        configs=$(nix eval --json .#nixosConfigurations | jq -r 'keys[]')
        
        for config in $configs; do
            log_info "Building system configuration: $config"
            if nix build ".#nixosConfigurations.$config.config.system.build.toplevel" --print-build-logs; then
                log_info "Pushing $config to cache..."
                cachix push "$CACHE_NAME" result
                log_success "System $config cached successfully"
            else
                log_error "Failed to build system: $config"
            fi
        done
    else
        log_warning "No NixOS configurations found"
    fi
}

# Show cache statistics
show_stats() {
    log_info "Cache statistics for $CACHE_NAME:"
    
    if cachix info "$CACHE_NAME" &> /dev/null; then
        cachix info "$CACHE_NAME"
    else
        log_error "Cache not found or not accessible: $CACHE_NAME"
    fi
}

# Clean old cache entries (if supported)
clean_cache() {
    log_warning "Cache cleaning is not directly supported by Cachix"
    log_info "Cache entries are automatically managed by Cachix"
    log_info "Old entries are cleaned up based on your plan's retention policy"
}

# Show help
show_help() {
    cat << EOF
Cache Manager for nix-blazar

Usage: $0 <command>

Commands:
    setup           Setup and configure the cache
    push-packages   Build and push custom packages
    push-devshells  Build and push development shells
    push-system     Build and push system configurations
    push-all        Push everything to cache
    stats           Show cache statistics
    clean           Information about cache cleaning
    help            Show this help message

Examples:
    $0 setup                # Initial cache setup
    $0 push-all            # Push everything to cache
    $0 stats               # Show cache statistics

Environment Variables:
    CACHE_NAME             Override cache name (default: nix-blazar)

EOF
}

# Main function
main() {
    local command="${1:-help}"
    
    case "$command" in
        setup)
            check_dependencies
            check_project_root
            setup_cache
            ;;
        push-packages)
            check_dependencies
            check_project_root
            push_packages
            ;;
        push-devshells)
            check_dependencies
            check_project_root
            push_devshells
            ;;
        push-system)
            check_dependencies
            check_project_root
            push_system
            ;;
        push-all)
            check_dependencies
            check_project_root
            push_packages
            push_devshells
            push_system
            log_success "All builds pushed to cache!"
            ;;
        stats)
            check_dependencies
            show_stats
            ;;
        clean)
            clean_cache
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
