#!/usr/bin/env bash
# EFI stub bootloader cleanup implementation
# Safely removes EFI stub bootloader entries and kernel files

# Global variables for EFI stub cleanup tracking
EFI_STUB_FILES_REMOVED=0
EFI_STUB_ERRORS=0

# Main EFI stub cleanup function
cleanup_efi_stub() {
    local target_device="$1"
    
    log_section "EFI Stub Cleanup"
    log_info "Cleaning EFI stub installations on $target_device"
    
    # Check if EFI stub was detected
    if ! is_bootloader_detected "efi-stub"; then
        log_info "No EFI stub installations detected - skipping cleanup"
        return 0
    fi
    
    # Clean up EFI stub kernel files from EFI partitions
    cleanup_efi_stub_kernels "$target_device"
    
    # Clean up EFI stub entries from UEFI NVRAM (handled separately in nvram-cleanup.sh)
    # This function focuses on file cleanup
    
    log_info "EFI stub cleanup completed: $EFI_STUB_FILES_REMOVED files removed, $EFI_STUB_ERRORS errors"
    return 0
}

# Clean up EFI stub kernel files from EFI partitions
cleanup_efi_stub_kernels() {
    local target_device="$1"
    
    log_info "Cleaning EFI stub kernel files from EFI partitions"
    
    # Find EFI partitions on the target device
    local efi_partitions
    efi_partitions=$(lsblk -no NAME,FSTYPE "$target_device" | grep -E "(vfat|fat32)" | awk '{print "/dev/"$1}')
    
    for partition in $efi_partitions; do
        log_debug "Checking EFI partition for EFI stub kernels: $partition"
        
        local temp_mount
        temp_mount=$(mktemp -d)
        
        if mount "$partition" "$temp_mount" 2>/dev/null; then
            # Clean up EFI stub kernels from common locations
            cleanup_efi_stub_directory "$temp_mount/EFI/Linux"
            cleanup_efi_stub_directory "$temp_mount/EFI/BOOT"
            cleanup_efi_stub_directory "$temp_mount/EFI/systemd"
            
            # Look for kernel files in other EFI directories
            find_and_cleanup_kernel_files "$temp_mount"
            
            umount "$temp_mount"
        else
            log_debug "Could not mount EFI partition: $partition"
        fi
        
        rmdir "$temp_mount" 2>/dev/null
    done
    
    # Also check mounted /boot for EFI stub kernels
    cleanup_efi_stub_mounted_boot
}

# Clean up EFI stub files from a specific directory
cleanup_efi_stub_directory() {
    local efi_dir="$1"
    
    if [[ ! -d "$efi_dir" ]]; then
        return 0
    fi
    
    log_info "Cleaning EFI stub directory: $efi_dir"
    
    # Create backup of the directory
    create_backup "$efi_dir" "efi-stub-$(basename "$efi_dir")"
    
    # Look for EFI stub kernel files
    local kernel_files
    kernel_files=$(find "$efi_dir" -name "*.efi" -type f 2>/dev/null)
    
    if [[ -n "$kernel_files" ]]; then
        while IFS= read -r kernel_file; do
            if [[ -f "$kernel_file" ]]; then
                # Check if this is actually an EFI stub kernel
                if is_efi_stub_kernel "$kernel_file"; then
                    # Check if this kernel should be excluded
                    if should_exclude_efi_stub_kernel "$kernel_file"; then
                        log_info "Excluding EFI stub kernel from cleanup: $(basename "$kernel_file")"
                        continue
                    fi
                    
                    log_file_op "remove EFI stub kernel" "$kernel_file"
                    if [[ "${DRY_RUN:-true}" != "true" ]]; then
                        if rm "$kernel_file" 2>/dev/null; then
                            ((EFI_STUB_FILES_REMOVED++))
                        else
                            log_error "Failed to remove: $kernel_file"
                            ((EFI_STUB_ERRORS++))
                        fi
                    fi
                else
                    log_debug "File is not an EFI stub kernel: $kernel_file"
                fi
            fi
        done <<< "$kernel_files"
    fi
    
    # Clean up associated files (initrd, etc.)
    cleanup_associated_files "$efi_dir"
    
    # Remove the directory if it's empty and it's a Linux-specific directory
    if [[ "$(basename "$efi_dir")" == "Linux" ]]; then
        if [[ "${DRY_RUN:-true}" != "true" ]]; then
            if [[ -d "$efi_dir" ]] && [[ -z "$(ls -A "$efi_dir" 2>/dev/null)" ]]; then
                log_file_op "remove empty EFI stub directory" "$efi_dir"
                if rmdir "$efi_dir" 2>/dev/null; then
                    log_info "Removed empty EFI stub directory: $efi_dir"
                fi
            fi
        else
            log_dry_run "Would remove empty EFI stub directory: $efi_dir"
        fi
    fi
}

# Find and clean up kernel files throughout the EFI partition
find_and_cleanup_kernel_files() {
    local mount_point="$1"
    
    log_debug "Searching for EFI stub kernel files in: $mount_point"
    
    # Look for files that might be EFI stub kernels
    local potential_kernels
    potential_kernels=$(find "$mount_point" -name "*.efi" -type f 2>/dev/null | grep -E "(vmlinuz|kernel|linux|bzImage)")
    
    if [[ -n "$potential_kernels" ]]; then
        log_info "Found potential EFI stub kernels:"
        
        while IFS= read -r kernel_file; do
            if [[ -f "$kernel_file" ]]; then
                log_debug "Checking potential kernel: $kernel_file"
                
                if is_efi_stub_kernel "$kernel_file"; then
                    log_info "Confirmed EFI stub kernel: $kernel_file"
                    
                    if should_exclude_efi_stub_kernel "$kernel_file"; then
                        log_info "Excluding from cleanup: $(basename "$kernel_file")"
                        continue
                    fi
                    
                    # Create backup before removal
                    create_backup "$kernel_file" "efi-stub-kernel-$(basename "$kernel_file")"
                    
                    log_file_op "remove EFI stub kernel" "$kernel_file"
                    if [[ "${DRY_RUN:-true}" != "true" ]]; then
                        if rm "$kernel_file" 2>/dev/null; then
                            ((EFI_STUB_FILES_REMOVED++))
                        else
                            log_error "Failed to remove: $kernel_file"
                            ((EFI_STUB_ERRORS++))
                        fi
                    fi
                fi
            fi
        done <<< "$potential_kernels"
    fi
}

# Clean up files associated with EFI stub kernels
cleanup_associated_files() {
    local efi_dir="$1"
    
    log_debug "Cleaning up files associated with EFI stub kernels in: $efi_dir"
    
    # Look for initrd files
    local initrd_files
    initrd_files=$(find "$efi_dir" -name "initrd*" -o -name "initramfs*" -o -name "*.img" 2>/dev/null)
    
    if [[ -n "$initrd_files" ]]; then
        while IFS= read -r initrd_file; do
            if [[ -f "$initrd_file" ]]; then
                log_debug "Found potential initrd file: $initrd_file"
                
                # Be more conservative with initrd files - only remove if clearly associated
                if is_associated_with_efi_stub "$initrd_file"; then
                    log_file_op "remove associated initrd" "$initrd_file"
                    if [[ "${DRY_RUN:-true}" != "true" ]]; then
                        if rm "$initrd_file" 2>/dev/null; then
                            ((EFI_STUB_FILES_REMOVED++))
                        else
                            log_error "Failed to remove: $initrd_file"
                            ((EFI_STUB_ERRORS++))
                        fi
                    fi
                fi
            fi
        done <<< "$initrd_files"
    fi
    
    # Look for other associated files (device tree blobs, etc.)
    local dtb_files
    dtb_files=$(find "$efi_dir" -name "*.dtb" -o -name "*.dtbo" 2>/dev/null)
    
    if [[ -n "$dtb_files" ]]; then
        while IFS= read -r dtb_file; do
            if [[ -f "$dtb_file" ]]; then
                log_debug "Found device tree blob: $dtb_file"
                
                if is_associated_with_efi_stub "$dtb_file"; then
                    log_file_op "remove device tree blob" "$dtb_file"
                    if [[ "${DRY_RUN:-true}" != "true" ]]; then
                        if rm "$dtb_file" 2>/dev/null; then
                            ((EFI_STUB_FILES_REMOVED++))
                        else
                            log_error "Failed to remove: $dtb_file"
                            ((EFI_STUB_ERRORS++))
                        fi
                    fi
                fi
            fi
        done <<< "$dtb_files"
    fi
}

# Clean up EFI stub kernels from mounted /boot
cleanup_efi_stub_mounted_boot() {
    log_debug "Cleaning EFI stub kernels from mounted /boot"
    
    # Check common locations in /boot
    local boot_locations=(
        "/boot/EFI/Linux"
        "/boot/EFI/BOOT"
        "/boot/efi/EFI/Linux"
        "/boot/efi/EFI/BOOT"
    )
    
    for location in "${boot_locations[@]}"; do
        if [[ -d "$location" ]]; then
            cleanup_efi_stub_directory "$location"
        fi
    done
}

# Check if a file is an EFI stub kernel
is_efi_stub_kernel() {
    local file_path="$1"
    
    if [[ ! -f "$file_path" ]]; then
        return 1
    fi
    
    # Check if it's an EFI executable
    if ! file "$file_path" 2>/dev/null | grep -q "PE32+ executable"; then
        return 1
    fi
    
    # Check for EFI stub signatures in the file
    if strings "$file_path" 2>/dev/null | grep -qE "(Linux|kernel|vmlinuz)"; then
        return 0
    fi
    
    # Check for EFI stub specific strings
    if strings "$file_path" 2>/dev/null | grep -qE "(EFI stub|EFI_STUB)"; then
        return 0
    fi
    
    # Check filename patterns
    local filename
    filename=$(basename "$file_path")
    if [[ "$filename" =~ ^(vmlinuz|kernel|linux|bzImage).*\.efi$ ]]; then
        return 0
    fi
    
    return 1
}

# Check if a file should be excluded from EFI stub cleanup
should_exclude_efi_stub_kernel() {
    local kernel_file="$1"
    local kernel_name
    kernel_name=$(basename "$kernel_file")
    
    if [[ -z "${EXCLUDE_PATTERNS:-}" ]]; then
        return 1  # No exclusions
    fi
    
    # Convert space-separated patterns to array
    IFS=' ' read -ra patterns <<< "$EXCLUDE_PATTERNS"
    
    for pattern in "${patterns[@]}"; do
        if [[ "$kernel_name" == $pattern ]]; then
            log_debug "EFI stub kernel matches exclude pattern '$pattern': $kernel_name"
            return 0  # Should exclude
        fi
    done
    
    # Check for version-specific exclusions
    local kernel_version
    kernel_version=$(extract_kernel_version "$kernel_file")
    
    if [[ -n "$kernel_version" ]]; then
        for pattern in "${patterns[@]}"; do
            if [[ "$kernel_version" == $pattern ]]; then
                log_debug "EFI stub kernel version matches exclude pattern '$pattern': $kernel_version"
                return 0  # Should exclude
            fi
        done
    fi
    
    return 1  # Should not exclude
}

# Check if a file is associated with EFI stub kernels
is_associated_with_efi_stub() {
    local file_path="$1"
    local filename
    filename=$(basename "$file_path")
    local directory
    directory=$(dirname "$file_path")
    
    # If the file is in an EFI/Linux directory, it's likely associated
    if [[ "$directory" == */EFI/Linux ]]; then
        return 0
    fi
    
    # Check for naming patterns that suggest association with kernels
    if [[ "$filename" =~ ^(initrd|initramfs).*$ ]]; then
        return 0
    fi
    
    # Check for device tree blobs in kernel directories
    if [[ "$filename" =~ \.dtb$ ]] && [[ "$directory" == */EFI/* ]]; then
        return 0
    fi
    
    return 1
}

# Extract kernel version from EFI stub kernel file
extract_kernel_version() {
    local kernel_file="$1"
    
    if [[ ! -f "$kernel_file" ]]; then
        echo ""
        return 1
    fi
    
    # Try to extract version from filename
    local filename
    filename=$(basename "$kernel_file")
    
    # Look for version patterns in filename
    local version
    version=$(echo "$filename" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)*" | head -1)
    
    if [[ -n "$version" ]]; then
        echo "$version"
        return 0
    fi
    
    # Try to extract from file contents (less reliable for EFI files)
    version=$(strings "$kernel_file" 2>/dev/null | grep -oE "Linux version [0-9]+\.[0-9]+\.[0-9]+" | head -1 | cut -d' ' -f3)
    
    if [[ -n "$version" ]]; then
        echo "$version"
        return 0
    fi
    
    echo ""
    return 1
}

# List EFI stub kernels for review
list_efi_stub_kernels() {
    local efi_dir="$1"
    
    if [[ ! -d "$efi_dir" ]]; then
        return 0
    fi
    
    log_info "EFI stub kernels in $efi_dir:"
    
    local kernel_files
    kernel_files=$(find "$efi_dir" -name "*.efi" -type f 2>/dev/null)
    
    if [[ -n "$kernel_files" ]]; then
        while IFS= read -r kernel_file; do
            if is_efi_stub_kernel "$kernel_file"; then
                local kernel_name
                kernel_name=$(basename "$kernel_file")
                local kernel_version
                kernel_version=$(extract_kernel_version "$kernel_file")
                
                log_info "  $kernel_name"
                if [[ -n "$kernel_version" ]]; then
                    log_info "    Version: $kernel_version"
                fi
                
                # Show if this kernel would be excluded
                if should_exclude_efi_stub_kernel "$kernel_file"; then
                    log_info "    (EXCLUDED from cleanup)"
                fi
            fi
        done <<< "$kernel_files"
    else
        log_info "  No EFI stub kernels found"
    fi
}

# Verify EFI stub installation before cleanup
verify_efi_stub_installation() {
    local installation_path="$1"
    
    # Look for EFI stub kernels in the path
    local kernel_files
    kernel_files=$(find "$installation_path" -name "*.efi" -type f 2>/dev/null)
    
    if [[ -n "$kernel_files" ]]; then
        while IFS= read -r kernel_file; do
            if is_efi_stub_kernel "$kernel_file"; then
                return 0  # Found at least one EFI stub kernel
            fi
        done <<< "$kernel_files"
    fi
    
    return 1
}

# Get information about EFI stub kernels
get_efi_stub_info() {
    local efi_dir="$1"
    
    if [[ ! -d "$efi_dir" ]]; then
        echo "Directory not found: $efi_dir"
        return 1
    fi
    
    local kernel_count=0
    local total_size=0
    
    local kernel_files
    kernel_files=$(find "$efi_dir" -name "*.efi" -type f 2>/dev/null)
    
    if [[ -n "$kernel_files" ]]; then
        while IFS= read -r kernel_file; do
            if is_efi_stub_kernel "$kernel_file"; then
                ((kernel_count++))
                local file_size
                file_size=$(stat -c%s "$kernel_file" 2>/dev/null || echo 0)
                total_size=$((total_size + file_size))
            fi
        done <<< "$kernel_files"
    fi
    
    echo "EFI stub kernels: $kernel_count, Total size: $((total_size / 1024 / 1024)) MB"
}

# Export functions
export -f cleanup_efi_stub cleanup_efi_stub_kernels cleanup_efi_stub_directory
export -f find_and_cleanup_kernel_files cleanup_associated_files cleanup_efi_stub_mounted_boot
export -f is_efi_stub_kernel should_exclude_efi_stub_kernel is_associated_with_efi_stub
export -f extract_kernel_version list_efi_stub_kernels verify_efi_stub_installation get_efi_stub_info
