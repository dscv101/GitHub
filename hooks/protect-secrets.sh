#!/usr/bin/env bash
# Claude Code PreToolUse Hook: Protect Secrets
#
# This hook prevents Claude from editing sensitive files that might contain
# secrets, API keys, or other confidential information.
#
# Usage: This script is called automatically before Claude uses file editing tools.

set -euo pipefail

# Configuration - Removed overly broad patterns that cause false positives
PROTECTED_PATTERNS=(
	"*.env"
	"*.env.*"
	"*.secret"
	"*.secrets"
	"*.key"
	"*.pem"
	"*.p12"
	"*.pfx"
	"*.crt"
	"*.cer"
	"*.der"
	"*_rsa"
	"*_dsa"
	"*_ecdsa"
	"*_ed25519"
	".ssh/id_*"
	".ssh/known_hosts"
	".aws/credentials"
	".aws/config"
	".docker/config.json"
	"secrets.yaml"
	"secrets.yml"
	"vault.yaml"
	"vault.yml"
	".sops.yaml"
	".age"
	"*.age"
	# Removed broad patterns like "*password*", "*secret*" etc. that cause false positives
)

PROTECTED_DIRECTORIES=(
	".ssh"
	".gnupg"
	".aws"
	".docker"
	"secrets"
	"vault"
	".vault"
	"keys"
	".keys"
)

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Logging function
log() {
	echo -e "${GREEN}[protect-secrets]${NC} $1" >&2
}

warn() {
	echo -e "${YELLOW}[protect-secrets]${NC} $1" >&2
}

error() {
	echo -e "${RED}[protect-secrets]${NC} $1" >&2
}

# Function to check if a file path matches protected patterns
is_protected_file() {
	local file_path="$1"
	local basename_file
	basename_file=$(basename "$file_path")

    # Check against protected patterns using case for glob matching.
    # Intentionally allow dynamic glob patterns from PROTECTED_PATTERNS.
    for pattern in "${PROTECTED_PATTERNS[@]}"; do
        # shellcheck disable=SC2254  # Intentional glob expansion of pattern
        case "$basename_file" in
            $pattern)
                return 0 ;; # File is protected
        esac
        # Also match full path to support patterns with directories (e.g., .ssh/id_*)
        # shellcheck disable=SC2254  # Intentional glob expansion of pattern
        case "$file_path" in
            *$pattern)
                return 0 ;;
        esac
    done

	# Check if file is in a protected directory
	for dir in "${PROTECTED_DIRECTORIES[@]}"; do
		if [[ "$file_path" == *"/$dir/"* ]] || [[ "$file_path" == "$dir/"* ]]; then
			return 0 # File is in protected directory
		fi
	done

	return 1 # File is not protected
}

# Function to check file content for potential secrets
check_file_content() {
	local file_path="$1"

	# Skip if file doesn't exist or is not readable
	if [[ ! -f "$file_path" ]] || [[ ! -r "$file_path" ]]; then
		return 1
	fi

	# Patterns that might indicate secrets in file content
	local secret_patterns=(
		"password\s*[:=]\s*['\"][^'\"]{8,}['\"]"
		"api[_-]?key\s*[:=]\s*['\"][^'\"]{16,}['\"]"
		"secret\s*[:=]\s*['\"][^'\"]{16,}['\"]"
		"token\s*[:=]\s*['\"][^'\"]{20,}['\"]"
		"private[_-]?key"
		"BEGIN\s+(RSA\s+)?PRIVATE\s+KEY"
		"BEGIN\s+CERTIFICATE"
		"ssh-rsa\s+AAAA"
		"ssh-ed25519\s+AAAA"
	)

	# Check first 50 lines for secret patterns (avoid scanning large files)
	local content
	content=$(head -50 "$file_path" 2>/dev/null || true)

	for pattern in "${secret_patterns[@]}"; do
		if echo "$content" | grep -iE "$pattern" >/dev/null 2>&1; then
			return 0 # Potential secret found
		fi
	done

	return 1 # No secrets detected
}

# Main protection logic
main() {
	log "Claude Code Secret Protection v2.0.1"

	# Get the file path from Claude tool arguments or command line
	local file_path=""

	# Try to extract file path from various possible sources
	if [[ -n "${CLAUDE_TOOL_ARGS:-}" ]]; then
		# Parse JSON tool arguments if available
		if command -v jq >/dev/null 2>&1; then
			file_path=$(echo "$CLAUDE_TOOL_ARGS" | jq -r '.file_path // .path // .filename // empty' 2>/dev/null || true)
		fi
	fi

	# Fallback: check command line arguments
	if [[ -z "$file_path" ]] && [[ $# -gt 0 ]]; then
		file_path="$1"
	fi

	# If we still don't have a file path, check environment variables
	if [[ -z "$file_path" ]]; then
		file_path="${CLAUDE_FILE_PATH:-${CLAUDE_TARGET_FILE:-}}"
	fi

	# If no file path is provided, allow the operation (might not be a file operation)
	if [[ -z "$file_path" ]]; then
		log "No file path detected, allowing operation"
		exit 0
	fi

	log "Checking file: $file_path"

	# Check if the file path matches protected patterns
	if is_protected_file "$file_path"; then
		error "🚫 BLOCKED: Attempt to edit protected file: $file_path"
		error "   This file appears to contain sensitive information."
		error "   Protected patterns include: *.env, *.secret, *.key, *.pem, etc."
		error "   If this is a false positive, you can:"
		error "   1. Rename the file to avoid protected patterns"
		error "   2. Move it outside protected directories"
		error "   3. Disable this hook temporarily"
		exit 1
	fi

	# Check file content for potential secrets (if file exists)
	if [[ -f "$file_path" ]] && check_file_content "$file_path"; then
		warn "⚠️  WARNING: File may contain sensitive information: $file_path"
		warn "   Detected potential secrets in file content."

		# In strict mode, block the operation
		if [[ "${CLAUDE_SECRETS_STRICT_MODE:-false}" == "true" ]]; then
			error "🚫 BLOCKED: Strict mode enabled, blocking potential secret file"
			exit 1
		else
			warn "   Allowing operation (strict mode disabled)"
			warn "   Set CLAUDE_SECRETS_STRICT_MODE=true to block these files"
		fi
	fi

	log "✅ File access allowed: $file_path"
	exit 0
}

# Handle script being sourced vs executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
