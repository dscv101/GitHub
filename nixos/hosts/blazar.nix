{ config, pkgs, lib, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "blazar";

  # Provide a root FS so evaluation works in CI (no real disks needed).
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "mode=0755" "size=512M" ];
  };

  # Users
  users.users.dscv = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    home = "/home/dscv";
  };

  # Basic packages (include rclone as a package rather than the non-existent programs.rclone option)
  environment.systemPackages = with pkgs; [
    git
    vim
    rclone
  ];

  services.openssh.enable = true;

  # Avoid the oneshot+restart issue seen in logs by explicitly ensuring no restart.
  systemd.services.home-manager-dscv.serviceConfig = {
    Type = "oneshot";
    Restart = "no";
  };

  # Pin the state version to avoid warnings and unintended migrations.
  system.stateVersion = "24.05";
}
