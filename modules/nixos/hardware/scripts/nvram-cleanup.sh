#!/usr/bin/env bash
# UEFI NVRAM cleanup implementation
# Safely removes orphaned UEFI boot entries from firmware NVRAM

# Global variables for NVRAM cleanup tracking
NVRAM_ENTRIES_REMOVED=0
NVRAM_ERRORS=0
NVRAM_BACKUP_FILE=""

# Main NVRAM cleanup function
cleanup_nvram_entries() {
    log_section "UEFI NVRAM Cleanup"
    log_info "Cleaning orphaned UEFI boot entries from NVRAM"
    
    # Check if we're in UEFI mode
    if [[ "$BOOT_MODE" != "UEFI" ]]; then
        log_info "System is not in UEFI mode - skipping NVRAM cleanup"
        return 0
    fi
    
    # Check if efibootmgr is available
    if ! command -v efibootmgr >/dev/null 2>&1; then
        log_error "efibootmgr not found - cannot clean NVRAM entries"
        return 1
    fi
    
    # Create backup of current boot entries
    backup_nvram_entries
    
    # Get current boot entries
    local boot_entries
    boot_entries=$(get_boot_entries)
    
    if [[ -z "$boot_entries" ]]; then
        log_info "No boot entries found in NVRAM"
        return 0
    fi
    
    # Clean up bootloader-specific entries
    cleanup_grub_nvram_entries
    cleanup_systemd_boot_nvram_entries
    cleanup_efi_stub_nvram_entries
    cleanup_orphaned_nvram_entries
    
    # Verify boot order integrity
    verify_boot_order_integrity
    
    log_info "NVRAM cleanup completed: $NVRAM_ENTRIES_REMOVED entries removed, $NVRAM_ERRORS errors"
    return 0
}

# Create backup of NVRAM boot entries
backup_nvram_entries() {
    log_info "Creating backup of NVRAM boot entries"
    
    if [[ "${BACKUP_BOOT_DATA:-true}" != "true" ]]; then
        log_info "NVRAM backup disabled by configuration"
        return 0
    fi
    
    NVRAM_BACKUP_FILE="$BACKUP_DIRECTORY/nvram-backup-$(date +%Y%m%d-%H%M%S).txt"
    
    log_file_op "backup NVRAM entries" "$NVRAM_BACKUP_FILE"
    
    if [[ "${DRY_RUN:-true}" != "true" ]]; then
        if efibootmgr -v > "$NVRAM_BACKUP_FILE" 2>/dev/null; then
            log_info "NVRAM backup created: $NVRAM_BACKUP_FILE"
        else
            log_error "Failed to create NVRAM backup"
            ((NVRAM_ERRORS++))
            return 1
        fi
    fi
    
    return 0
}

# Get all boot entries from NVRAM
get_boot_entries() {
    efibootmgr 2>/dev/null | grep "^Boot[0-9A-F]\{4\}"
}

# Clean up GRUB-related NVRAM entries
cleanup_grub_nvram_entries() {
    log_debug "Cleaning GRUB-related NVRAM entries"
    
    # Only clean if GRUB was targeted for cleanup
    if [[ "${TARGET_BOOTLOADERS:-}" != *"grub"* ]]; then
        log_debug "GRUB not targeted for cleanup - skipping NVRAM entries"
        return 0
    fi
    
    local grub_entries
    grub_entries=$(efibootmgr 2>/dev/null | grep -iE "(grub|GRUB)")
    
    if [[ -n "$grub_entries" ]]; then
        log_info "Found GRUB entries in NVRAM:"
        echo "$grub_entries" | while IFS= read -r entry; do
            log_info "  $entry"
        done
        
        # Extract boot numbers and remove entries
        echo "$grub_entries" | while IFS= read -r entry; do
            local boot_num
            boot_num=$(echo "$entry" | grep -oE "Boot[0-9A-F]{4}" | sed 's/Boot//')
            
            if [[ -n "$boot_num" ]]; then
                remove_nvram_entry "$boot_num" "GRUB"
            fi
        done
    else
        log_debug "No GRUB entries found in NVRAM"
    fi
}

# Clean up systemd-boot related NVRAM entries
cleanup_systemd_boot_nvram_entries() {
    log_debug "Cleaning systemd-boot related NVRAM entries"
    
    # Only clean if systemd-boot was targeted for cleanup
    if [[ "${TARGET_BOOTLOADERS:-}" != *"systemd-boot"* ]]; then
        log_debug "systemd-boot not targeted for cleanup - skipping NVRAM entries"
        return 0
    fi
    
    local systemd_boot_entries
    systemd_boot_entries=$(efibootmgr 2>/dev/null | grep -iE "(systemd-boot|Linux Boot Manager)")
    
    if [[ -n "$systemd_boot_entries" ]]; then
        log_info "Found systemd-boot entries in NVRAM:"
        echo "$systemd_boot_entries" | while IFS= read -r entry; do
            log_info "  $entry"
        done
        
        # Extract boot numbers and remove entries
        echo "$systemd_boot_entries" | while IFS= read -r entry; do
            local boot_num
            boot_num=$(echo "$entry" | grep -oE "Boot[0-9A-F]{4}" | sed 's/Boot//')
            
            if [[ -n "$boot_num" ]]; then
                remove_nvram_entry "$boot_num" "systemd-boot"
            fi
        done
    else
        log_debug "No systemd-boot entries found in NVRAM"
    fi
}

# Clean up EFI stub related NVRAM entries
cleanup_efi_stub_nvram_entries() {
    log_debug "Cleaning EFI stub related NVRAM entries"
    
    # Only clean if EFI stub was targeted for cleanup
    if [[ "${TARGET_BOOTLOADERS:-}" != *"efi-stub"* ]]; then
        log_debug "EFI stub not targeted for cleanup - skipping NVRAM entries"
        return 0
    fi
    
    # EFI stub entries are typically direct kernel boots
    local efi_stub_entries
    efi_stub_entries=$(efibootmgr -v 2>/dev/null | grep -E "vmlinuz|kernel|linux.*\.efi")
    
    if [[ -n "$efi_stub_entries" ]]; then
        log_info "Found EFI stub entries in NVRAM:"
        echo "$efi_stub_entries" | while IFS= read -r entry; do
            log_info "  $entry"
        done
        
        # Extract boot numbers and remove entries
        echo "$efi_stub_entries" | while IFS= read -r entry; do
            local boot_num
            boot_num=$(echo "$entry" | grep -oE "Boot[0-9A-F]{4}" | sed 's/Boot//')
            
            if [[ -n "$boot_num" ]]; then
                # Check if this entry should be excluded
                if should_exclude_nvram_entry "$entry"; then
                    log_info "Excluding NVRAM entry from cleanup: Boot$boot_num"
                    continue
                fi
                
                remove_nvram_entry "$boot_num" "EFI stub"
            fi
        done
    else
        log_debug "No EFI stub entries found in NVRAM"
    fi
}

# Clean up orphaned NVRAM entries
cleanup_orphaned_nvram_entries() {
    log_debug "Cleaning orphaned NVRAM entries"
    
    # Get all boot entries with verbose information
    local all_entries
    all_entries=$(efibootmgr -v 2>/dev/null)
    
    if [[ -z "$all_entries" ]]; then
        log_debug "No boot entries found for orphan cleanup"
        return 0
    fi
    
    # Look for entries that point to non-existent files
    echo "$all_entries" | grep "^Boot[0-9A-F]\{4\}" | while IFS= read -r entry; do
        local boot_num
        boot_num=$(echo "$entry" | grep -oE "Boot[0-9A-F]{4}" | sed 's/Boot//')
        
        if [[ -n "$boot_num" ]]; then
            if is_orphaned_entry "$entry"; then
                log_info "Found orphaned NVRAM entry: $entry"
                
                # Check if this entry should be excluded
                if should_exclude_nvram_entry "$entry"; then
                    log_info "Excluding orphaned entry from cleanup: Boot$boot_num"
                    continue
                fi
                
                remove_nvram_entry "$boot_num" "orphaned"
            fi
        fi
    done
}

# Remove a specific NVRAM entry
remove_nvram_entry() {
    local boot_num="$1"
    local entry_type="$2"
    
    log_info "Removing $entry_type NVRAM entry: Boot$boot_num"
    
    # Verify the entry exists before attempting removal
    if ! efibootmgr 2>/dev/null | grep -q "Boot$boot_num"; then
        log_debug "Boot entry Boot$boot_num does not exist"
        return 0
    fi
    
    log_file_op "remove NVRAM entry" "Boot$boot_num ($entry_type)"
    
    if [[ "${DRY_RUN:-true}" != "true" ]]; then
        if efibootmgr -b "$boot_num" -B >/dev/null 2>&1; then
            log_info "Successfully removed NVRAM entry: Boot$boot_num"
            ((NVRAM_ENTRIES_REMOVED++))
        else
            log_error "Failed to remove NVRAM entry: Boot$boot_num"
            ((NVRAM_ERRORS++))
        fi
    fi
}

# Check if a NVRAM entry is orphaned
is_orphaned_entry() {
    local entry="$1"
    
    # Extract file path from the entry
    local file_path
    file_path=$(echo "$entry" | grep -oE "\\\\[^\\\\]*\\.efi" | sed 's/\\\\/\//g' | head -1)
    
    if [[ -z "$file_path" ]]; then
        # No file path found, might be a firmware entry
        return 1
    fi
    
    # Check if the file exists on any mounted EFI partition
    local efi_partitions
    efi_partitions=$(mount | grep -E "(vfat|fat)" | awk '{print $3}')
    
    for mount_point in $efi_partitions; do
        local full_path="$mount_point$file_path"
        if [[ -f "$full_path" ]]; then
            log_debug "NVRAM entry file exists: $full_path"
            return 1  # Not orphaned
        fi
    done
    
    # Also check common EFI mount points
    local common_efi_paths=(
        "/boot/efi$file_path"
        "/boot$file_path"
        "/efi$file_path"
    )
    
    for path in "${common_efi_paths[@]}"; do
        if [[ -f "$path" ]]; then
            log_debug "NVRAM entry file exists: $path"
            return 1  # Not orphaned
        fi
    done
    
    log_debug "NVRAM entry appears to be orphaned: $file_path"
    return 0  # Is orphaned
}

# Check if a NVRAM entry should be excluded from cleanup
should_exclude_nvram_entry() {
    local entry="$1"
    
    if [[ -z "${EXCLUDE_PATTERNS:-}" ]]; then
        return 1  # No exclusions
    fi
    
    # Convert space-separated patterns to array
    IFS=' ' read -ra patterns <<< "$EXCLUDE_PATTERNS"
    
    for pattern in "${patterns[@]}"; do
        if echo "$entry" | grep -q "$pattern"; then
            log_debug "NVRAM entry matches exclude pattern '$pattern'"
            return 0  # Should exclude
        fi
    done
    
    # Always exclude Windows Boot Manager and other critical entries
    local critical_patterns=(
        "Windows Boot Manager"
        "Microsoft"
        "UEFI"
        "Setup"
        "Firmware"
    )
    
    for pattern in "${critical_patterns[@]}"; do
        if echo "$entry" | grep -qi "$pattern"; then
            log_debug "NVRAM entry matches critical pattern '$pattern' - excluding"
            return 0  # Should exclude
        fi
    done
    
    return 1  # Should not exclude
}

# Verify boot order integrity after cleanup
verify_boot_order_integrity() {
    log_debug "Verifying boot order integrity"
    
    local boot_order
    boot_order=$(efibootmgr 2>/dev/null | grep "BootOrder:" | cut -d: -f2 | tr -d ' ')
    
    if [[ -z "$boot_order" ]]; then
        log_warn "No boot order found in NVRAM"
        return 0
    fi
    
    log_debug "Current boot order: $boot_order"
    
    # Check if all entries in boot order actually exist
    IFS=',' read -ra order_entries <<< "$boot_order"
    local valid_entries=()
    local invalid_entries=()
    
    for entry in "${order_entries[@]}"; do
        if efibootmgr 2>/dev/null | grep -q "Boot$entry"; then
            valid_entries+=("$entry")
        else
            invalid_entries+=("$entry")
            log_warn "Boot order references non-existent entry: Boot$entry"
        fi
    done
    
    # If we found invalid entries, update the boot order
    if [[ ${#invalid_entries[@]} -gt 0 ]]; then
        log_info "Updating boot order to remove invalid entries"
        
        local new_boot_order
        new_boot_order=$(IFS=','; echo "${valid_entries[*]}")
        
        log_file_op "update boot order" "$new_boot_order"
        
        if [[ "${DRY_RUN:-true}" != "true" ]]; then
            if efibootmgr -o "$new_boot_order" >/dev/null 2>&1; then
                log_info "Boot order updated successfully: $new_boot_order"
            else
                log_error "Failed to update boot order"
                ((NVRAM_ERRORS++))
            fi
        fi
    else
        log_info "Boot order integrity verified"
    fi
}

# List all NVRAM entries for review
list_nvram_entries() {
    log_info "Current NVRAM boot entries:"
    
    local entries
    entries=$(efibootmgr -v 2>/dev/null)
    
    if [[ -n "$entries" ]]; then
        echo "$entries" | grep "^Boot[0-9A-F]\{4\}" | while IFS= read -r entry; do
            local boot_num
            boot_num=$(echo "$entry" | grep -oE "Boot[0-9A-F]{4}")
            
            log_info "  $entry"
            
            # Show if this entry would be excluded
            if should_exclude_nvram_entry "$entry"; then
                log_info "    (EXCLUDED from cleanup)"
            fi
            
            # Show if this entry appears orphaned
            if is_orphaned_entry "$entry"; then
                log_info "    (ORPHANED - file not found)"
            fi
        done
        
        # Show boot order
        local boot_order
        boot_order=$(echo "$entries" | grep "BootOrder:" | cut -d: -f2)
        if [[ -n "$boot_order" ]]; then
            log_info "Boot order:$boot_order"
        fi
    else
        log_info "  No boot entries found"
    fi
}

# Restore NVRAM entries from backup
restore_nvram_backup() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi
    
    log_info "Restoring NVRAM entries from backup: $backup_file"
    log_warn "This is a manual process - backup file contains efibootmgr output for reference"
    log_info "Use the backup file to manually recreate boot entries if needed"
    
    # Show the backup content for reference
    log_info "Backup content:"
    cat "$backup_file"
}

# Get NVRAM statistics
get_nvram_stats() {
    local total_entries
    total_entries=$(efibootmgr 2>/dev/null | grep -c "^Boot[0-9A-F]\{4\}")
    
    local active_entries
    active_entries=$(efibootmgr 2>/dev/null | grep -c "^Boot[0-9A-F]\{4\}\*")
    
    local orphaned_count=0
    local entries
    entries=$(efibootmgr -v 2>/dev/null | grep "^Boot[0-9A-F]\{4\}")
    
    if [[ -n "$entries" ]]; then
        while IFS= read -r entry; do
            if is_orphaned_entry "$entry"; then
                ((orphaned_count++))
            fi
        done <<< "$entries"
    fi
    
    log_info "NVRAM Statistics:"
    log_info "  Total entries: $total_entries"
    log_info "  Active entries: $active_entries"
    log_info "  Orphaned entries: $orphaned_count"
}

# Export functions
export -f cleanup_nvram_entries backup_nvram_entries get_boot_entries
export -f cleanup_grub_nvram_entries cleanup_systemd_boot_nvram_entries cleanup_efi_stub_nvram_entries
export -f cleanup_orphaned_nvram_entries remove_nvram_entry is_orphaned_entry should_exclude_nvram_entry
export -f verify_boot_order_integrity list_nvram_entries restore_nvram_backup get_nvram_stats
