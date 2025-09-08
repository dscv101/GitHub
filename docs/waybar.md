# Waybar Configuration

This document describes the enhanced Waybar configuration with modern styling and comprehensive modules.

## Overview

The Waybar configuration provides a beautiful, functional status bar with:

- **Modern Design**: Rounded corners, gradients, and smooth animations
- **Comprehensive Modules**: System monitoring, network, audio, battery, and more
- **Interactive Elements**: Click actions and scroll functionality
- **Catppuccin Theme**: Consistent with the overall system theming

## Module Layout

### Left Side
- **Workspaces**: Niri workspace indicators with custom icons
- **Mode**: Current Niri mode display
- **Window**: Active window title

### Center
- **Clock**: Date and time with calendar tooltip

### Right Side
- **Idle Inhibitor**: Prevents screen from sleeping
- **Temperature**: CPU temperature monitoring
- **CPU**: CPU usage percentage
- **Memory**: RAM usage percentage
- **Disk**: Root filesystem usage
- **Network**: WiFi/Ethernet connection status
- **Bluetooth**: Bluetooth status and control
- **Audio**: PulseAudio volume control
- **Battery**: Battery status and percentage
- **Power Profiles**: Power management profiles
- **System Tray**: Application tray icons

## Interactive Features

### Click Actions
- **CPU/Memory**: Click to open `btop` system monitor
- **Disk**: Click to open `baobab` disk usage analyzer
- **Network**: Click to open NetworkManager connection editor
- **Bluetooth**: Click to open Blueman manager
- **Audio**: Click to open PulseAudio volume control

### Scroll Actions
- **Audio**: Scroll to adjust volume up/down
- **Clock**: Scroll to shift time display

## Styling Features

### Visual Effects
- **Rounded Corners**: Modern 12px border radius on main bar
- **Transparency**: Semi-transparent background with blur effect
- **Gradients**: Beautiful gradient backgrounds on key modules
- **Animations**: Smooth hover effects and state transitions
- **Color Coding**: Different colors for different module types

### State Indicators
- **Battery**: Color changes based on charge level and charging state
- **Temperature**: Critical temperature warnings with pulsing animation
- **Network**: Visual indication of connection status
- **Audio**: Muted state indication
- **Power Profiles**: Different colors for performance modes

## Customization

### Timezone
The clock is set to `America/New_York` by default. Change this in the configuration:

```jsonc
"clock": {
  "timezone": "Your/Timezone",
  // ... other settings
}
```

### Temperature Monitoring
The temperature module is configured for thermal zone 2. You may need to adjust:

```jsonc
"temperature": {
  "thermal-zone": 2,  // Change this number
  "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",  // Or use this path
  // ... other settings
}
```

### Module Visibility
To hide modules you don't need, remove them from the `modules-right` array:

```jsonc
"modules-right": [
  "idle_inhibitor",
  // "temperature",  // Comment out or remove unwanted modules
  "cpu",
  "memory",
  // ... other modules
]
```

### Colors and Styling
The CSS uses Catppuccin Mocha colors. Key color variables:

- **Background**: `rgba(30, 30, 46, 0.95)` - Main bar background
- **Surface**: `rgba(49, 50, 68, 0.8)` - Module backgrounds
- **Blue**: `#89b4fa` - Primary accent color
- **Green**: `#a6e3a1` - Success/good states
- **Yellow**: `#f9e2af` - Warning states
- **Red**: `#f38ba8` - Critical/error states

## Dependencies

The enhanced configuration requires these packages (automatically installed):

- `btop` - System monitor
- `baobab` - Disk usage analyzer
- `pavucontrol` - Audio control
- `pamixer` - Audio mixer
- `networkmanagerapplet` - Network management
- `blueman` - Bluetooth management

## Troubleshooting

### Temperature Module Not Working
1. Check available thermal zones: `ls /sys/class/thermal/`
2. Find your CPU thermal zone: `cat /sys/class/thermal/thermal_zone*/type`
3. Update the `thermal-zone` number in the configuration

### Battery Module Not Showing
The battery module only appears on systems with a battery. On desktop systems, it will be hidden automatically.

### Bluetooth Module Issues
Ensure Bluetooth is enabled in your system configuration:

```nix
hardware.bluetooth.enable = true;
services.blueman.enable = true;
```

### Network Module Not Working
Ensure NetworkManager is enabled:

```nix
networking.networkmanager.enable = true;
```

## Advanced Configuration

### Custom Scripts
You can add custom modules with scripts. Example:

```jsonc
"custom/weather": {
  "format": "{}",
  "exec": "curl -s 'wttr.in/YourCity?format=1'",
  "interval": 3600
}
```

### Multiple Bars
For multi-monitor setups, you can create multiple bar configurations:

```jsonc
[
  {
    "output": "DP-1",
    // ... first monitor config
  },
  {
    "output": "HDMI-A-1", 
    // ... second monitor config
  }
]
```

## Performance Notes

- **Update Intervals**: Modules have optimized update intervals to balance responsiveness and CPU usage
- **Animations**: CSS transitions are hardware-accelerated for smooth performance
- **Memory Usage**: The configuration is designed to be lightweight while feature-rich

## Integration with Niri

The configuration is specifically designed for the Niri window manager:

- Uses `niri/workspaces` for workspace display
- Includes `niri/mode` for mode indication
- Uses `niri/window` for window title display

For other window managers, replace these with appropriate modules (e.g., `sway/workspaces` for Sway).
