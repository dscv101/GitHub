# Enhanced Waybar Configuration Example

This example demonstrates the modern, feature-rich Waybar configuration with comprehensive modules and beautiful styling.

## What's Included

- **Modern Design**: Rounded corners, gradients, and smooth animations
- **Comprehensive Modules**: 11 different status modules covering all system aspects
- **Interactive Elements**: Click actions and scroll functionality for all modules
- **Catppuccin Theming**: Consistent with the overall system theme
- **Smart Dependencies**: All required packages automatically installed

## Features Overview

### Visual Design
- **Rounded Bar**: 12px border radius with subtle border
- **Transparency**: Semi-transparent background with proper contrast
- **Gradients**: Beautiful gradient backgrounds on key modules
- **Animations**: Smooth hover effects and state transitions
- **Color Coding**: Different colors for different module types

### Modules Included

| Module | Function | Click Action | Scroll Action |
|--------|----------|--------------|---------------|
| **Workspaces** | Niri workspace indicators | Switch workspace | - |
| **Mode** | Current Niri mode | - | - |
| **Window** | Active window title | - | - |
| **Clock** | Date/time with calendar | Toggle format | Shift time |
| **Idle Inhibitor** | Prevent screen sleep | Toggle inhibitor | - |
| **Temperature** | CPU temperature | - | - |
| **CPU** | CPU usage % | Open btop | - |
| **Memory** | RAM usage % | Open btop | - |
| **Disk** | Root filesystem usage | Open baobab | - |
| **Network** | WiFi/Ethernet status | Open NetworkManager | - |
| **Bluetooth** | Bluetooth status | Open Blueman | - |
| **Audio** | Volume control | Open PulseAudio | Volume up/down |
| **Battery** | Battery status | - | - |
| **Power Profiles** | Power management | - | - |
| **Tray** | System tray icons | - | - |

## Quick Start

1. **Import the desktop modules** (includes enhanced Waybar):
   ```nix
   imports = [
     ../../modules/home/desktop
   ];
   ```

2. **Enable system services** for full functionality:
   ```nix
   services.networkmanager.enable = true;
   services.blueman.enable = true;
   hardware.bluetooth.enable = true;
   ```

3. **Rebuild your system**:
   ```bash
   sudo nixos-rebuild switch
   ```

4. **Restart Waybar** (if already running):
   ```bash
   pkill waybar && waybar &
   ```

## Customization

### Hiding Modules
Remove unwanted modules from the `modules-right` array in `modules/home/desktop/waybar.nix`:

```jsonc
"modules-right": [
  "idle_inhibitor",
  // "temperature",  // Comment out to hide
  "cpu",
  "memory",
  // ... other modules
]
```

### Changing Colors
The configuration uses Catppuccin Mocha colors. Key colors in the CSS:

```css
/* Main colors */
--background: rgba(30, 30, 46, 0.95);
--surface: rgba(49, 50, 68, 0.8);
--blue: #89b4fa;
--green: #a6e3a1;
--yellow: #f9e2af;
--red: #f38ba8;
```

### Temperature Monitoring
You may need to adjust the thermal zone based on your hardware:

```jsonc
"temperature": {
  "thermal-zone": 2,  // Try 0, 1, 2, etc.
  // OR use hwmon path:
  "hwmon-path": "/sys/class/hwmon/hwmon1/temp1_input"
}
```

Find your thermal zones:
```bash
ls /sys/class/thermal/thermal_zone*/type
```

### Custom CSS Overrides
Add custom styling in your configuration:

```nix
xdg.configFile."waybar/custom-overrides.css".text = ''
  /* Your custom CSS here */
  window#waybar { height: 36px; }
'';
```

## Dependencies

All required packages are automatically installed:

- **btop** - System monitor (CPU/Memory clicks)
- **baobab** - Disk usage analyzer (Disk clicks)
- **pavucontrol** - Audio control (Audio clicks)
- **pamixer** - Volume control (Audio scroll)
- **networkmanagerapplet** - Network management (Network clicks)
- **blueman** - Bluetooth management (Bluetooth clicks)

## Troubleshooting

### Temperature Not Showing
1. Check available thermal zones:
   ```bash
   ls /sys/class/thermal/
   cat /sys/class/thermal/thermal_zone*/type
   ```
2. Update the `thermal-zone` number in the configuration

### Battery Module Missing
The battery module only appears on systems with a battery (laptops). On desktops, it's automatically hidden.

### Network Module Not Working
Ensure NetworkManager is enabled:
```nix
networking.networkmanager.enable = true;
```

### Bluetooth Module Issues
Enable Bluetooth in your system configuration:
```nix
hardware.bluetooth.enable = true;
services.blueman.enable = true;
```

### Click Actions Not Working
Ensure the required packages are installed. They should be automatically included when you import the desktop modules.

## Performance

The configuration is optimized for performance:

- **Update Intervals**: Balanced for responsiveness vs CPU usage
- **Hardware Acceleration**: CSS animations use GPU acceleration
- **Memory Efficient**: Lightweight while feature-rich
- **Smart Updates**: Modules only update when necessary

## Screenshots

The enhanced Waybar provides:

- **Clean Layout**: Well-organized modules with proper spacing
- **Visual Feedback**: Hover effects and state indicators
- **Consistent Theming**: Matches the overall Catppuccin theme
- **Professional Look**: Modern design suitable for any environment

## Integration

This configuration is specifically designed for:

- **Niri Window Manager**: Uses Niri-specific modules
- **NixOS/Home Manager**: Declarative configuration
- **Catppuccin Theme**: Consistent color scheme
- **Modern Wayland**: Full Wayland compatibility

For other window managers, replace `niri/*` modules with appropriate alternatives (e.g., `sway/*` for Sway).

## Advanced Usage

### Multiple Monitors
The configuration works with multiple monitors. Waybar will appear on all outputs by default.

### Custom Scripts
Add custom modules with scripts:

```jsonc
"custom/weather": {
  "format": "{}",
  "exec": "curl -s 'wttr.in/YourCity?format=1'",
  "interval": 3600
}
```

### Conditional Modules
Use CSS media queries to hide modules on smaller screens:

```css
@media (max-width: 1366px) {
  #temperature, #idle_inhibitor {
    display: none;
  }
}
```
