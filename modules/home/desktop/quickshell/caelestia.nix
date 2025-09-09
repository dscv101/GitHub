{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.programs.caelestia;
in {
  options.programs.caelestia = {
    enable = lib.mkEnableOption "Caelestia quickshell configuration";

    systemd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable systemd service for caelestia shell";
      };

      target = lib.mkOption {
        type = lib.types.str;
        default = "graphical-session.target";
        description = "Systemd target for caelestia shell service";
      };

      environment = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Environment variables for systemd service";
      };
    };

    settings = {
      bar.status = {
        showBattery = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Show battery status in the bar";
        };
      };

      paths.wallpaperDir = lib.mkOption {
        type = lib.types.str;
        default = "~/Images";
        description = "Directory containing wallpapers";
      };
    };

    cli = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable caelestia CLI tools";
      };

      settings = {
        theme.enableGtk = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable GTK theme integration";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Install caelestia shell from the flake input
    home.packages = with pkgs; [
      # Add quickshell as a dependency
      # Note: This assumes quickshell is available in nixpkgs
      # If not, it would need to be built from the caelestia-shell input
    ] ++ lib.optionals cfg.cli.enable [
      # Add caelestia CLI tools when enabled
    ];

    # Create configuration directory and files
    xdg.configFile = {
      "caelestia/shell.json" = {
        text = builtins.toJSON {
          bar.status.showBattery = cfg.settings.bar.status.showBattery;
          paths.wallpaperDir = cfg.settings.paths.wallpaperDir;
          cli.theme.enableGtk = cfg.cli.settings.theme.enableGtk;
        };
      };
    };

    # Systemd service configuration
    systemd.user.services.caelestia-shell = lib.mkIf cfg.systemd.enable {
      Unit = {
        Description = "Caelestia Quickshell";
        After = [ cfg.systemd.target ];
        Wants = [ cfg.systemd.target ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.quickshell}/bin/quickshell -c caelestia";
        Restart = "on-failure";
        RestartSec = 3;
        Environment = cfg.systemd.environment;
      };

      Install = {
        WantedBy = [ cfg.systemd.target ];
      };
    };

    # Add quickshell configuration directory
    xdg.configFile."quickshell/caelestia" = {
      source = inputs.caelestia-shell;
      recursive = true;
    };
  };
}
