{pkgs, ...}: {
  # Development tools and databases
  environment.systemPackages = [
    pkgs.duckdb
    pkgs.sqlite
    pkgs.postgresql # client only
    pkgs.pgcli
  ];
}
