#!/usr/bin/env bash
# Bootloader detection utilities
# Detects existing bootloaders on target devices and partitions

# Global arrays to store detected bootloaders
declare -A DETECTED_BOOTLOADERS
declare -A BOOTLOADER_LOCATIONS
declare -A BOOTLOADER_VERSIONS

# Main bootloader detection function
detect_bootloaders() {
	local target_device="$1"

	log_section "Bootloader Detection"
	log_info "Scanning device: $target_device"

	# Initialize detection arrays
	DETECTED_BOOTLOADERS=()
	BOOTLOADER_LOCATIONS=()
	BOOTLOADER_VERSIONS=()

	# Detect GRUB installations
	detect_grub_installations "$target_device"

	# Detect systemd-boot installations
	detect_systemd_boot_installations "$target_device"

	# Detect EFI stub installations
	detect_efi_stub_installations "$target_device"

	# Detect other bootloaders
	detect_other_bootloaders "$target_device"

	# Summary of detected bootloaders
	log_detection_summary

	return 0
}

# Detect GRUB installations (both BIOS and EFI)
detect_grub_installations() {
	local device="$1"

	log_debug "Detecting GRUB installations on $device"

	# Check for GRUB in MBR (BIOS mode)
	detect_grub_mbr "$device"

	# Check for GRUB EFI installations
	detect_grub_efi "$device"

	# Check for GRUB configuration files
	detect_grub_configs "$device"
}

# Detect GRUB in MBR
detect_grub_mbr() {
	local device="$1"

	log_debug "Checking for GRUB in MBR of $device"

	# Read the first 512 bytes (MBR) and look for GRUB signature
	if command -v hexdump >/dev/null 2>&1; then
		local mbr_content
		mbr_content=$(dd if="$device" bs=512 count=1 2>/dev/null | hexdump -C)

		# Look for GRUB stage1 signatures
		if echo "$mbr_content" | grep -q "GRUB"; then
			log_info "GRUB detected in MBR of $device"
			DETECTED_BOOTLOADERS["grub-mbr"]="$device"
			BOOTLOADER_LOCATIONS["grub-mbr"]="MBR sector 0"

			# Try to determine GRUB version from MBR
			local grub_version
			grub_version=$(echo "$mbr_content" | grep -o "GRUB [0-9.]*" | head -1)
			BOOTLOADER_VERSIONS["grub-mbr"]="${grub_version:-unknown}"
		fi
	fi

	# Alternative method: check for GRUB stage1.5 in reserved sectors
	local stage15_sectors
	stage15_sectors=$(dd if="$device" bs=512 skip=1 count=62 2>/dev/null | strings | grep -i grub)

	if [[ -n "$stage15_sectors" ]]; then
		log_info "GRUB stage1.5 detected in reserved sectors of $device"
		if [[ -z "${DETECTED_BOOTLOADERS["grub-mbr"]:-}" ]]; then
			DETECTED_BOOTLOADERS["grub-mbr"]="$device"
			BOOTLOADER_LOCATIONS["grub-mbr"]="Reserved sectors 1-62"
		fi
	fi
}

# Detect GRUB EFI installations
detect_grub_efi() {
	local device="$1"

	log_debug "Checking for GRUB EFI installations on $device"

	# Mount EFI partitions and check for GRUB
	local efi_partitions
	efi_partitions=$(lsblk -no NAME,FSTYPE "$device" | grep -E "(vfat|fat32)" | awk '{print "/dev/"$1}')

	for partition in $efi_partitions; do
		log_debug "Checking EFI partition: $partition"

		# Create temporary mount point
		local temp_mount
		temp_mount=$(mktemp -d)

		if mount "$partition" "$temp_mount" 2>/dev/null; then
			# Check for GRUB EFI binaries
			local grub_efi_paths=(
				"$temp_mount/EFI/GRUB/grubx64.efi"
				"$temp_mount/EFI/grub/grubx64.efi"
				"$temp_mount/EFI/BOOT/grubx64.efi"
				"$temp_mount/efi/grub/grubx64.efi"
			)

			for grub_path in "${grub_efi_paths[@]}"; do
				if [[ -f "$grub_path" ]]; then
					log_info "GRUB EFI binary found: $grub_path"
					DETECTED_BOOTLOADERS["grub-efi"]="$partition"
					BOOTLOADER_LOCATIONS["grub-efi"]="$grub_path"

					# Try to get version information
					local version_info
					version_info=$(strings "$grub_path" | grep -i "grub.*version" | head -1)
					BOOTLOADER_VERSIONS["grub-efi"]="${version_info:-unknown}"
					break
				fi
			done

			# Check for GRUB configuration files
			local grub_cfg_paths=(
				"$temp_mount/EFI/GRUB/grub.cfg"
				"$temp_mount/EFI/grub/grub.cfg"
				"$temp_mount/boot/grub/grub.cfg"
			)

			for cfg_path in "${grub_cfg_paths[@]}"; do
				if [[ -f "$cfg_path" ]]; then
					log_debug "GRUB config found: $cfg_path"
					if [[ -z "${BOOTLOADER_LOCATIONS["grub-efi"]:-}" ]]; then
						DETECTED_BOOTLOADERS["grub-efi"]="$partition"
						BOOTLOADER_LOCATIONS["grub-efi"]="$cfg_path"
					fi
				fi
			done

			umount "$temp_mount"
		else
			log_debug "Could not mount EFI partition: $partition"
		fi

		rmdir "$temp_mount" 2>/dev/null
	done
}

# Detect GRUB configuration files on mounted filesystems
detect_grub_configs() {
	local device="$1"

	log_debug "Checking for GRUB configuration files"

	# Common GRUB config locations
	local grub_config_paths=(
		"/boot/grub/grub.cfg"
		"/boot/grub2/grub.cfg"
		"/boot/efi/EFI/GRUB/grub.cfg"
		"/boot/EFI/GRUB/grub.cfg"
	)

	for config_path in "${grub_config_paths[@]}"; do
		if [[ -f "$config_path" ]]; then
			log_info "GRUB configuration found: $config_path"

			# Determine if this is BIOS or EFI GRUB based on path
			local grub_type="grub-bios"
			if [[ "$config_path" == *"efi"* ]] || [[ "$config_path" == *"EFI"* ]]; then
				grub_type="grub-efi"
			fi

			if [[ -z "${DETECTED_BOOTLOADERS[$grub_type]:-}" ]]; then
				DETECTED_BOOTLOADERS[$grub_type]="$device"
				BOOTLOADER_LOCATIONS[$grub_type]="$config_path"
			fi

			# Extract version from config file
			local version_line
			version_line=$(grep -m1 "# GRUB" "$config_path" 2>/dev/null || echo "")
			if [[ -n "$version_line" ]]; then
				BOOTLOADER_VERSIONS[$grub_type]="$version_line"
			fi
		fi
	done
}

# Detect systemd-boot installations
detect_systemd_boot_installations() {
	local device="$1"

	log_debug "Detecting systemd-boot installations on $device"

	# Check for systemd-boot on EFI partitions
	local efi_partitions
	efi_partitions=$(lsblk -no NAME,FSTYPE "$device" | grep -E "(vfat|fat32)" | awk '{print "/dev/"$1}')

	for partition in $efi_partitions; do
		log_debug "Checking EFI partition for systemd-boot: $partition"

		local temp_mount
		temp_mount=$(mktemp -d)

		if mount "$partition" "$temp_mount" 2>/dev/null; then
			# Check for systemd-boot EFI binary
			local systemd_boot_paths=(
				"$temp_mount/EFI/systemd/systemd-bootx64.efi"
				"$temp_mount/EFI/BOOT/bootx64.efi"
				"$temp_mount/EFI/Boot/bootx64.efi"
			)

			for boot_path in "${systemd_boot_paths[@]}"; do
				if [[ -f "$boot_path" ]]; then
					# Verify it's actually systemd-boot by checking strings
					if strings "$boot_path" | grep -q "systemd-boot"; then
						log_info "systemd-boot binary found: $boot_path"
						DETECTED_BOOTLOADERS["systemd-boot"]="$partition"
						BOOTLOADER_LOCATIONS["systemd-boot"]="$boot_path"

						# Get version information
						local version_info
						version_info=$(strings "$boot_path" | grep -E "systemd-boot [0-9]+" | head -1)
						BOOTLOADER_VERSIONS["systemd-boot"]="${version_info:-unknown}"
						break
					fi
				fi
			done

			# Check for systemd-boot loader configuration
			if [[ -f "$temp_mount/loader/loader.conf" ]]; then
				log_info "systemd-boot loader config found: $temp_mount/loader/loader.conf"
				if [[ -z "${DETECTED_BOOTLOADERS["systemd-boot"]:-}" ]]; then
					DETECTED_BOOTLOADERS["systemd-boot"]="$partition"
					BOOTLOADER_LOCATIONS["systemd-boot"]="$temp_mount/loader/loader.conf"
				fi
			fi

			# Check for boot entries
			if [[ -d "$temp_mount/loader/entries" ]]; then
				local entry_count
				entry_count=$(find "$temp_mount/loader/entries" -name "*.conf" | wc -l)
				if [[ $entry_count -gt 0 ]]; then
					log_info "Found $entry_count systemd-boot entries in $temp_mount/loader/entries"
				fi
			fi

			umount "$temp_mount"
		fi

		rmdir "$temp_mount" 2>/dev/null
	done

	# Also check mounted /boot for systemd-boot
	if [[ -f /boot/loader/loader.conf ]]; then
		log_info "systemd-boot configuration found in /boot/loader/loader.conf"
		DETECTED_BOOTLOADERS["systemd-boot"]="/boot"
		BOOTLOADER_LOCATIONS["systemd-boot"]="/boot/loader/loader.conf"
	fi
}

# Detect EFI stub installations
detect_efi_stub_installations() {
	local device="$1"

	log_debug "Detecting EFI stub installations on $device"

	# EFI stub bootloaders are typically kernel images with EFI stub support
	# Check UEFI boot entries for direct kernel boots
	if [[ "$BOOT_MODE" == "UEFI" ]] && command -v efibootmgr >/dev/null 2>&1; then
		local efi_entries
		efi_entries=$(efibootmgr -v 2>/dev/null)

		# Look for entries that point directly to kernel files
		while IFS= read -r line; do
			if [[ "$line" =~ Boot[0-9A-F]{4}\*.*\.efi ]]; then
				# Check if this looks like a kernel EFI stub
				if echo "$line" | grep -qE "(vmlinuz|kernel|linux).*\.efi"; then
					log_info "EFI stub entry detected: $line"
					DETECTED_BOOTLOADERS["efi-stub"]="UEFI NVRAM"
					BOOTLOADER_LOCATIONS["efi-stub"]="$line"

					# Extract kernel version if possible
					local kernel_version
					kernel_version=$(echo "$line" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -1)
					BOOTLOADER_VERSIONS["efi-stub"]="Kernel ${kernel_version:-unknown}"
				fi
			fi
		done <<<"$efi_entries"
	fi

	# Check EFI partitions for kernel EFI files
	local efi_partitions
	efi_partitions=$(lsblk -no NAME,FSTYPE "$device" | grep -E "(vfat|fat32)" | awk '{print "/dev/"$1}')

	for partition in $efi_partitions; do
		local temp_mount
		temp_mount=$(mktemp -d)

		if mount "$partition" "$temp_mount" 2>/dev/null; then
			# Look for kernel EFI files
			local kernel_efi_files
			kernel_efi_files=$(find "$temp_mount" -name "*.efi" -type f 2>/dev/null | grep -E "(vmlinuz|kernel|linux)")

			if [[ -n "$kernel_efi_files" ]]; then
				while IFS= read -r kernel_file; do
					log_info "EFI stub kernel found: $kernel_file"
					DETECTED_BOOTLOADERS["efi-stub"]="$partition"
					BOOTLOADER_LOCATIONS["efi-stub"]="$kernel_file"

					# Try to extract version from filename
					local version
					version=$(basename "$kernel_file" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
					BOOTLOADER_VERSIONS["efi-stub"]="Kernel ${version:-unknown}"
				done <<<"$kernel_efi_files"
			fi

			umount "$temp_mount"
		fi

		rmdir "$temp_mount" 2>/dev/null
	done
}

# Detect other bootloaders (rEFInd, Clover, etc.)
detect_other_bootloaders() {
	local device="$1"

	log_debug "Detecting other bootloaders on $device"

	local efi_partitions
	efi_partitions=$(lsblk -no NAME,FSTYPE "$device" | grep -E "(vfat|fat32)" | awk '{print "/dev/"$1}')

	for partition in $efi_partitions; do
		local temp_mount
		temp_mount=$(mktemp -d)

		if mount "$partition" "$temp_mount" 2>/dev/null; then
			# Check for rEFInd
			if [[ -f "$temp_mount/EFI/refind/refind_x64.efi" ]]; then
				log_info "rEFInd bootloader detected: $temp_mount/EFI/refind/refind_x64.efi"
				DETECTED_BOOTLOADERS["refind"]="$partition"
				BOOTLOADER_LOCATIONS["refind"]="$temp_mount/EFI/refind/refind_x64.efi"
			fi

			# Check for Clover
			if [[ -f "$temp_mount/EFI/CLOVER/CLOVERX64.efi" ]]; then
				log_info "Clover bootloader detected: $temp_mount/EFI/CLOVER/CLOVERX64.efi"
				DETECTED_BOOTLOADERS["clover"]="$partition"
				BOOTLOADER_LOCATIONS["clover"]="$temp_mount/EFI/CLOVER/CLOVERX64.efi"
			fi

			# Check for Windows Boot Manager
			if [[ -f "$temp_mount/EFI/Microsoft/Boot/bootmgfw.efi" ]]; then
				log_info "Windows Boot Manager detected: $temp_mount/EFI/Microsoft/Boot/bootmgfw.efi"
				DETECTED_BOOTLOADERS["windows"]="$partition"
				BOOTLOADER_LOCATIONS["windows"]="$temp_mount/EFI/Microsoft/Boot/bootmgfw.efi"
			fi

			umount "$temp_mount"
		fi

		rmdir "$temp_mount" 2>/dev/null
	done
}

# Log summary of detected bootloaders
log_detection_summary() {
	log_section "Detection Summary"

	if [[ ${#DETECTED_BOOTLOADERS[@]} -eq 0 ]]; then
		log_info "No bootloaders detected"
		return 0
	fi

	log_info "Detected ${#DETECTED_BOOTLOADERS[@]} bootloader(s):"

	for bootloader in "${!DETECTED_BOOTLOADERS[@]}"; do
		local device="${DETECTED_BOOTLOADERS[$bootloader]}"
		local location="${BOOTLOADER_LOCATIONS[$bootloader]:-unknown}"
		local version="${BOOTLOADER_VERSIONS[$bootloader]:-unknown}"

		log_info "  $bootloader:"
		log_info "    Device: $device"
		log_info "    Location: $location"
		log_info "    Version: $version"
	done
}

# Check if a specific bootloader was detected
is_bootloader_detected() {
	local bootloader_type="$1"
	[[ -n "${DETECTED_BOOTLOADERS[$bootloader_type]:-}" ]]
}

# Get detected bootloader information
get_bootloader_info() {
	local bootloader_type="$1"
	local info_type="$2" # device, location, or version

	case "$info_type" in
	"device")
		echo "${DETECTED_BOOTLOADERS[$bootloader_type]:-}"
		;;
	"location")
		echo "${BOOTLOADER_LOCATIONS[$bootloader_type]:-}"
		;;
	"version")
		echo "${BOOTLOADER_VERSIONS[$bootloader_type]:-}"
		;;
	*)
		log_error "Invalid info type: $info_type"
		return 1
		;;
	esac
}

# Export functions and arrays
export -f detect_bootloaders detect_grub_installations detect_grub_mbr detect_grub_efi
export -f detect_grub_configs detect_systemd_boot_installations detect_efi_stub_installations
export -f detect_other_bootloaders log_detection_summary is_bootloader_detected get_bootloader_info
