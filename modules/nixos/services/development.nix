{ pkgs, ... }:
{
  # Development tools and databases
  environment.systemPackages = with pkgs; [
    duckdb
    sqlite
    postgresql # client only
    pgcli
  ];
}
