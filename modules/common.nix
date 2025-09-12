{
  lib,
  config,
  ...
}: {
  # Common configuration options for conditional loading
  options.modules = {
    desktop.enable = lib.mkEnableOption "desktop environment and applications";
    development.enable = lib.mkEnableOption "development tools and environments";
    virtualization.enable = lib.mkEnableOption "virtualization support";
    networking.enable = lib.mkEnableOption "networking configuration";
    security.enable = lib.mkEnableOption "security hardening";
  };

  # Default configurations
  config = {
    modules = {
      desktop.enable = lib.mkDefault true;
      development.enable = lib.mkDefault true;
      virtualization.enable = lib.mkDefault false;
      networking.enable = lib.mkDefault true;
      security.enable = lib.mkDefault true;
    };
  };
}

