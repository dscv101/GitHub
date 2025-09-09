{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.desktop.sddm;
  astronautTheme = pkgs.callPackage ../../../pkgs/sddm-themes/astronaut.nix {};
in {
  options.desktop.sddm = {
    enable = lib.mkEnableOption "Enable SDDM display manager";
    enableAstronautTheme = lib.mkEnableOption "Enable the Astronaut theme for SDDM";
  };

  config = lib.mkIf cfg.enable {
    # Enable SDDM display manager
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = lib.mkIf cfg.enableAstronautTheme "astronaut";
    };

    # Install the astronaut theme if enabled
    environment.systemPackages = lib.mkIf cfg.enableAstronautTheme [
      astronautTheme
    ];

    # Ensure SDDM can find the theme
    systemd.tmpfiles.rules = lib.mkIf cfg.enableAstronautTheme [
      "L+ /run/current-system/sw/share/sddm/themes/astronaut - - - - ${astronautTheme}/share/sddm/themes/astronaut"
    ];

    # Disable greetd if SDDM is enabled (they conflict)
    services.greetd.enable = lib.mkForce false;
  };
}
