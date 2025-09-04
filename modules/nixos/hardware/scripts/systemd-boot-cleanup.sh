#!/usr/bin/env bash
# systemd-boot cleanup implementation
# Safely removes systemd-boot installations and configurations

# Global variables for systemd-boot cleanup tracking
SYSTEMD_BOOT_FILES_REMOVED=0
SYSTEMD_BOOT_ERRORS=0

# Main systemd-boot cleanup function
cleanup_systemd_boot() {
    local target_device="$1"
    
    log_section "systemd-boot Cleanup"
    log_info "Cleaning systemd-boot installations on $target_device"
    
    # Check if systemd-boot was detected
    if ! is_bootloader_detected "systemd-boot"; then
        log_info "No systemd-boot installations detected - skipping cleanup"
        return 0
    fi
    
    # Clean up systemd-boot from EFI partitions
    cleanup_systemd_boot_efi "$target_device"
    
    # Clean up systemd-boot from mounted /boot
    cleanup_systemd_boot_mounted
    
    # Clean up systemd-boot configuration files
    cleanup_systemd_boot_configs
    
    # Clean up boot entries
    cleanup_systemd_boot_entries
    
    log_info "systemd-boot cleanup completed: $SYSTEMD_BOOT_FILES_REMOVED files removed, $SYSTEMD_BOOT_ERRORS errors"
    return 0
}

# Clean up systemd-boot from EFI partitions
cleanup_systemd_boot_efi() {
    local target_device="$1"
    
    log_info "Cleaning systemd-boot from EFI partitions"
    
    # Find EFI partitions on the target device
    local efi_partitions
    efi_partitions=$(lsblk -no NAME,FSTYPE "$target_device" | grep -E "(vfat|fat32)" | awk '{print "/dev/"$1}')
    
    for partition in $efi_partitions; do
        log_debug "Checking EFI partition for systemd-boot: $partition"
        
        local temp_mount
        temp_mount=$(mktemp -d)
        
        if mount "$partition" "$temp_mount" 2>/dev/null; then
            # Clean up systemd-boot EFI directories
            cleanup_systemd_boot_efi_directory "$temp_mount/EFI/systemd"
            cleanup_systemd_boot_efi_directory "$temp_mount/EFI/SYSTEMD"
            
            # Clean up loader directory
            cleanup_systemd_boot_loader_directory "$temp_mount/loader"
            
            # Clean up systemd-boot from BOOT directory if present
            cleanup_systemd_boot_from_boot_directory "$temp_mount/EFI/BOOT"
            cleanup_systemd_boot_from_boot_directory "$temp_mount/EFI/Boot"
            
            umount "$temp_mount"
        else
            log_debug "Could not mount EFI partition: $partition"
        fi
        
        rmdir "$temp_mount" 2>/dev/null
    done
}

# Clean up systemd-boot EFI directory
cleanup_systemd_boot_efi_directory() {
    local systemd_dir="$1"
    
    if [[ ! -d "$systemd_dir" ]]; then
        return 0
    fi
    
    log_info "Cleaning systemd-boot EFI directory: $systemd_dir"
    
    # Create backup of the directory
    create_backup "$systemd_dir" "systemd-boot-efi-$(basename "$systemd_dir")"
    
    # List of systemd-boot EFI files to remove
    local systemd_boot_files=(
        "systemd-bootx64.efi"
        "systemd-bootia32.efi"
        "systemd-bootaa64.efi"
        "systemd-boot.efi"
    )
    
    for file in "${systemd_boot_files[@]}"; do
        local file_path="$systemd_dir/$file"
        if [[ -f "$file_path" ]]; then
            # Verify it's actually systemd-boot
            if strings "$file_path" 2>/dev/null | grep -q "systemd-boot"; then
                if verify_file_ownership "$file_path"; then
                    log_file_op "remove systemd-boot binary" "$file_path"
                    if [[ "${DRY_RUN:-true}" != "true" ]]; then
                        if rm "$file_path" 2>/dev/null; then
                            ((SYSTEMD_BOOT_FILES_REMOVED++))
                        else
                            log_error "Failed to remove: $file_path"
                            ((SYSTEMD_BOOT_ERRORS++))
                        fi
                    fi
                fi
            else
                log_debug "File does not appear to be systemd-boot: $file_path"
            fi
        fi
    done
    
    # Remove the directory if it's empty
    if [[ "${DRY_RUN:-true}" != "true" ]]; then
        if [[ -d "$systemd_dir" ]] && [[ -z "$(ls -A "$systemd_dir" 2>/dev/null)" ]]; then
            log_file_op "remove empty directory" "$systemd_dir"
            if rmdir "$systemd_dir" 2>/dev/null; then
                log_info "Removed empty systemd-boot directory: $systemd_dir"
            fi
        fi
    else
        log_dry_run "Would remove empty directory: $systemd_dir"
    fi
}

# Clean up systemd-boot loader directory
cleanup_systemd_boot_loader_directory() {
    local loader_dir="$1"
    
    if [[ ! -d "$loader_dir" ]]; then
        return 0
    fi
    
    log_info "Cleaning systemd-boot loader directory: $loader_dir"
    
    # Create backup of the loader directory
    create_backup "$loader_dir" "systemd-boot-loader"
    
    # Clean up loader configuration
    local loader_config="$loader_dir/loader.conf"
    if [[ -f "$loader_config" ]]; then
        log_file_op "remove loader config" "$loader_config"
        if [[ "${DRY_RUN:-true}" != "true" ]]; then
            if rm "$loader_config" 2>/dev/null; then
                ((SYSTEMD_BOOT_FILES_REMOVED++))
            else
                log_error "Failed to remove: $loader_config"
                ((SYSTEMD_BOOT_ERRORS++))
            fi
        fi
    fi
    
    # Clean up boot entries directory
    local entries_dir="$loader_dir/entries"
    if [[ -d "$entries_dir" ]]; then
        cleanup_systemd_boot_entries_directory "$entries_dir"
    fi
    
    # Clean up other loader files
    local loader_files=(
        "random-seed"
        "keys"
    )
    
    for file in "${loader_files[@]}"; do
        local file_path="$loader_dir/$file"
        if [[ -e "$file_path" ]]; then
            log_file_op "remove loader file" "$file_path"
            if [[ "${DRY_RUN:-true}" != "true" ]]; then
                if rm -rf "$file_path" 2>/dev/null; then
                    ((SYSTEMD_BOOT_FILES_REMOVED++))
                else
                    log_error "Failed to remove: $file_path"
                    ((SYSTEMD_BOOT_ERRORS++))
                fi
            fi
        fi
    done
    
    # Remove the loader directory if it's empty
    if [[ "${DRY_RUN:-true}" != "true" ]]; then
        if [[ -d "$loader_dir" ]] && [[ -z "$(ls -A "$loader_dir" 2>/dev/null)" ]]; then
            log_file_op "remove empty loader directory" "$loader_dir"
            if rmdir "$loader_dir" 2>/dev/null; then
                log_info "Removed empty loader directory: $loader_dir"
            fi
        fi
    else
        log_dry_run "Would remove empty loader directory: $loader_dir"
    fi
}

# Clean up systemd-boot entries directory
cleanup_systemd_boot_entries_directory() {
    local entries_dir="$1"
    
    log_info "Cleaning systemd-boot entries directory: $entries_dir"
    
    # List all boot entries
    local entry_files
    entry_files=$(find "$entries_dir" -name "*.conf" -type f 2>/dev/null)
    
    if [[ -n "$entry_files" ]]; then
        local entry_count
        entry_count=$(echo "$entry_files" | wc -l)
        log_info "Found $entry_count boot entries to clean up"
        
        while IFS= read -r entry_file; do
            if [[ -f "$entry_file" ]]; then
                # Check if this entry should be excluded
                if should_exclude_boot_entry "$entry_file"; then
                    log_info "Excluding boot entry from cleanup: $(basename "$entry_file")"
                    continue
                fi
                
                log_file_op "remove boot entry" "$entry_file"
                if [[ "${DRY_RUN:-true}" != "true" ]]; then
                    if rm "$entry_file" 2>/dev/null; then
                        ((SYSTEMD_BOOT_FILES_REMOVED++))
                    else
                        log_error "Failed to remove: $entry_file"
                        ((SYSTEMD_BOOT_ERRORS++))
                    fi
                fi
            fi
        done <<< "$entry_files"
    fi
    
    # Remove the entries directory if it's empty
    if [[ "${DRY_RUN:-true}" != "true" ]]; then
        if [[ -d "$entries_dir" ]] && [[ -z "$(ls -A "$entries_dir" 2>/dev/null)" ]]; then
            log_file_op "remove empty entries directory" "$entries_dir"
            if rmdir "$entries_dir" 2>/dev/null; then
                log_info "Removed empty entries directory: $entries_dir"
            fi
        fi
    else
        log_dry_run "Would remove empty entries directory: $entries_dir"
    fi
}

# Clean up systemd-boot from EFI/BOOT directory
cleanup_systemd_boot_from_boot_directory() {
    local boot_dir="$1"
    
    if [[ ! -d "$boot_dir" ]]; then
        return 0
    fi
    
    log_debug "Checking EFI/BOOT directory for systemd-boot files: $boot_dir"
    
    # Check for systemd-boot files in the BOOT directory
    local boot_files=(
        "bootx64.efi"
        "bootia32.efi"
        "bootaa64.efi"
    )
    
    for file in "${boot_files[@]}"; do
        local file_path="$boot_dir/$file"
        if [[ -f "$file_path" ]]; then
            # Verify it's actually systemd-boot by checking file contents
            if strings "$file_path" 2>/dev/null | grep -q "systemd-boot"; then
                log_info "Found systemd-boot file in EFI/BOOT: $file_path"
                create_backup "$file_path" "boot-systemd-$(basename "$file_path")"
                
                log_file_op "remove systemd-boot file" "$file_path"
                if [[ "${DRY_RUN:-true}" != "true" ]]; then
                    if rm "$file_path" 2>/dev/null; then
                        ((SYSTEMD_BOOT_FILES_REMOVED++))
                    else
                        log_error "Failed to remove: $file_path"
                        ((SYSTEMD_BOOT_ERRORS++))
                    fi
                fi
            else
                log_debug "File in EFI/BOOT is not systemd-boot: $file_path"
            fi
        fi
    done
}

# Clean up systemd-boot from mounted /boot
cleanup_systemd_boot_mounted() {
    log_debug "Cleaning systemd-boot from mounted /boot"
    
    # Check for systemd-boot in /boot
    if [[ -d /boot/loader ]]; then
        cleanup_systemd_boot_loader_directory "/boot/loader"
    fi
    
    # Check for systemd-boot EFI files in /boot/EFI
    if [[ -d /boot/EFI/systemd ]]; then
        cleanup_systemd_boot_efi_directory "/boot/EFI/systemd"
    fi
    
    if [[ -d /boot/EFI/SYSTEMD ]]; then
        cleanup_systemd_boot_efi_directory "/boot/EFI/SYSTEMD"
    fi
}

# Clean up systemd-boot configuration files
cleanup_systemd_boot_configs() {
    log_debug "Cleaning systemd-boot configuration files"
    
    # systemd-boot doesn't typically have system-wide config files like GRUB
    # Most configuration is in the loader directory which is already handled
    
    # Check for any systemd-boot related files in /etc
    local config_locations=(
        "/etc/systemd/boot"
        "/etc/kernel/cmdline"
    )
    
    for config_location in "${config_locations[@]}"; do
        if [[ -e "$config_location" ]]; then
            # Be very careful with system configuration files
            if [[ "${DRY_RUN:-true}" == "true" ]] || [[ "${CONFIRMATION_REQUIRED:-true}" == "true" ]]; then
                log_info "systemd-boot related config found: $config_location"
                log_info "Consider manual review of system configuration files"
            else
                create_backup "$config_location" "systemd-boot-config-$(basename "$config_location")"
                
                log_file_op "remove systemd-boot config" "$config_location"
                if rm -rf "$config_location" 2>/dev/null; then
                    ((SYSTEMD_BOOT_FILES_REMOVED++))
                else
                    log_error "Failed to remove: $config_location"
                    ((SYSTEMD_BOOT_ERRORS++))
                fi
            fi
        fi
    done
}

# Clean up systemd-boot entries (alternative entry point)
cleanup_systemd_boot_entries() {
    log_debug "Cleaning systemd-boot entries"
    
    # This function provides an alternative way to clean up entries
    # The main cleanup is done in cleanup_systemd_boot_entries_directory
    
    # Check for entries in common locations
    local entry_locations=(
        "/boot/loader/entries"
        "/efi/loader/entries"
    )
    
    for entry_location in "${entry_locations[@]}"; do
        if [[ -d "$entry_location" ]]; then
            cleanup_systemd_boot_entries_directory "$entry_location"
        fi
    done
}

# Check if a boot entry should be excluded from cleanup
should_exclude_boot_entry() {
    local entry_file="$1"
    local entry_name
    entry_name=$(basename "$entry_file" .conf)
    
    if [[ -z "${EXCLUDE_PATTERNS:-}" ]]; then
        return 1  # No exclusions
    fi
    
    # Convert space-separated patterns to array
    IFS=' ' read -ra patterns <<< "$EXCLUDE_PATTERNS"
    
    for pattern in "${patterns[@]}"; do
        if [[ "$entry_name" == $pattern ]]; then
            log_debug "Boot entry matches exclude pattern '$pattern': $entry_name"
            return 0  # Should exclude
        fi
    done
    
    # Also check the content of the entry file for exclusion patterns
    if [[ -f "$entry_file" ]]; then
        local entry_content
        entry_content=$(cat "$entry_file" 2>/dev/null)
        
        for pattern in "${patterns[@]}"; do
            if echo "$entry_content" | grep -q "$pattern"; then
                log_debug "Boot entry content matches exclude pattern '$pattern': $entry_name"
                return 0  # Should exclude
            fi
        done
    fi
    
    return 1  # Should not exclude
}

# Verify systemd-boot installation before cleanup
verify_systemd_boot_installation() {
    local installation_path="$1"
    
    # Check for systemd-boot specific files
    if [[ -f "$installation_path/systemd-bootx64.efi" ]] || [[ -f "$installation_path/loader.conf" ]]; then
        return 0
    fi
    
    # Check for loader directory structure
    if [[ -d "$installation_path/loader" ]] && [[ -d "$installation_path/loader/entries" ]]; then
        return 0
    fi
    
    return 1
}

# Get systemd-boot version information
get_systemd_boot_version() {
    local efi_file="$1"
    
    if [[ -f "$efi_file" ]] && strings "$efi_file" 2>/dev/null | grep -q "systemd-boot"; then
        local version_info
        version_info=$(strings "$efi_file" | grep -E "systemd-boot [0-9]+" | head -1)
        echo "${version_info:-unknown}"
    else
        echo "unknown"
    fi
}

# List systemd-boot entries for review
list_systemd_boot_entries() {
    local entries_dir="$1"
    
    if [[ ! -d "$entries_dir" ]]; then
        return 0
    fi
    
    log_info "systemd-boot entries in $entries_dir:"
    
    local entry_files
    entry_files=$(find "$entries_dir" -name "*.conf" -type f 2>/dev/null)
    
    if [[ -n "$entry_files" ]]; then
        while IFS= read -r entry_file; do
            local entry_name
            entry_name=$(basename "$entry_file" .conf)
            
            # Extract title from entry file
            local title
            title=$(grep "^title" "$entry_file" 2>/dev/null | cut -d' ' -f2- || echo "No title")
            
            log_info "  $entry_name: $title"
            
            # Show if this entry would be excluded
            if should_exclude_boot_entry "$entry_file"; then
                log_info "    (EXCLUDED from cleanup)"
            fi
        done <<< "$entry_files"
    else
        log_info "  No entries found"
    fi
}

# Export functions
export -f cleanup_systemd_boot cleanup_systemd_boot_efi cleanup_systemd_boot_efi_directory
export -f cleanup_systemd_boot_loader_directory cleanup_systemd_boot_entries_directory
export -f cleanup_systemd_boot_from_boot_directory cleanup_systemd_boot_mounted
export -f cleanup_systemd_boot_configs cleanup_systemd_boot_entries should_exclude_boot_entry
export -f verify_systemd_boot_installation get_systemd_boot_version list_systemd_boot_entries
