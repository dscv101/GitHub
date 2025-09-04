{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "blazar";
  time.timeZone = "UTC";

  users.users.dscv = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  # Install system-wide packages that don't need HM modules
  environment.systemPackages = with pkgs; [
    rclone    # instead of nonexistent programs.rclone
    git
  ];

  # Minimal boot/root so evaluation succeeds during CI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # DO NOT set deprecated sound.enable; use hardware.alsa if you need ALSA userspace
  # hardware.alsa.enable = true;  # example alternative, if needed
}