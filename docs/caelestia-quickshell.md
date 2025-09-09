# Caelestia Quickshell Configuration

This document describes how to configure and use the Caelestia quickshell in this NixOS flake.

## Overview

The Caelestia shell is a beautiful desktop shell built with [Quickshell](https://quickshell.outfoxxed.me) and designed for Wayland compositors like Hyprland. This flake includes a Home Manager module that makes it easy to configure and deploy the Caelestia shell.

## Configuration

The Caelestia shell is configured through the `programs.caelestia` option in your Home Manager configuration.

### Basic Configuration

```nix
{
  programs.caelestia = {
    enable = true;
    systemd = {
      enable = false; # if you prefer starting from your compositor
      target = "graphical-session.target";
      environment = [];
    };
    settings = {
      bar.status = {
        showBattery = false;
      };
      paths.wallpaperDir = "~/Images";
    };
    cli = {
      enable = true; # Also add caelestia-cli to path
      settings = {
        theme.enableGtk = false;
      };
    };
  };
}
```

### Configuration Options

#### `programs.caelestia.enable`
- **Type**: boolean
- **Default**: false
- **Description**: Enable the Caelestia quickshell configuration

#### `programs.caelestia.systemd.enable`
- **Type**: boolean
- **Default**: false
- **Description**: Enable systemd service for caelestia shell. Set to false if you prefer starting from your compositor.

#### `programs.caelestia.systemd.target`
- **Type**: string
- **Default**: "graphical-session.target"
- **Description**: Systemd target for caelestia shell service

#### `programs.caelestia.systemd.environment`
- **Type**: list of strings
- **Default**: []
- **Description**: Environment variables for systemd service

#### `programs.caelestia.settings.bar.status.showBattery`
- **Type**: boolean
- **Default**: false
- **Description**: Show battery status in the bar

#### `programs.caelestia.settings.paths.wallpaperDir`
- **Type**: string
- **Default**: "~/Images"
- **Description**: Directory containing wallpapers

#### `programs.caelestia.cli.enable`
- **Type**: boolean
- **Default**: true
- **Description**: Enable caelestia CLI tools

#### `programs.caelestia.cli.settings.theme.enableGtk`
- **Type**: boolean
- **Default**: false
- **Description**: Enable GTK theme integration

## Usage

### Starting the Shell

If you have systemd integration enabled:
```bash
systemctl --user start caelestia-shell
```

If you prefer manual startup or compositor integration:
```bash
quickshell -c caelestia
```

### CLI Commands

The caelestia CLI provides various commands for interacting with the shell:

```bash
# Show available IPC commands
caelestia shell -s

# Control MPRIS (media players)
caelestia shell mpris playPause
caelestia shell mpris getActive trackTitle

# Control notifications
caelestia shell notifs clear

# Control wallpapers
caelestia wallpaper set /path/to/wallpaper.jpg
caelestia wallpaper list
```

## Dependencies

The Caelestia shell requires several dependencies that should be automatically handled by the module:

- quickshell (git version)
- caelestia-cli
- Various system utilities (ddcutil, brightnessctl, etc.)

## Integration with Hyprland

If you're using Hyprland, you can add the shell to your Hyprland configuration:

```
exec-once = quickshell -c caelestia
```

Or use the systemd service:

```
exec-once = systemctl --user start caelestia-shell
```

## Customization

The shell configuration is sourced directly from the [caelestia-dots/shell](https://github.com/caelestia-dots/shell) repository. The module creates a configuration file at `~/.config/caelestia/shell.json` with your specified settings.

For advanced customization, you can modify the shell files in `~/.config/quickshell/caelestia/` after the module has been applied.

## Troubleshooting

### Shell not starting
1. Check that quickshell is installed and available
2. Verify that the caelestia configuration is present in `~/.config/quickshell/caelestia/`
3. Check systemd service logs if using systemd integration:
   ```bash
   journalctl --user -u caelestia-shell
   ```

### Missing dependencies
The module should handle most dependencies automatically, but some system-level packages might need to be installed separately depending on your system configuration.

## Example Configuration

See `home/dscv/caelestia-example.nix` for a complete example configuration that matches the user's original request.
