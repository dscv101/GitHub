# Astronaut Theme Example

This example demonstrates how to enable the beautiful Astronaut SDDM theme in your NixOS configuration.

## What's Included

- SDDM display manager with Wayland support
- Astronaut space-themed login screen
- Proper integration with the existing desktop modules

## Usage

1. Copy the configuration to your system:
   ```nix
   # In your system configuration
   desktop.sddm = {
     enable = true;
     enableAstronautTheme = true;
   };
   ```

2. Rebuild your system:
   ```bash
   sudo nixos-rebuild switch
   ```

3. Reboot to see the new login screen

## Features

- **Space Theme**: Beautiful astronaut and space imagery
- **Wayland Support**: Works with modern Wayland compositors
- **KDE Integration**: Uses KDE Plasma components for consistency
- **Auto-conflict Resolution**: Automatically disables greetd to prevent conflicts

## Customization

You can further customize SDDM by adding settings:

```nix
services.displayManager.sddm.settings = {
  Theme = {
    Current = "astronaut";
    CursorTheme = "Adwaita";
    Font = "Inter";
  };
  General = {
    HaltCommand = "/run/current-system/systemd/bin/systemctl poweroff";
    RebootCommand = "/run/current-system/systemd/bin/systemctl reboot";
  };
};
```

## Troubleshooting

If the theme doesn't appear:

1. Check that SDDM is running: `systemctl status sddm`
2. Verify theme installation: `ls /run/current-system/sw/share/sddm/themes/`
3. Check logs: `journalctl -u sddm`

## Switching Back

To switch back to greetd (the default):

```nix
desktop.sddm.enable = false;
# greetd will be automatically re-enabled
```
