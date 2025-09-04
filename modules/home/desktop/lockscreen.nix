{ pkgs, ... }:
{
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock-effects}/bin/swaylock -f --effect-blur 7x5";
      }
    ];
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.swaylock-effects}/bin/swaylock -f --effect-blur 7x5";
      } # lock after 10m
      {
        timeout = 900;
        command = "${pkgs.coreutils}/bin/true";
      } # screen off handled by DPMS via compositor
    ];
  };
}
