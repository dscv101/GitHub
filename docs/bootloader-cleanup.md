# Bootloader Cleanup Enhancement for NixOS Disko Utility

This document describes the bootloader cleanup functionality that extends the NixOS disko utility to safely detect and remove existing bootloaders during disk formatting operations.

## Overview

The bootloader cleanup enhancement provides functionality to:

- **Detect existing bootloaders** (GRUB, systemd-boot, EFI stub) on target devices
- **Safely remove bootloader installations** from MBR and EFI partitions  
- **Clean up UEFI NVRAM entries** for removed bootloaders
- **Provide comprehensive logging** and dry-run capabilities
- **Handle edge cases** like encrypted partitions, RAID arrays, and LVM configurations

## Features

### Supported Bootloaders

- **GRUB** (both BIOS/MBR and EFI installations)
- **systemd-boot** (EFI installations and configurations)
- **EFI stub** (direct kernel EFI boots)

### Safety Features

- **Dry-run mode** - Preview all operations without making changes
- **Comprehensive backup** - Automatic backup of critical boot data
- **Safety checks** - Verification of system state before operations
- **Exclude patterns** - Protect specific boot entries from cleanup
- **UEFI NVRAM backup** - Backup and restore NVRAM boot entries

### Detection Capabilities

- **MBR scanning** - Detect GRUB installations in Master Boot Record
- **EFI partition analysis** - Scan EFI System Partitions for bootloaders
- **NVRAM enumeration** - List and analyze UEFI boot entries
- **File system inspection** - Identify bootloader files and configurations

## Configuration

### Basic Configuration

Enable bootloader cleanup in your NixOS configuration:

```nix
{
  hardware.bootloader-cleanup = {
    enable = true;
    device = "/dev/nvme0n1";
    targets = [ "grub" "systemd-boot" "efi-stub" ];
    dryRun = true;  # Start with dry-run for safety
    verbose = true;
    cleanNvram = false;  # Enable after testing
  };
}
```

### Disko Integration

Integrate with disko configuration for automated cleanup during formatting:

```nix
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              # Bootloader cleanup configuration
              bootloader-cleanup = {
                enable = true;
                targets = [ "grub" "systemd-boot" "efi-stub" ];
                clean-nvram = true;
                dry-run = false;
                verbose = true;
              };
            };
          };
        };
      };
    };
  };
}
```

### Advanced Configuration

```nix
{
  hardware.bootloader-cleanup = {
    enable = true;
    device = "/dev/sda";
    targets = [ "grub" "systemd-boot" ];
    
    # Safety settings
    dryRun = false;
    confirmationRequired = true;
    backupBootData = true;
    
    # Logging
    verbose = true;
    
    # NVRAM management
    cleanNvram = true;
    
    # Exclusions
    excludePatterns = [ "Windows*" "Recovery*" "UEFI*" ];
  };
}
```

## Configuration Options

### Core Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable bootloader cleanup functionality |
| `device` | string | `""` | Target device for cleanup (e.g., `/dev/sda`) |
| `targets` | list | `["grub" "systemd-boot" "efi-stub"]` | Bootloader types to clean up |

### Safety Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `dryRun` | bool | `true` | Preview operations without making changes |
| `confirmationRequired` | bool | `true` | Require explicit confirmation for destructive operations |
| `backupBootData` | bool | `true` | Create backup of critical boot data |
| `excludePatterns` | list | `[]` | Patterns to exclude from cleanup |

### Logging Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `verbose` | bool | `true` | Enable verbose logging |

### NVRAM Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `cleanNvram` | bool | `false` | Clean up UEFI NVRAM boot entries |

## Usage Examples

### Basic Cleanup (Dry Run)

```bash
# Enable the module and run a dry-run
sudo systemctl start bootloader-cleanup
```

### Manual Execution

```bash
# Run the cleanup script directly
sudo bootloader-cleanup
```

### Check Current Bootloaders

```bash
# View detected bootloaders without cleanup
sudo bootloader-cleanup --detect-only
```

## Safety Considerations

### Pre-Cleanup Checklist

1. **Backup your system** - Ensure you have a complete system backup
2. **Test in dry-run mode** - Always test with `dryRun = true` first
3. **Verify target device** - Double-check the device path is correct
4. **Review exclude patterns** - Ensure critical boot entries are excluded
5. **Check UEFI settings** - Verify UEFI firmware settings if using NVRAM cleanup

### Risk Mitigation

- **Automatic backups** - All critical boot data is backed up before cleanup
- **Safety checks** - System validates configuration before proceeding
- **Exclude patterns** - Protect Windows Boot Manager and other critical entries
- **Boot order preservation** - UEFI boot order is validated and corrected
- **Rollback capability** - Backup files can be used for manual recovery

### Recovery Procedures

If something goes wrong during cleanup:

1. **Boot from rescue media** - Use NixOS installation media or rescue disk
2. **Mount your system** - Mount root and boot partitions
3. **Restore from backup** - Use backup files created during cleanup
4. **Reinstall bootloader** - Use `nixos-rebuild` to reinstall bootloader
5. **Fix UEFI entries** - Use `efibootmgr` to restore NVRAM entries

## Troubleshooting

### Common Issues

#### "No bootloaders detected"
- Verify the target device is correct
- Check if bootloaders are on a different device
- Ensure you have root privileges

#### "Failed to mount EFI partition"
- Check if EFI partition is already mounted
- Verify partition is not corrupted
- Ensure sufficient permissions

#### "NVRAM cleanup failed"
- Verify system is in UEFI mode
- Check if `efibootmgr` is installed
- Ensure EFI variables are writable

### Debug Mode

Enable debug logging for troubleshooting:

```nix
{
  hardware.bootloader-cleanup = {
    enable = true;
    verbose = true;
    # ... other options
  };
}
```

### Log Files

Cleanup operations are logged to:
- **System journal**: `journalctl -u bootloader-cleanup`
- **Console output**: Real-time progress and status
- **Backup directory**: `/tmp/bootloader-cleanup-backup-*`

## Architecture

### Module Structure

```
modules/nixos/hardware/bootloader-cleanup.nix    # Main module
├── scripts/
│   ├── logging-utils.sh                         # Logging utilities
│   ├── safety-checks.sh                         # Safety validation
│   ├── bootloader-detection.sh                  # Detection logic
│   ├── grub-cleanup.sh                          # GRUB cleanup
│   ├── systemd-boot-cleanup.sh                  # systemd-boot cleanup
│   ├── efi-stub-cleanup.sh                      # EFI stub cleanup
│   └── nvram-cleanup.sh                         # NVRAM management
```

### Execution Flow

1. **Safety Checks** - Validate system state and permissions
2. **Detection Phase** - Scan for existing bootloaders
3. **Backup Creation** - Create backups of critical data
4. **Cleanup Execution** - Remove detected bootloaders
5. **NVRAM Management** - Clean up UEFI boot entries
6. **Verification** - Validate cleanup results

### Integration Points

- **NixOS Module System** - Integrated as hardware module
- **Disko Configuration** - Extended disko syntax support
- **systemd Services** - Automated execution via systemd
- **Boot Process** - Kernel parameters for installation-time cleanup

## Development

### Testing

The module includes comprehensive testing capabilities:

```bash
# Run in dry-run mode
sudo bootloader-cleanup --dry-run

# Test specific bootloader cleanup
sudo bootloader-cleanup --targets grub --dry-run

# Test NVRAM operations
sudo bootloader-cleanup --clean-nvram --dry-run
```

### Contributing

When contributing to the bootloader cleanup functionality:

1. **Follow safety-first principles** - All operations must be reversible
2. **Add comprehensive tests** - Test edge cases and error conditions
3. **Update documentation** - Keep this document current
4. **Maintain compatibility** - Ensure backward compatibility with existing configurations

### Code Style

- **Shell scripts** follow bash best practices with `set -euo pipefail`
- **Nix code** follows nixpkgs style guidelines
- **Documentation** uses clear, actionable language
- **Error handling** provides helpful error messages and recovery suggestions

## Limitations

### Current Limitations

- **Windows Boot Manager** - Not cleaned up (by design for safety)
- **Custom bootloaders** - May not detect proprietary bootloaders
- **Network boot** - PXE and network boot configurations not handled
- **Secure Boot** - May require additional steps with Secure Boot enabled

### Future Enhancements

- **Additional bootloader support** - rEFInd, Clover, etc.
- **GUI interface** - Graphical configuration and monitoring
- **Advanced scheduling** - Cron-based cleanup scheduling
- **Integration testing** - Automated testing in virtual environments

## Security Considerations

### Permissions

The bootloader cleanup functionality requires:
- **Root privileges** - For disk and NVRAM operations
- **EFI variable access** - For NVRAM cleanup operations
- **Mount permissions** - For EFI partition access

### Audit Trail

All operations are logged with:
- **Timestamps** - When operations occurred
- **User context** - Who initiated the cleanup
- **Operation details** - What was cleaned up
- **Backup locations** - Where backups were stored

### Data Protection

- **Backup encryption** - Consider encrypting backup files
- **Secure deletion** - Use secure deletion for sensitive data
- **Access controls** - Restrict access to backup directories

## Support

### Getting Help

- **NixOS Manual** - Check the official NixOS documentation
- **Community Forums** - Ask questions on NixOS Discourse
- **Issue Tracker** - Report bugs and feature requests
- **IRC/Matrix** - Real-time help from the community

### Reporting Issues

When reporting issues, include:
- **System information** - NixOS version, hardware details
- **Configuration** - Your bootloader-cleanup configuration
- **Log output** - Relevant log messages and errors
- **Steps to reproduce** - How to reproduce the issue

---

**Last Updated**: 2024-09-04
**Version**: 1.0.0
**Compatibility**: NixOS 24.11+
