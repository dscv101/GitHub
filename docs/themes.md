# Themes Configuration

This document describes the available themes and how to configure them in your NixOS system.

## SDDM Astronaut Theme

The Astronaut theme is a beautiful space-themed login screen for SDDM (Simple Desktop Display Manager).

### Features

- Space/astronaut themed background
- Modern, clean interface
- Wayland support
- Compatible with KDE Plasma components

### Usage

To enable SDDM with the Astronaut theme, add the following to your system configuration:

```nix
{
  # Enable SDDM display manager
  desktop.sddm.enable = true;
  
  # Enable the Astronaut theme
  desktop.sddm.enableAstronautTheme = true;
}
```

### Alternative: Manual SDDM Configuration

If you prefer to configure SDDM manually, you can use:

```nix
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "astronaut";
  };
  
  environment.systemPackages = [
    pkgs.sddm-astronaut-theme
  ];
}
```

### Switching from Greetd

If you're currently using greetd (the default in this configuration), enabling SDDM will automatically disable greetd to prevent conflicts.

### Theme Source

The Astronaut theme is sourced from [Keyitdev/sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme).

## Other Themes

### GTK Theme (Catppuccin)

The system uses Catppuccin Mocha as the default GTK theme. This is configured in `modules/home/theming/default.nix`.

### Icon Theme (Papirus)

Papirus Dark icons are used as the default icon theme.

## Customization

To customize themes further, you can:

1. Fork the astronaut theme repository
2. Modify the theme files
3. Update the `pkgs/sddm-themes/astronaut.nix` file to point to your fork
4. Rebuild your system

## Troubleshooting

### Theme Not Loading

If the astronaut theme doesn't load:

1. Check that SDDM is enabled: `systemctl status sddm`
2. Verify the theme is installed: `ls /run/current-system/sw/share/sddm/themes/`
3. Check SDDM logs: `journalctl -u sddm`

### Wayland Issues

If you experience issues with Wayland:

1. Ensure `wayland.enable = true` is set in your SDDM configuration
2. Check that your graphics drivers support Wayland
3. Consider temporarily disabling Wayland to test: `wayland.enable = false`
