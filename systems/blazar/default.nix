{pkgs, ...}: {
  imports = [
    ./disko.nix
  ];

  system.stateVersion = "24.11";

  # Host-specific networking
  networking.hostName = "blazar";

  # Locale and timezone
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  # X server configuration (disabled for Wayland)
  services.xserver = {
    enable = false;
    xkb.layout = "us";
    xkb.variant = "";
    videoDrivers = ["nvidia"];
  };

  # User configuration
  users.users.dscv = {
    isNormalUser = true;
    description = "Derek Vitrano";
    extraGroups = ["wheel" "networkmanager" "audio" "video"];
    shell = pkgs.zsh;
    linger = true;
  };

  # Boot & kernel configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.luks.devices.cryptroot.device = "/dev/disk/by-partlabel/luks";
    # Use the latest kernel packages
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "nvidia_drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "amd_iommu=on"
      "iommu=pt"
    ];
    plymouth = {
      enable = true;
      theme = "bgrt"; # theme tweaked later by HM/wayland look
    };
  };

  # Root filesystem (disko should handle this, but NixOS requires explicit definition)
  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = ["subvol=@" "compress=zstd:3" "noatime" "ssd" "discard=async"];
  };

  # Persist filesystem for impermanence
  fileSystems."/persist" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = ["subvol=@persist" "compress=zstd:3" "noatime" "ssd" "discard=async"];
    neededForBoot = true;
  };

  # System maintenance
  system.autoUpgrade.enable = false; # per user preference
}
