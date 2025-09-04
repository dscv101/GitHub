{ pkgs, ... }:
{
  programs.niri.enable = true;

  # Waybar + Mako notifications
  programs.waybar.enable = true;
  services.mako.enable = true;

  # Loginctl linger for user daemons
  systemd.user.services."keep-alive" = {
    Service = { Type = "oneshot"; ExecStart = "${pkgs.coreutils}/bin/true"; };
    Install = { WantedBy = [ "default.target" ]; };
  };
  loginctl.linger.enable = true;
}
