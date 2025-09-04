{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # SQL tooling
    duckdb
    sqlite
    postgresql
    pgcli
  ];
}
