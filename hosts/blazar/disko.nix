{ lib, ... }:
{
  # Generate fileSystems/swapDevices from the layout:
  disko.enableConfig = true;

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/DEVICE_REPLACE_ME"; # replace on install (e.g., nvme0n1 or by-id)
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "ef00";
          size = "1536MiB"; # 1.5 GiB
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "fmask=0022" "dmask=0022" ];
            extraArgs = [ "-n" "EFI" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" "-L" "nixos" ];
            subvolumes = {
              "@root" = {
                mountpoint = "/";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "@persist" = {
                mountpoint = "/persist";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
            };
          };
        };
      };
    };
  };
}
