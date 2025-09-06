#!/usr/bin/env bash
# Claude Code PreToolUse Hook: Protect Secrets
#
# This hook prevents Claude from editing sensitive files that might contain
# secrets, API keys, or other confidential information.
#
# Usage: This script is called automatically before Claude uses file editing tools.

set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="protect-secrets"
readonly SCRIPT_VERSION="2.0.0"

# Configuration - Enhanced patterns with more comprehensive coverage
readonly PROTECTED_PATTERNS=(
	# Environment and config files
	"*.env"
	"*.env.*"
	"*.environment"
	".env*"
	
	# Secret files
	"*.secret"
	"*.secrets"
	"secrets.*"
	
	# Cryptographic keys and certificates
	"*.key"
	"*.pem"
	"*.p12"
	"*.pfx"
	"*.crt"
	"*.cer"
	"*.der"
	"*.csr"
	"*.p7b"
	"*.p7c"
	"*.spc"
	"*.keystore"
	"*.jks"
	"*.truststore"
	
	# SSH keys
	"*_rsa"
	"*_dsa"
	"*_ecdsa"
	"*_ed25519"
	"id_*"
	"*.pub"
	
	# Cloud provider credentials
	".aws/credentials"
	".aws/config"
	".azure/credentials"
	".gcloud/credentials"
	"gcp-credentials.json"
	"service-account*.json"
	
	# Container and orchestration secrets
	".docker/config.json"
	".dockercfg"
	"kubeconfig"
	"*.kubeconfig"
	
	# Application secrets
	"secrets.yaml"
	"secrets.yml"
	"vault.yaml"
	"vault.yml"
	"*.vault"
	".sops.yaml"
	".sops.yml"
	".age"
	"*.age"
	
	# Database credentials
	".pgpass"
	".my.cnf"
	"database.yml"
	
	# CI/CD secrets
	".travis.yml"
	".github/secrets"
	"gitlab-ci.yml"
	
	# Password managers and keychains
	"*.kdbx"
	"*.kdb"
	"login.keychain*"
	
	# Terraform and infrastructure
	"terraform.tfvars"
	"*.tfvars"
	".terraform/terraform.tfstate"
	
	# Application-specific
	"*password*"
	"*credential*"
	"*apikey*"
	"*api_key*"
	"*token*"
	"*bearer*"
)

readonly PROTECTED_DIRECTORIES=(
	".ssh"
	".gnupg"
	".gpg"
	".aws"
	".azure"
	".gcloud"
	".docker"
	"secrets"
	"vault"
	".vault"
	"keys"
	".keys"
	"certificates"
	".certificates"
	"credentials"
	".credentials"
	"private"
	".private"
)

# Enhanced secret content patterns with better regex
readonly SECRET_CONTENT_PATTERNS=(
	# Generic secrets
	'(password|pwd|pass)\s*[:=]\s*["\047][^"\047]{8,}["\047]'
	'(api[_-]?key|apikey)\s*[:=]\s*["\047][A-Za-z0-9+/]{16,}["\047]'
	'(secret|token)\s*[:=]\s*["\047][A-Za-z0-9+/=]{16,}["\047]'
	'(access[_-]?token|accesstoken)\s*[:=]\s*["\047][A-Za-z0-9+/=]{20,}["\047]'
	
	# Cloud provider patterns
	'AKIA[0-9A-Z]{16}'  # AWS Access Key
	'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'  # UUID format
	'sk-[A-Za-z0-9]{48}'  # OpenAI API key
	'ghp_[A-Za-z0-9]{36}'  # GitHub Personal Access Token
	'gho_[A-Za-z0-9]{36}'  # GitHub OAuth token
	'ghu_[A-Za-z0-9]{36}'  # GitHub user token
	'ghs_[A-Za-z0-9]{36}'  # GitHub server token
	'glpat-[A-Za-z0-9_-]{20}'  # GitLab Personal Access Token
	
	# Private keys
	'-----BEGIN [A-Z ]*PRIVATE KEY-----'
	'-----BEGIN CERTIFICATE-----'
	'-----BEGIN RSA PRIVATE KEY-----'
	'-----BEGIN OPENSSH PRIVATE KEY-----'
	
	# SSH keys
	'ssh-rsa AAAA[0-9A-Za-z+/]+'
	'ssh-ed25519 AAAA[0-9A-Za-z+/]+'
	'ssh-dss AAAA[0-9A-Za-z+/]+'
	
	# Database connection strings
	'(mongodb|mysql|postgresql|postgres|redis)://[^:]+:[^@]+@'
	'Server=[^;]+;.*Password=[^;]+'
)

# Colors for output
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration from environment
readonly CLAUDE_SECRETS_STRICT_MODE="${CLAUDE_SECRETS_STRICT_MODE:-false}"
readonly CLAUDE_SECRETS_MAX_FILE_SIZE="${CLAUDE_SECRETS_MAX_FILE_SIZE:-1048576}"  # 1MB
readonly CLAUDE_SECRETS_CONTENT_CHECK="${CLAUDE_SECRETS_CONTENT_CHECK:-true}"
readonly CLAUDE_SECRETS_LOG_LEVEL="${CLAUDE_SECRETS_LOG_LEVEL:-info}"  # debug, info, warn, error

# Logging functions with levels
debug() {
	[[ "$CLAUDE_SECRETS_LOG_LEVEL" == "debug" ]] && echo -e "${BLUE}[${SCRIPT_NAME}:DEBUG]${NC} $1" >&2
}

log() {
	[[ "$CLAUDE_SECRETS_LOG_LEVEL" =~ ^(debug|info)$ ]] && echo -e "${GREEN}[${SCRIPT_NAME}]${NC} $1" >&2
}

warn() {
	[[ "$CLAUDE_SECRETS_LOG_LEVEL" =~ ^(debug|info|warn)$ ]] && echo -e "${YELLOW}[${SCRIPT_NAME}:WARN]${NC} $1" >&2
}

error() {
	echo -e "${RED}[${SCRIPT_NAME}:ERROR]${NC} $1" >&2
}

# Enhanced file path normalization
normalize_path() {
	local path="$1"
	# Remove leading ./ and resolve basic path components
	path="${path#./}"
	echo "$path"
}

# Function to check if a file path matches protected patterns
is_protected_file() {
	local file_path
	file_path=$(normalize_path "$1")
	local basename_file
	basename_file=$(basename "$file_path")
	local dirname_file
	dirname_file=$(dirname "$file_path")

	debug "Checking protection patterns for: $file_path"

	# Check against protected patterns
	for pattern in "${PROTECTED_PATTERNS[@]}"; do
		# Use case-insensitive matching for better coverage
		if [[ "${basename_file,,}" == "${pattern,,}" ]] || [[ "${file_path,,}" == *"${pattern,,}"* ]]; then
			debug "Matched pattern: $pattern"
			return 0 # File is protected
		fi
	done

	# Check if file is in a protected directory
	for dir in "${PROTECTED_DIRECTORIES[@]}"; do
		if [[ "$file_path" == *"/$dir/"* ]] || [[ "$file_path" == "$dir/"* ]] || [[ "$dirname_file" == *"$dir"* ]]; then
			debug "Matched protected directory: $dir"
			return 0 # File is in protected directory
		fi
	done

	debug "No protection patterns matched"
	return 1 # File is not protected
}

# Enhanced function to check file content for potential secrets
check_file_content() {
	local file_path="$1"

	# Skip content checking if disabled
	if [[ "$CLAUDE_SECRETS_CONTENT_CHECK" != "true" ]]; then
		debug "Content checking disabled"
		return 1
	fi

	# Skip if file doesn't exist or is not readable
	if [[ ! -f "$file_path" ]] || [[ ! -r "$file_path" ]]; then
		debug "File not found or not readable: $file_path"
		return 1
	fi

	# Check file size to avoid scanning huge files
	local file_size
	file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null || echo "0")
	if [[ "$file_size" -gt "$CLAUDE_SECRETS_MAX_FILE_SIZE" ]]; then
		warn "File too large for content scanning ($file_size bytes): $file_path"
		return 1
	fi

	debug "Scanning file content for secrets: $file_path"

	# Read file content (limit to reasonable size)
	local content
	content=$(head -c "$CLAUDE_SECRETS_MAX_FILE_SIZE" "$file_path" 2>/dev/null || true)

	# Skip binary files
	if [[ -n "$content" ]] && file "$file_path" 2>/dev/null | grep -q "binary"; then
		debug "Skipping binary file: $file_path"
		return 1
	fi

	# Check against secret patterns
	for pattern in "${SECRET_CONTENT_PATTERNS[@]}"; do
		if echo "$content" | grep -iE "$pattern" >/dev/null 2>&1; then
			debug "Matched secret pattern: $pattern"
			return 0 # Potential secret found
		fi
	done

	debug "No secret patterns found in content"
	return 1 # No secrets detected
}

# Function to extract file path from various sources
extract_file_path() {
	local file_path=""

	# Try to extract file path from Claude tool arguments (JSON)
	if [[ -n "${CLAUDE_TOOL_ARGS:-}" ]]; then
		if command -v jq >/dev/null 2>&1; then
			file_path=$(echo "$CLAUDE_TOOL_ARGS" | jq -r '.file_path // .path // .filename // .target // empty' 2>/dev/null || true)
			debug "Extracted from CLAUDE_TOOL_ARGS: $file_path"
		fi
	fi

	# Fallback: check command line arguments
	if [[ -z "$file_path" ]] && [[ $# -gt 0 ]]; then
		file_path="$1"
		debug "Using command line argument: $file_path"
	fi

	# Fallback: check environment variables
	if [[ -z "$file_path" ]]; then
		file_path="${CLAUDE_FILE_PATH:-${CLAUDE_TARGET_FILE:-${CLAUDE_EDIT_FILE:-}}}"
		debug "Using environment variable: $file_path"
	fi

	echo "$file_path"
}

# Function to display help
show_help() {
	cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION - Claude Code Secret Protection Hook

USAGE:
    $0 [FILE_PATH]

DESCRIPTION:
    Protects sensitive files from being edited by Claude Code.
    Checks file paths and content for potential secrets.

ENVIRONMENT VARIABLES:
    CLAUDE_SECRETS_STRICT_MODE      Block files with potential secrets (default: false)
    CLAUDE_SECRETS_MAX_FILE_SIZE    Maximum file size to scan in bytes (default: 1MB)
    CLAUDE_SECRETS_CONTENT_CHECK    Enable content scanning (default: true)
    CLAUDE_SECRETS_LOG_LEVEL        Logging level: debug|info|warn|error (default: info)

EXAMPLES:
    $0 config.env                   # Check specific file
    CLAUDE_FILE_PATH=secret.key $0  # Check via environment variable
    echo '{"file_path": "api.key"}' | CLAUDE_TOOL_ARGS="\$(cat)" $0  # JSON args

EXIT CODES:
    0   File access allowed
    1   File access blocked
    2   Script error
EOF
}

# Main protection logic
main() {
	# Handle help flag
	if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
		show_help
		exit 0
	fi

	log "Claude Code Secret Protection v$SCRIPT_VERSION"
	debug "Configuration: strict_mode=$CLAUDE_SECRETS_STRICT_MODE, max_size=$CLAUDE_SECRETS_MAX_FILE_SIZE, content_check=$CLAUDE_SECRETS_CONTENT_CHECK"

	# Extract file path from various sources
	local file_path
	file_path=$(extract_file_path "$@")

	# If no file path is provided, allow the operation (might not be a file operation)
	if [[ -z "$file_path" ]]; then
		log "No file path detected, allowing operation"
		exit 0
	fi

	log "Checking file: $file_path"

	# Check if the file path matches protected patterns
	if is_protected_file "$file_path"; then
		error "BLOCKED: Attempt to edit protected file: $file_path"
		error "   This file matches protected patterns for sensitive information."
		error "   Protected patterns include: *.env, *.secret, *.key, *.pem, etc."
		error ""
		error "   To resolve this:"
		error "   1. Rename the file to avoid protected patterns"
		error "   2. Move it outside protected directories"
		error "   3. Set CLAUDE_SECRETS_STRICT_MODE=false to allow content-based files"
		error "   4. Disable this hook temporarily if needed"
		exit 1
	fi

	# Check file content for potential secrets (if file exists)
	if [[ -f "$file_path" ]] && check_file_content "$file_path"; then
		warn "WARNING: File may contain sensitive information: $file_path"
		warn "   Detected potential secrets in file content."
		
		# In strict mode, block the operation
		if [[ "$CLAUDE_SECRETS_STRICT_MODE" == "true" ]]; then
			error "BLOCKED: Strict mode enabled, blocking potential secret file"
			error "   Set CLAUDE_SECRETS_STRICT_MODE=false to allow with warnings"
			exit 1
		else
			warn "   Allowing operation (strict mode disabled)"
			warn "   Set CLAUDE_SECRETS_STRICT_MODE=true to block these files"
		fi
	fi

	log "File access allowed: $file_path"
	exit 0
}

# Error handling
trap 'error "Script failed at line $LINENO"; exit 2' ERR

# Handle script being sourced vs executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi
