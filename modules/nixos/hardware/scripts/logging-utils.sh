#!/usr/bin/env bash
# Logging utilities for bootloader cleanup operations
# Provides structured logging with different levels and dry-run support

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Log levels
readonly LOG_ERROR=0
readonly LOG_WARN=1
readonly LOG_INFO=2
readonly LOG_DEBUG=3

# Current log level (can be overridden by VERBOSE setting)
LOG_LEVEL=${LOG_LEVEL:-$LOG_INFO}

# Set log level based on VERBOSE setting
if [[ "${VERBOSE:-false}" == "true" ]]; then
  LOG_LEVEL=$LOG_DEBUG
fi

# Timestamp function
timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

# Generic logging function
log() {
  local level=$1
  local color=$2
  local prefix=$3
  shift 3
  local message="$*"

  if [[ $level -le $LOG_LEVEL ]]; then
    echo -e "${color}[$(timestamp)] ${prefix}:${NC} $message" >&2

    # Also log to systemd journal if available
    if command -v systemd-cat >/dev/null 2>&1; then
      echo "[$(timestamp)] ${prefix}: $message" | systemd-cat -t bootloader-cleanup -p "$prefix"
    fi
  fi
}

# Specific logging functions
log_error() {
  log $LOG_ERROR "$RED" "ERROR" "$@"
}

log_warn() {
  log $LOG_WARN "$YELLOW" "WARN" "$@"
}

log_info() {
  log $LOG_INFO "$GREEN" "INFO" "$@"
}

log_debug() {
  log $LOG_DEBUG "$BLUE" "DEBUG" "$@"
}

# Special logging for dry-run operations
log_dry_run() {
  log $LOG_INFO "$PURPLE" "DRY-RUN" "$@"
}

# Log command execution (with dry-run support)
log_exec() {
  local cmd="$*"

  if [[ "${DRY_RUN:-true}" == "true" ]]; then
    log_dry_run "Would execute: $cmd"
    return 0
  else
    log_debug "Executing: $cmd"
    if eval "$cmd"; then
      log_debug "Command succeeded: $cmd"
      return 0
    else
      local exit_code=$?
      log_error "Command failed with exit code $exit_code: $cmd"
      return $exit_code
    fi
  fi
}

# Log file operations (with dry-run support)
log_file_op() {
  local operation=$1
  local file=$2
  local extra_info=${3:-""}

  if [[ "${DRY_RUN:-true}" == "true" ]]; then
    log_dry_run "Would $operation: $file $extra_info"
  else
    log_info "$operation: $file $extra_info"
  fi
}

# Progress indicator for long operations
show_progress() {
  local current=$1
  local total=$2
  local operation=${3:-"Processing"}

  local percent=$((current * 100 / total))
  local bar_length=20
  local filled_length=$((percent * bar_length / 100))

  local bar=""
  for ((i = 0; i < filled_length; i++)); do
    bar+="█"
  done
  for ((i = filled_length; i < bar_length; i++)); do
    bar+="░"
  done

  printf "\r${CYAN}%s: [%s] %d%% (%d/%d)${NC}" "$operation" "$bar" "$percent" "$current" "$total"

  if [[ $current -eq $total ]]; then
    echo # New line when complete
  fi
}

# Create a log section separator
log_section() {
  local title="$1"
  local width=60
  local padding=$(((width - ${#title} - 2) / 2))

  local separator=""
  for ((i = 0; i < width; i++)); do
    separator+="="
  done

  local padded_title=""
  for ((i = 0; i < padding; i++)); do
    padded_title+=" "
  done
  padded_title+="$title"
  for ((i = 0; i < padding; i++)); do
    padded_title+=" "
  done

  log_info "$separator"
  log_info "$padded_title"
  log_info "$separator"
}

# Log system information
log_system_info() {
  log_section "System Information"
  log_info "Hostname: $(hostname)"
  log_info "Kernel: $(uname -r)"
  log_info "Architecture: $(uname -m)"
  log_info "Boot mode: $([ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS")"
  log_info "Current user: $(whoami)"
  log_info "Working directory: $(pwd)"

  if [[ -f /proc/cmdline ]]; then
    log_debug "Kernel command line: $(cat /proc/cmdline)"
  fi
}

# Log cleanup summary
log_cleanup_summary() {
  local operations_performed=$1
  local files_removed=$2
  local errors_encountered=$3

  log_section "Cleanup Summary"
  log_info "Operations performed: $operations_performed"
  log_info "Files removed: $files_removed"

  if [[ $errors_encountered -gt 0 ]]; then
    log_warn "Errors encountered: $errors_encountered"
  else
    log_info "No errors encountered"
  fi

  if [[ "${DRY_RUN:-true}" == "true" ]]; then
    log_info "This was a dry run - no actual changes were made"
  fi
}

# Backup logging
log_backup_created() {
  local backup_path=$1
  local original_path=$2

  log_info "Backup created: $original_path -> $backup_path"
}

# Error recovery logging
log_recovery_attempt() {
  local operation=$1
  local attempt=$2
  local max_attempts=$3

  log_warn "Recovery attempt $attempt/$max_attempts for: $operation"
}

# Export functions for use in other scripts
export -f timestamp log log_error log_warn log_info log_debug log_dry_run
export -f log_exec log_file_op show_progress log_section log_system_info
export -f log_cleanup_summary log_backup_created log_recovery_attempt
