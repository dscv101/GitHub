# Quickshell Configuration

This document describes the quickshell setup in this NixOS configuration, which provides a modern QML-based shell/panel system as an alternative to Waybar.

## Overview

Quickshell is a QML-based shell system that offers more flexibility and modern UI capabilities compared to traditional status bars. It uses Qt Quick for rendering and provides reactive bindings for dynamic content updates.

## Architecture

### Main Components

- **Shell Configuration**: `~/.config/quickshell/shell.qml` - Main entry point
- **System Monitor**: CPU, memory, disk, and temperature monitoring
- **Audio Control**: Volume control with PulseAudio/PipeWire integration
- **Network Info**: WiFi and Ethernet connection status
- **Battery Status**: Battery level and charging state
- **Clock**: Date and time display

### File Structure

```
~/.config/quickshell/
├── shell.qml              # Main shell configuration
├── .qmlls.ini             # LSP configuration (auto-generated)
└── components/
    ├── SystemMonitor.qml  # System monitoring widgets
    ├── AudioControl.qml   # Audio volume control
    ├── NetworkInfo.qml    # Network status display
    └── SystemTray.qml     # System tray implementation
```

## Features

### System Monitoring
- **CPU Usage**: Real-time CPU utilization percentage
- **Memory Usage**: RAM usage percentage
- **Disk Usage**: Root filesystem usage
- **Temperature**: CPU temperature (if sensors available)
- **Click Actions**: Opens `btop` for CPU/Memory, `baobab` for disk

### Audio Control
- **Volume Display**: Current volume level with icons
- **Mute Status**: Visual indication when muted
- **Mouse Controls**:
  - Left click: Toggle mute
  - Right click: Open PulseAudio control (pavucontrol)
  - Scroll wheel: Adjust volume ±5%

### Network Information
- **WiFi Status**: SSID and signal strength
- **Ethernet Status**: Connection state
- **Click Action**: Opens NetworkManager connection editor

### Battery Status
- **Battery Level**: Percentage with appropriate icons
- **AC Power**: Shows "AC" when plugged in
- **Visual Indicators**: Different icons based on charge level

### System Tray
- **StatusNotifierItem Support**: Compatible with modern system tray applications
- **Interactive Icons**: Left-click activation, right-click context menus, middle-click secondary actions
- **Scroll Support**: Mouse wheel support for volume controls and similar applications
- **Tooltips**: Hover tooltips showing application information
- **Dynamic Updates**: Automatic addition/removal of tray items as applications start/stop

## Integration with Niri

The quickshell configuration is designed to work with the Niri window manager:

- **Multi-monitor Support**: Automatically creates panels on all connected screens
- **Workspace Integration**: Placeholder for Niri workspace display (to be implemented)
- **Window Management**: Integrates with Niri's window management system

## Customization

### Theming

The configuration uses a Catppuccin-inspired color scheme:

- **Background**: `#1e1e2e` (Catppuccin Base)
- **Surface**: `#313244` (Catppuccin Surface0)
- **Text**: `#cdd6f4` (Catppuccin Text)
- **Accent Colors**:
  - Blue: `#89b4fa` (CPU)
  - Green: `#a6e3a1` (Memory, Clock)
  - Pink: `#f5c2e7` (Disk)
  - Orange: `#fab387` (Temperature)
  - Purple: `#cba6f7` (Audio)
  - Teal: `#94e2d5` (Network)
  - Yellow: `#f9e2af` (Battery)

### Font Configuration

Uses JetBrainsMono Nerd Font for consistent monospace display with icon support.

### Layout Customization

The panel layout can be customized by modifying the QML structure:

- **Left Section**: Workspaces (currently placeholder)
- **Center Section**: Clock
- **Right Section**: System monitoring and controls

## Dependencies

### Required Packages

- `quickshell`: Main application
- `qt6.qtsvg`: SVG support
- `qt6.qtimageformats`: Additional image formats
- `qt6.qtmultimedia`: Audio/video support
- `qt6.qt5compat`: Additional visual effects

### System Tools

- `btop`: System monitor
- `baobab`: Disk usage analyzer
- `pavucontrol`: Audio control
- `pamixer`: Audio mixer
- `networkmanagerapplet`: Network management
- `blueman`: Bluetooth management

## Service Management

Quickshell can be started in several ways:

### Systemd User Service (Default)

The configuration includes a systemd user service that starts with the graphical session:

```bash
systemctl --user enable quickshell
systemctl --user start quickshell
```

### Manual Start

```bash
quickshell
```

### Window Manager Integration

For Niri, add to your Niri configuration:

```kdl
spawn-at-startup "quickshell"
```

## Development

### LSP Support

The configuration includes `.qmlls.ini` for QML Language Server support. This enables:

- Syntax highlighting
- Code completion
- Error checking
- Documentation tooltips

### Live Reloading

Quickshell supports live reloading - changes to QML files are automatically applied without restarting the application.

### Debugging

Enable debug output:

```bash
QML_IMPORT_TRACE=1 quickshell
```

## Troubleshooting

### Common Issues

1. **Components not loading**: Ensure component files are in the correct directory
2. **System commands failing**: Check that required system tools are installed
3. **Font issues**: Verify JetBrainsMono Nerd Font is installed
4. **Qt errors**: Ensure all Qt6 dependencies are available

### Logs

Check systemd logs for service issues:

```bash
journalctl --user -u quickshell -f
```

### Performance

Monitor resource usage:

```bash
htop -p $(pgrep quickshell)
```

## Migration from Waybar

When migrating from Waybar:

1. **Test Phase**: Both Waybar and Quickshell can run simultaneously
2. **Feature Comparison**: Verify all required features are implemented
3. **Configuration**: Adjust styling and behavior as needed
4. **Switch**: Disable Waybar and enable Quickshell in desktop configuration

## Future Enhancements

Planned improvements:

- [ ] Niri workspace integration
- [x] System tray support
- [ ] Bluetooth status widget
- [ ] Power profile management
- [ ] Notification integration
- [ ] Custom widget system
- [ ] Configuration file support
- [ ] Theme switching

## References

- [Quickshell Documentation](https://quickshell.org/docs/master/guide/)
- [QML Documentation](https://doc.qt.io/qt-6/qmlapplications.html)
- [Niri Window Manager](https://github.com/YaLTeR/niri)
- [Catppuccin Theme](https://catppuccin.com/)
