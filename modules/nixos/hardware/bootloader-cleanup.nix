# Bootloader Cleanup Enhancement for NixOS Disko Utility
# Provides functionality to detect and safely remove existing bootloaders
# during disk formatting operations
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hardware.bootloader-cleanup;
  
  # Bootloader detection and cleanup scripts
  bootloaderScripts = pkgs.writeShellScriptBin "bootloader-cleanup" ''
    set -euo pipefail
    
    # Source utility functions
    source ${pkgs.writeText "logging-utils.sh" (builtins.readFile ./scripts/logging-utils.sh)}
    source ${pkgs.writeText "safety-checks.sh" (builtins.readFile ./scripts/safety-checks.sh)}
    source ${pkgs.writeText "bootloader-detection.sh" (builtins.readFile ./scripts/bootloader-detection.sh)}
    source ${pkgs.writeText "grub-cleanup.sh" (builtins.readFile ./scripts/grub-cleanup.sh)}
    source ${pkgs.writeText "systemd-boot-cleanup.sh" (builtins.readFile ./scripts/systemd-boot-cleanup.sh)}
    source ${pkgs.writeText "efi-stub-cleanup.sh" (builtins.readFile ./scripts/efi-stub-cleanup.sh)}
    source ${pkgs.writeText "nvram-cleanup.sh" (builtins.readFile ./scripts/nvram-cleanup.sh)}
    
    # Configuration from NixOS options
    ENABLE_CLEANUP="${toString cfg.enable}"
    DRY_RUN="${toString cfg.dryRun}"
    VERBOSE="${toString cfg.verbose}"
    CLEAN_NVRAM="${toString cfg.cleanNvram}"
    TARGET_BOOTLOADERS="${concatStringsSep " " cfg.targets}"
    TARGET_DEVICE="${cfg.device}"
    
    main() {
      log_info "Starting bootloader cleanup process"
      log_info "Targets: $TARGET_BOOTLOADERS"
      log_info "Device: $TARGET_DEVICE"
      log_info "Dry run: $DRY_RUN"
      log_info "Clean NVRAM: $CLEAN_NVRAM"
      
      if [[ "$ENABLE_CLEANUP" != "true" ]]; then
        log_info "Bootloader cleanup is disabled, skipping"
        exit 0
      fi
      
      # Perform safety checks
      perform_safety_checks "$TARGET_DEVICE"
      
      # Detect existing bootloaders
      detect_bootloaders "$TARGET_DEVICE"
      
      # Clean up each target bootloader
      for bootloader in $TARGET_BOOTLOADERS; do
        case "$bootloader" in
          "grub")
            cleanup_grub "$TARGET_DEVICE"
            ;;
          "systemd-boot")
            cleanup_systemd_boot "$TARGET_DEVICE"
            ;;
          "efi-stub")
            cleanup_efi_stub "$TARGET_DEVICE"
            ;;
          *)
            log_error "Unknown bootloader type: $bootloader"
            exit 1
            ;;
        esac
      done
      
      # Clean up UEFI NVRAM entries if requested
      if [[ "$CLEAN_NVRAM" == "true" ]]; then
        cleanup_nvram_entries
      fi
      
      log_info "Bootloader cleanup completed successfully"
    }
    
    main "$@"
  '';
in {
  options.hardware.bootloader-cleanup = {
    enable = mkEnableOption "bootloader cleanup functionality";
    
    device = mkOption {
      type = types.str;
      default = "";
      description = "Target device for bootloader cleanup (e.g., /dev/sda)";
      example = "/dev/nvme0n1";
    };
    
    targets = mkOption {
      type = types.listOf (types.enum ["grub" "systemd-boot" "efi-stub"]);
      default = ["grub" "systemd-boot" "efi-stub"];
      description = "List of bootloader types to clean up";
      example = ["grub" "systemd-boot"];
    };
    
    dryRun = mkOption {
      type = types.bool;
      default = true;
      description = "Enable dry-run mode to preview cleanup operations without making changes";
    };
    
    verbose = mkOption {
      type = types.bool;
      default = true;
      description = "Enable verbose logging of cleanup operations";
    };
    
    cleanNvram = mkOption {
      type = types.bool;
      default = false;
      description = "Clean up UEFI NVRAM boot entries for removed bootloaders";
    };
    
    confirmationRequired = mkOption {
      type = types.bool;
      default = true;
      description = "Require explicit confirmation for destructive operations";
    };
    
    backupBootData = mkOption {
      type = types.bool;
      default = true;
      description = "Create backup of critical boot data before cleanup";
    };
    
    excludePatterns = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Patterns to exclude from cleanup (e.g., specific boot entries to preserve)";
      example = ["Windows*" "Recovery*"];
    };
  };
  
  config = mkIf cfg.enable {
    # Ensure required packages are available
    environment.systemPackages = with pkgs; [
      efibootmgr    # For UEFI NVRAM management
      util-linux    # For general disk utilities
      dosfstools    # For FAT filesystem operations
      efivar        # For EFI variable manipulation
      grub2         # For GRUB utilities
    ];
    
    # Add the cleanup script to system packages
    environment.systemPackages = [ bootloaderScripts ];
    
    # Create systemd service for bootloader cleanup
    systemd.services.bootloader-cleanup = {
      description = "Bootloader Cleanup Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${bootloaderScripts}/bin/bootloader-cleanup";
        StandardOutput = "journal";
        StandardError = "journal";
      };
      
      # Only run if explicitly enabled and not in dry-run mode
      enable = cfg.enable && !cfg.dryRun;
    };
    
    # Add boot parameter to enable cleanup during installation
    boot.kernelParams = mkIf cfg.enable [
      "bootloader-cleanup.enable=${toString cfg.enable}"
      "bootloader-cleanup.dry-run=${toString cfg.dryRun}"
    ];
    
    # Validation warnings
    warnings = 
      optional (cfg.enable && cfg.device == "") 
        "bootloader-cleanup is enabled but no target device specified" ++
      optional (cfg.enable && !cfg.dryRun && cfg.confirmationRequired)
        "bootloader-cleanup will perform destructive operations - ensure you have backups" ++
      optional (cfg.cleanNvram && !cfg.backupBootData)
        "NVRAM cleanup without backup is risky - consider enabling backupBootData";
    
    # Assertions for safety
    assertions = [
      {
        assertion = !cfg.enable || cfg.device != "";
        message = "bootloader-cleanup requires a target device to be specified";
      }
      {
        assertion = !cfg.enable || (length cfg.targets) > 0;
        message = "bootloader-cleanup requires at least one target bootloader";
      }
      {
        assertion = !cfg.cleanNvram || (elem "efi-stub" cfg.targets || elem "grub" cfg.targets || elem "systemd-boot" cfg.targets);
        message = "NVRAM cleanup requires at least one EFI-compatible bootloader target";
      }
    ];
  };
}
