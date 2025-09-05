#!/usr/bin/env bash
# GRUB bootloader cleanup implementation
# Safely removes GRUB installations from MBR and EFI partitions

# Global variables for GRUB cleanup tracking
GRUB_FILES_REMOVED=0
GRUB_ERRORS=0

# Main GRUB cleanup function
cleanup_grub() {
	local target_device="$1"

	log_section "GRUB Cleanup"
	log_info "Cleaning GRUB installations on $target_device"

	# Check if GRUB was detected
	if ! is_bootloader_detected "grub-mbr" && ! is_bootloader_detected "grub-efi" && ! is_bootloader_detected "grub-bios"; then
		log_info "No GRUB installations detected - skipping cleanup"
		return 0
	fi

	# Clean up GRUB MBR installation
	if is_bootloader_detected "grub-mbr"; then
		cleanup_grub_mbr "$target_device"
	fi

	# Clean up GRUB EFI installation
	if is_bootloader_detected "grub-efi"; then
		cleanup_grub_efi "$target_device"
	fi

	# Clean up GRUB BIOS installation
	if is_bootloader_detected "grub-bios"; then
		cleanup_grub_bios "$target_device"
	fi

	# Clean up GRUB configuration files
	cleanup_grub_configs

	# Clean up GRUB modules and themes
	cleanup_grub_modules

	log_info "GRUB cleanup completed: $GRUB_FILES_REMOVED files removed, $GRUB_ERRORS errors"
	return 0
}

# Clean up GRUB from MBR
cleanup_grub_mbr() {
	local device="$1"

	log_info "Cleaning GRUB from MBR of $device"

	# Create backup of MBR if requested
	if [[ "${BACKUP_BOOT_DATA:-true}" == "true" ]]; then
		create_backup "$device" "mbr-backup-$(basename "$device").bin"

		# Create actual MBR backup
		log_file_op "backup MBR" "$device"
		if [[ "${DRY_RUN:-true}" != "true" ]]; then
			if ! dd if="$device" of="$BACKUP_DIRECTORY/mbr-backup-$(basename "$device").bin" bs=512 count=1 2>/dev/null; then
				log_error "Failed to backup MBR from $device"
				((GRUB_ERRORS++))
			fi
		fi
	fi

	# Zero out the MBR boot code (preserve partition table)
	log_file_op "clear MBR boot code" "$device"
	if [[ "${DRY_RUN:-true}" != "true" ]]; then
		# Only clear the first 446 bytes (boot code), preserve partition table
		if dd if=/dev/zero of="$device" bs=446 count=1 2>/dev/null; then
			log_info "MBR boot code cleared on $device"
			((GRUB_FILES_REMOVED++))
		else
			log_error "Failed to clear MBR boot code on $device"
			((GRUB_ERRORS++))
		fi
	fi

	# Clean up GRUB stage1.5 from reserved sectors
	log_file_op "clear GRUB stage1.5" "$device sectors 1-62"
	if [[ "${DRY_RUN:-true}" != "true" ]]; then
		# Clear sectors 1-62 (typical location for GRUB stage1.5)
		if dd if=/dev/zero of="$device" bs=512 seek=1 count=62 2>/dev/null; then
			log_info "GRUB stage1.5 cleared from reserved sectors"
			((GRUB_FILES_REMOVED++))
		else
			log_error "Failed to clear GRUB stage1.5 from reserved sectors"
			((GRUB_ERRORS++))
		fi
	fi
}

# Clean up GRUB EFI installation
cleanup_grub_efi() {
	local target_device="$1"

	log_info "Cleaning GRUB EFI installations"

	# Find EFI partitions on the target device
	local efi_partitions
	efi_partitions=$(lsblk -no NAME,FSTYPE "$target_device" | grep -E "(vfat|fat32)" | awk '{print "/dev/"$1}')

	for partition in $efi_partitions; do
		log_debug "Checking EFI partition for GRUB: $partition"

		local temp_mount
		temp_mount=$(mktemp -d)

		if mount "$partition" "$temp_mount" 2>/dev/null; then
			# Clean up GRUB EFI directories
			cleanup_grub_efi_directory "$temp_mount/EFI/GRUB"
			cleanup_grub_efi_directory "$temp_mount/EFI/grub"
			cleanup_grub_efi_directory "$temp_mount/efi/grub"

			# Clean up GRUB from BOOT directory if it's the only bootloader there
			cleanup_grub_from_boot_directory "$temp_mount/EFI/BOOT"

			umount "$temp_mount"
		else
			log_debug "Could not mount EFI partition: $partition"
		fi

		rmdir "$temp_mount" 2>/dev/null
	done
}

# Clean up a specific GRUB EFI directory
cleanup_grub_efi_directory() {
	local grub_dir="$1"

	if [[ ! -d "$grub_dir" ]]; then
		return 0
	fi

	log_info "Cleaning GRUB EFI directory: $grub_dir"

	# Create backup of the directory
	create_backup "$grub_dir" "grub-efi-$(basename "$grub_dir")"

	# List of GRUB EFI files to remove
	local grub_efi_files=(
		"grubx64.efi"
		"grub.efi"
		"grub.cfg"
		"grubenv"
		"fonts"
		"locale"
		"themes"
		"x86_64-efi"
	)

	for file in "${grub_efi_files[@]}"; do
		local file_path="$grub_dir/$file"
		if [[ -e "$file_path" ]]; then
			if verify_file_ownership "$file_path"; then
				log_file_op "remove" "$file_path"
				if [[ "${DRY_RUN:-true}" != "true" ]]; then
					if rm -rf "$file_path" 2>/dev/null; then
						((GRUB_FILES_REMOVED++))
					else
						log_error "Failed to remove: $file_path"
						((GRUB_ERRORS++))
					fi
				fi
			fi
		fi
	done

	# Remove the directory if it's empty
	if [[ "${DRY_RUN:-true}" != "true" ]]; then
		if [[ -d "$grub_dir" ]] && [[ -z "$(ls -A "$grub_dir" 2>/dev/null)" ]]; then
			log_file_op "remove empty directory" "$grub_dir"
			if rmdir "$grub_dir" 2>/dev/null; then
				log_info "Removed empty GRUB directory: $grub_dir"
			fi
		fi
	else
		log_dry_run "Would remove empty directory: $grub_dir"
	fi
}

# Clean up GRUB from EFI/BOOT directory (carefully)
cleanup_grub_from_boot_directory() {
	local boot_dir="$1"

	if [[ ! -d "$boot_dir" ]]; then
		return 0
	fi

	log_debug "Checking EFI/BOOT directory for GRUB files: $boot_dir"

	# Only remove files that are definitely GRUB-related
	local grub_boot_files=(
		"grubx64.efi"
		"grub.efi"
	)

	for file in "${grub_boot_files[@]}"; do
		local file_path="$boot_dir/$file"
		if [[ -f "$file_path" ]]; then
			# Verify it's actually GRUB by checking file contents
			if strings "$file_path" 2>/dev/null | grep -q "GRUB"; then
				log_info "Found GRUB file in EFI/BOOT: $file_path"
				create_backup "$file_path" "boot-$(basename "$file_path")"

				log_file_op "remove GRUB file" "$file_path"
				if [[ "${DRY_RUN:-true}" != "true" ]]; then
					if rm "$file_path" 2>/dev/null; then
						((GRUB_FILES_REMOVED++))
					else
						log_error "Failed to remove: $file_path"
						((GRUB_ERRORS++))
					fi
				fi
			fi
		fi
	done
}

# Clean up GRUB BIOS installation
cleanup_grub_bios() {
	local target_device="$1"

	log_info "Cleaning GRUB BIOS installation"

	# GRUB BIOS files are typically in /boot/grub or /boot/grub2
	local grub_dirs=(
		"/boot/grub"
		"/boot/grub2"
	)

	for grub_dir in "${grub_dirs[@]}"; do
		if [[ -d "$grub_dir" ]]; then
			cleanup_grub_bios_directory "$grub_dir"
		fi
	done
}

# Clean up a GRUB BIOS directory
cleanup_grub_bios_directory() {
	local grub_dir="$1"

	log_info "Cleaning GRUB BIOS directory: $grub_dir"

	# Create backup
	create_backup "$grub_dir" "grub-bios-$(basename "$grub_dir")"

	# Files and directories to remove
	local grub_items=(
		"grub.cfg"
		"grubenv"
		"device.map"
		"fonts"
		"locale"
		"themes"
		"i386-pc"
		"x86_64-efi"
	)

	for item in "${grub_items[@]}"; do
		local item_path="$grub_dir/$item"
		if [[ -e "$item_path" ]]; then
			if verify_file_ownership "$item_path"; then
				log_file_op "remove" "$item_path"
				if [[ "${DRY_RUN:-true}" != "true" ]]; then
					if rm -rf "$item_path" 2>/dev/null; then
						((GRUB_FILES_REMOVED++))
					else
						log_error "Failed to remove: $item_path"
						((GRUB_ERRORS++))
					fi
				fi
			fi
		fi
	done

	# Remove directory if empty
	if [[ "${DRY_RUN:-true}" != "true" ]]; then
		if [[ -d "$grub_dir" ]] && [[ -z "$(ls -A "$grub_dir" 2>/dev/null)" ]]; then
			log_file_op "remove empty directory" "$grub_dir"
			if rmdir "$grub_dir" 2>/dev/null; then
				log_info "Removed empty GRUB directory: $grub_dir"
			fi
		fi
	else
		log_dry_run "Would remove empty directory: $grub_dir"
	fi
}

# Clean up GRUB configuration files
cleanup_grub_configs() {
	log_debug "Cleaning GRUB configuration files"

	# Common GRUB config locations
	local config_files=(
		"/etc/default/grub"
		"/etc/grub.d"
		"/boot/grub/grub.cfg"
		"/boot/grub2/grub.cfg"
	)

	for config_item in "${config_files[@]}"; do
		if [[ -e "$config_item" ]]; then
			# Check if this should be excluded
			if should_exclude_file "$config_item"; then
				log_info "Excluding from cleanup: $config_item"
				continue
			fi

			create_backup "$config_item" "grub-config-$(basename "$config_item")"

			log_file_op "remove GRUB config" "$config_item"
			if [[ "${DRY_RUN:-true}" != "true" ]]; then
				if rm -rf "$config_item" 2>/dev/null; then
					((GRUB_FILES_REMOVED++))
				else
					log_error "Failed to remove: $config_item"
					((GRUB_ERRORS++))
				fi
			fi
		fi
	done
}

# Clean up GRUB modules and themes
cleanup_grub_modules() {
	log_debug "Cleaning GRUB modules and themes"

	# Additional GRUB-related directories
	local grub_dirs=(
		"/usr/lib/grub"
		"/usr/share/grub"
		"/var/lib/grub"
	)

	for grub_dir in "${grub_dirs[@]}"; do
		if [[ -d "$grub_dir" ]]; then
			# Only remove if this appears to be a bootloader cleanup scenario
			# Be more conservative with system directories
			if [[ "${DRY_RUN:-true}" == "true" ]] || [[ "${CONFIRMATION_REQUIRED:-true}" == "true" ]]; then
				log_info "GRUB system directory found: $grub_dir"
				log_info "Consider manual cleanup of system GRUB files"
			else
				create_backup "$grub_dir" "grub-system-$(basename "$grub_dir")"

				log_file_op "remove GRUB system directory" "$grub_dir"
				if rm -rf "$grub_dir" 2>/dev/null; then
					((GRUB_FILES_REMOVED++))
				else
					log_error "Failed to remove: $grub_dir"
					((GRUB_ERRORS++))
				fi
			fi
		fi
	done
}

# Check if a file should be excluded from cleanup
should_exclude_file() {
	local file_path="$1"

	if [[ -z "${EXCLUDE_PATTERNS:-}" ]]; then
		return 1 # No exclusions
	fi

	# Convert space-separated patterns to array
	IFS=' ' read -ra patterns <<<"$EXCLUDE_PATTERNS"

	for pattern in "${patterns[@]}"; do
		if [[ "$(basename "$file_path")" == "$pattern" ]]; then
			return 0 # Should exclude
		fi
	done

	return 1 # Should not exclude
}

# Verify GRUB installation before cleanup
verify_grub_installation() {
	local installation_path="$1"

	# Basic verification that this is actually a GRUB installation
	if [[ -f "$installation_path/grub.cfg" ]] || [[ -f "$installation_path/grubx64.efi" ]]; then
		return 0
	fi

	# Check for GRUB-specific files
	local grub_indicators=(
		"grub"
		"GRUB"
		"stage1"
		"stage2"
	)

	for indicator in "${grub_indicators[@]}"; do
		if find "$installation_path" -name "*$indicator*" -type f 2>/dev/null | head -1 | grep -q .; then
			return 0
		fi
	done

	return 1
}

# Clean up GRUB from specific partition
cleanup_grub_partition() {
	local partition="$1"
	local mount_point="$2"

	log_info "Cleaning GRUB from partition: $partition (mounted at $mount_point)"

	# Look for GRUB installations in common locations
	local grub_locations=(
		"$mount_point/grub"
		"$mount_point/boot/grub"
		"$mount_point/EFI/GRUB"
		"$mount_point/EFI/grub"
	)

	for location in "${grub_locations[@]}"; do
		if [[ -d "$location" ]] && verify_grub_installation "$location"; then
			cleanup_grub_efi_directory "$location"
		fi
	done
}

# Export functions
export -f cleanup_grub cleanup_grub_mbr cleanup_grub_efi cleanup_grub_efi_directory
export -f cleanup_grub_from_boot_directory cleanup_grub_bios cleanup_grub_bios_directory
export -f cleanup_grub_configs cleanup_grub_modules should_exclude_file
export -f verify_grub_installation cleanup_grub_partition
