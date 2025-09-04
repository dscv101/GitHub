{pkgs, ...}: {
  home.packages = [
    # SQL tooling
    pkgs.duckdb
    pkgs.sqlite
    pkgs.postgresql
    pkgs.pgcli
  ];
}
