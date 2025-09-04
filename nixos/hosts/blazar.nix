{ config, lib, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "blazar";

  # Silence warning & encode baseline expectations for this system.
  system.stateVersion = "24.05";

  # Minimal root FS for CI evaluation; replace with your real disk/disko setup on machines.
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "mode=0755" "size=2G" ];
  };

  # Old `sound.enable` is removed; if you need audio, configure PipeWire/ALSA explicitly:
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   pulse.enable = true;
  # };
  # hardware.alsa.enable = true;  # only if you need user-space ALSA specifically

  # rclone: there is no NixOS option `programs.rclone`; install it as a package:
  environment.systemPackages = with pkgs; [ rclone git vim ];

  # Ensure we don't globally force oneshot services to Restart=always.
  systemd.services.home-manager-dscv.serviceConfig = {
    Restart = lib.mkForce "no";
  };
}
