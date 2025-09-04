# Declarative partitioning for /dev/nvme0n1
# Layout:
# - EFI 1.5GiB (vfat)
# - LUKS2 (rest) -> Btrfs subvols: @, @home, @nix, @log, @persist, @snapshots
{...}: {
  disko.devices = {
    disk.nvme0n1 = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1536MiB";
            type = "ef00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              # keyFile / ask on install; passphrase prompt at boot
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                mountpoint = "/";
                mountOptions = [
                  "compress=zstd:3"
                  "noatime"
                  "ssd"
                  "discard=async"
                ];
                subvolumes = {
                  "@".mountpoint = "/";
                  "@home".mountpoint = "/home";
                  "@nix".mountpoint = "/nix";
                  "@log".mountpoint = "/var/log";
                  "@persist".mountpoint = "/persist";
                  "@snapshots".mountpoint = "/.snapshots";
                };
              };
            };
          };
        };
      };
    };
  };
}
