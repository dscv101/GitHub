{ lib, ... }:
{
  systemd.services.home-manager-dscv.serviceConfig = {
    Type = lib.mkForce "oneshot";
    Restart = lib.mkForce "no";
  };
}
