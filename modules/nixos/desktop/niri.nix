{ pkgs, ... }:
{
  programs.niri.enable = true;

  # Waybar
  programs.waybar.enable = true;

  # Greetd + Tuigreet → Niri session
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --theme 'catppuccin' --cmd ${pkgs.niri}/bin/niri-session";
        user = "greeter";
      };
    };
  };

  # Loginctl linger for user daemons
  systemd.user.services."keep-alive" = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
    wantedBy = ["default.target"];
  };
}
