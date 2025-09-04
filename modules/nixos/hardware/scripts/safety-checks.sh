#!/usr/bin/env bash
# Safety checks for bootloader cleanup operations
# Ensures system safety before performing destructive operations

# Global variables for tracking safety state
SAFETY_CHECKS_PASSED=false
BACKUP_DIRECTORY=""
CURRENT_BOOTLOADER=""
ACTIVE_BOOT_ENTRIES=()

# Perform comprehensive safety checks
perform_safety_checks() {
    local target_device="$1"
    
    log_section "Safety Checks"
    
    # Check if running as root
    check_root_privileges
    
    # Validate target device
    validate_target_device "$target_device"
    
    # Check system boot mode
    check_boot_mode
    
    # Detect current bootloader
    detect_current_bootloader
    
    # Verify system is not currently booting from target device
    check_current_boot_device "$target_device"
    
    # Check for active boot entries
    enumerate_active_boot_entries
    
    # Verify backup capabilities
    check_backup_capabilities
    
    # Check for confirmation if required
    check_user_confirmation
    
    # Validate exclude patterns
    validate_exclude_patterns
    
    # Final safety validation
    if [[ "$SAFETY_CHECKS_PASSED" == "true" ]]; then
        log_info "All safety checks passed"
        return 0
    else
        log_error "Safety checks failed - aborting operation"
        return 1
    fi
}

# Check if running with sufficient privileges
check_root_privileges() {
    log_debug "Checking root privileges"
    
    if [[ $EUID -ne 0 ]]; then
        log_error "Bootloader cleanup requires root privileges"
        log_error "Please run with sudo or as root user"
        return 1
    fi
    
    log_debug "Root privileges confirmed"
    return 0
}

# Validate the target device exists and is accessible
validate_target_device() {
    local device="$1"
    
    log_debug "Validating target device: $device"
    
    if [[ -z "$device" ]]; then
        log_error "No target device specified"
        return 1
    fi
    
    if [[ ! -b "$device" ]]; then
        log_error "Target device does not exist or is not a block device: $device"
        return 1
    fi
    
    if [[ ! -r "$device" ]]; then
        log_error "Cannot read target device: $device"
        return 1
    fi
    
    # Check if device is mounted
    if mount | grep -q "^$device"; then
        log_warn "Target device $device has mounted partitions"
        log_warn "This may indicate the device is currently in use"
        
        # List mounted partitions
        log_debug "Mounted partitions from $device:"
        mount | grep "^$device" | while read -r line; do
            log_debug "  $line"
        done
    fi
    
    log_debug "Target device validation passed: $device"
    return 0
}

# Check system boot mode (UEFI vs BIOS)
check_boot_mode() {
    log_debug "Checking system boot mode"
    
    if [[ -d /sys/firmware/efi ]]; then
        log_info "System is running in UEFI mode"
        export BOOT_MODE="UEFI"
    else
        log_info "System is running in BIOS/Legacy mode"
        export BOOT_MODE="BIOS"
    fi
    
    return 0
}

# Detect the currently active bootloader
detect_current_bootloader() {
    log_debug "Detecting current bootloader"
    
    # Check for systemd-boot
    if [[ -f /boot/loader/loader.conf ]]; then
        CURRENT_BOOTLOADER="systemd-boot"
        log_info "Current bootloader: systemd-boot"
        return 0
    fi
    
    # Check for GRUB (EFI)
    if [[ -d /boot/efi/EFI/GRUB ]] || [[ -d /boot/EFI/GRUB ]]; then
        CURRENT_BOOTLOADER="grub-efi"
        log_info "Current bootloader: GRUB (EFI)"
        return 0
    fi
    
    # Check for GRUB (BIOS)
    if [[ -f /boot/grub/grub.cfg ]] || [[ -f /boot/grub2/grub.cfg ]]; then
        CURRENT_BOOTLOADER="grub-bios"
        log_info "Current bootloader: GRUB (BIOS)"
        return 0
    fi
    
    # Check for EFI stub
    if [[ "$BOOT_MODE" == "UEFI" ]] && efibootmgr 2>/dev/null | grep -q "Linux"; then
        CURRENT_BOOTLOADER="efi-stub"
        log_info "Current bootloader: EFI stub"
        return 0
    fi
    
    log_warn "Could not detect current bootloader"
    CURRENT_BOOTLOADER="unknown"
    return 0
}

# Check if system is currently booting from the target device
check_current_boot_device() {
    local target_device="$1"
    
    log_debug "Checking if system is booting from target device"
    
    # Get the device containing /boot
    local boot_device
    boot_device=$(df /boot 2>/dev/null | tail -1 | awk '{print $1}' | sed 's/[0-9]*$//')
    
    if [[ -z "$boot_device" ]]; then
        log_warn "Could not determine boot device"
        return 0
    fi
    
    log_debug "Boot device: $boot_device"
    log_debug "Target device: $target_device"
    
    if [[ "$boot_device" == "$target_device" ]]; then
        log_error "Target device $target_device is the current boot device"
        log_error "Cleaning up the current boot device could make the system unbootable"
        
        if [[ "${DRY_RUN:-true}" != "true" ]]; then
            log_error "Refusing to proceed with cleanup of current boot device"
            return 1
        else
            log_warn "This is a dry run, but be aware of the risk"
        fi
    fi
    
    return 0
}

# Enumerate active boot entries
enumerate_active_boot_entries() {
    log_debug "Enumerating active boot entries"
    
    ACTIVE_BOOT_ENTRIES=()
    
    if [[ "$BOOT_MODE" == "UEFI" ]]; then
        # Get UEFI boot entries
        if command -v efibootmgr >/dev/null 2>&1; then
            while IFS= read -r line; do
                if [[ "$line" =~ ^Boot[0-9A-F]{4}\*.*$ ]]; then
                    ACTIVE_BOOT_ENTRIES+=("$line")
                    log_debug "Active boot entry: $line"
                fi
            done < <(efibootmgr 2>/dev/null)
        fi
    fi
    
    # Check systemd-boot entries
    if [[ -d /boot/loader/entries ]]; then
        while IFS= read -r -d '' entry; do
            local entry_name
            entry_name=$(basename "$entry" .conf)
            ACTIVE_BOOT_ENTRIES+=("systemd-boot: $entry_name")
            log_debug "systemd-boot entry: $entry_name"
        done < <(find /boot/loader/entries -name "*.conf" -print0 2>/dev/null)
    fi
    
    log_info "Found ${#ACTIVE_BOOT_ENTRIES[@]} active boot entries"
    return 0
}

# Check backup capabilities
check_backup_capabilities() {
    log_debug "Checking backup capabilities"
    
    if [[ "${BACKUP_BOOT_DATA:-true}" != "true" ]]; then
        log_info "Backup is disabled by configuration"
        return 0
    fi
    
    # Create backup directory
    BACKUP_DIRECTORY="/tmp/bootloader-cleanup-backup-$(date +%Y%m%d-%H%M%S)"
    
    if [[ "${DRY_RUN:-true}" != "true" ]]; then
        if ! mkdir -p "$BACKUP_DIRECTORY"; then
            log_error "Failed to create backup directory: $BACKUP_DIRECTORY"
            return 1
        fi
    fi
    
    log_info "Backup directory: $BACKUP_DIRECTORY"
    
    # Check available space
    local available_space
    available_space=$(df /tmp | tail -1 | awk '{print $4}')
    
    if [[ $available_space -lt 1048576 ]]; then  # Less than 1GB
        log_warn "Low disk space in /tmp: ${available_space}KB available"
        log_warn "Backup operations may fail"
    fi
    
    return 0
}

# Check for user confirmation if required
check_user_confirmation() {
    if [[ "${CONFIRMATION_REQUIRED:-true}" != "true" ]]; then
        log_debug "User confirmation not required"
        return 0
    fi
    
    if [[ "${DRY_RUN:-true}" == "true" ]]; then
        log_debug "Dry run mode - skipping confirmation"
        return 0
    fi
    
    log_warn "This operation will perform destructive changes to bootloader configurations"
    log_warn "Target device: ${TARGET_DEVICE:-unknown}"
    log_warn "Target bootloaders: ${TARGET_BOOTLOADERS:-unknown}"
    
    if [[ "${CLEAN_NVRAM:-false}" == "true" ]]; then
        log_warn "UEFI NVRAM entries will also be modified"
    fi
    
    echo -n "Are you sure you want to proceed? (yes/no): "
    read -r response
    
    case "$response" in
        yes|YES|y|Y)
            log_info "User confirmed operation"
            return 0
            ;;
        *)
            log_info "User cancelled operation"
            return 1
            ;;
    esac
}

# Validate exclude patterns
validate_exclude_patterns() {
    log_debug "Validating exclude patterns"
    
    if [[ -z "${EXCLUDE_PATTERNS:-}" ]]; then
        log_debug "No exclude patterns specified"
        return 0
    fi
    
    # Convert space-separated patterns to array
    IFS=' ' read -ra patterns <<< "$EXCLUDE_PATTERNS"
    
    for pattern in "${patterns[@]}"; do
        log_debug "Exclude pattern: $pattern"
        
        # Validate pattern syntax (basic check)
        if [[ "$pattern" =~ ^[a-zA-Z0-9*?_-]+$ ]]; then
            log_debug "Pattern '$pattern' is valid"
        else
            log_warn "Pattern '$pattern' contains potentially unsafe characters"
        fi
    done
    
    return 0
}

# Create backup of critical files
create_backup() {
    local source_path="$1"
    local backup_name="${2:-$(basename "$source_path")}"
    
    if [[ "${BACKUP_BOOT_DATA:-true}" != "true" ]]; then
        log_debug "Backup disabled - skipping $source_path"
        return 0
    fi
    
    if [[ ! -e "$source_path" ]]; then
        log_debug "Source path does not exist - skipping backup: $source_path"
        return 0
    fi
    
    local backup_path="$BACKUP_DIRECTORY/$backup_name"
    
    log_file_op "backup" "$source_path" "to $backup_path"
    
    if [[ "${DRY_RUN:-true}" != "true" ]]; then
        if cp -r "$source_path" "$backup_path" 2>/dev/null; then
            log_backup_created "$backup_path" "$source_path"
            return 0
        else
            log_error "Failed to create backup: $source_path -> $backup_path"
            return 1
        fi
    fi
    
    return 0
}

# Verify file ownership before deletion
verify_file_ownership() {
    local file_path="$1"
    local expected_patterns=("grub" "systemd-boot" "loader" "EFI" "boot")
    
    if [[ ! -e "$file_path" ]]; then
        return 0  # File doesn't exist, safe to "remove"
    fi
    
    local file_name
    file_name=$(basename "$file_path")
    local dir_name
    dir_name=$(basename "$(dirname "$file_path")")
    
    # Check if file/directory name matches expected bootloader patterns
    for pattern in "${expected_patterns[@]}"; do
        if [[ "$file_name" == *"$pattern"* ]] || [[ "$dir_name" == *"$pattern"* ]]; then
            log_debug "File ownership verified: $file_path (matches pattern: $pattern)"
            return 0
        fi
    done
    
    # Additional checks for specific file types
    if [[ "$file_path" == *.efi ]] || [[ "$file_path" == *.conf ]] || [[ "$file_path" == *grub* ]]; then
        log_debug "File ownership verified by extension: $file_path"
        return 0
    fi
    
    log_warn "Could not verify bootloader ownership of: $file_path"
    log_warn "File will be skipped for safety"
    return 1
}

# Final safety validation before proceeding
finalize_safety_checks() {
    local errors=0
    
    # Check that we have a valid target device
    if [[ -z "${TARGET_DEVICE:-}" ]]; then
        log_error "No target device specified"
        ((errors++))
    fi
    
    # Check that we have valid bootloader targets
    if [[ -z "${TARGET_BOOTLOADERS:-}" ]]; then
        log_error "No target bootloaders specified"
        ((errors++))
    fi
    
    # Warn about cleaning current bootloader
    if [[ "${TARGET_BOOTLOADERS:-}" == *"$CURRENT_BOOTLOADER"* ]] && [[ "${DRY_RUN:-true}" != "true" ]]; then
        log_warn "Target includes current bootloader: $CURRENT_BOOTLOADER"
        log_warn "This may make the system unbootable"
    fi
    
    if [[ $errors -eq 0 ]]; then
        SAFETY_CHECKS_PASSED=true
        return 0
    else
        SAFETY_CHECKS_PASSED=false
        return 1
    fi
}

# Export functions and variables
export -f perform_safety_checks check_root_privileges validate_target_device
export -f check_boot_mode detect_current_bootloader check_current_boot_device
export -f enumerate_active_boot_entries check_backup_capabilities check_user_confirmation
export -f validate_exclude_patterns create_backup verify_file_ownership finalize_safety_checks
export SAFETY_CHECKS_PASSED BACKUP_DIRECTORY CURRENT_BOOTLOADER
