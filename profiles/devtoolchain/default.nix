{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    duckdb sqlite postgresql pgcli
  ];
}
