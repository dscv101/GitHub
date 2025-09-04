{ pkgs, ... }:
{
  # Backups: restic + rclone (unit + timer)
  # Env/secrets supplied by sops-nix at runtime
  systemd.services."restic-backup" = {
    description = "Restic backup to B2 via rclone";
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = "/run/secrets/restic_env"; # provided by sops (B2 creds + RESTIC_PASSWORD)
      ExecStart = "${pkgs.restic}/bin/restic backup --repo rclone:b2-blazar:nixos/blazar \
        --exclude-file=/etc/restic/excludes.txt \
        /home/dscv/dev /home/dscv/.config/Code /home/dscv/.config/ghostty /home/dscv/.ssh";
      ExecStartPost = "${pkgs.restic}/bin/restic forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --repo rclone:b2-blazar:nixos/blazar";
    };
    wants = ["network-online.target"];
    after = ["network-online.target"];
  };
  
  systemd.timers."restic-backup" = {
    wantedBy = ["timers.target"];
    timerConfig.OnCalendar = "daily 03:30";
    unitConfig.Description = "Daily Restic backup";
  };
}
