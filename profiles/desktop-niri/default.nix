{pkgs, ...}: {
  programs.niri.enable = true;

  # Waybar
  programs.waybar.enable = true;

  # Loginctl linger for user daemons
  systemd.user.services."keep-alive" = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
    wantedBy = ["default.target"];
  };
}
