{pkgs, ...}: {
  packages = with pkgs; [
    duckdb
    sqlite
    postgresql
    pgcli
  ];
}
