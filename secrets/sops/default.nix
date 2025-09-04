{ config, lib, pkgs, ... }:
let
  secretsDir = "/var/lib/sops-nix/secrets";
in
{
  sops = {
    age = {
      keyFile = "/var/lib/sops-nix/keys/age/keys.txt";
      generateKey = false;
    };
    defaultSopsFile = ./secrets.sops.yaml;
    validateSopsFiles = false;
    secrets = {
      RESTIC_PASSWORD = { };
      B2_ACCOUNT_ID = { };
      B2_ACCOUNT_KEY = { };
      RCLONE_CONFIG = { format = "binary"; path = "${secretsDir}/rclone.conf"; };
      TAILSCALE_AUTHKEY = { };
      MOTHERDUCK_TOKEN = { };
      GITHUB_TOKEN = { };
      GHCR_USER = { };
      GHCR_TOKEN = { };
      restic_env = { name = "restic_env"; path = "/run/secrets/restic_env"; };
    };
  };
  systemd.tmpfiles.rules = [ "f /run/secrets/restic_env 0600 root root -" ];
}
