{ lib, ... }: {
  system.stateVersion = "24.05";
  boot.loader.grub.enable = false;

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "mode=0755" "size=1G" ];
  };
}
