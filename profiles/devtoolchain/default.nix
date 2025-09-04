{pkgs, ...}: {
  # DuckDB + tools
  environment.systemPackages = with pkgs; [
    duckdb
    sqlite
    postgresql # client only
    pgcli
  ];
}
