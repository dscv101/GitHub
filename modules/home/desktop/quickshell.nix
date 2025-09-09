{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  # Get quickshell package from the flake input
  quickshell = inputs.quickshell.packages.${pkgs.system}.default;
in {
  # Install quickshell and required dependencies
  home.packages = [
    quickshell
    
    # Qt dependencies for quickshell
    pkgs.qt6.qtsvg              # SVG support
    pkgs.qt6.qtimageformats     # Additional image formats (WEBP, etc.)
    pkgs.qt6.qtmultimedia       # Audio/video support
    pkgs.qt6.qt5compat          # Additional visual effects
    
    # System monitoring tools (used by quickshell components)
    pkgs.btop                   # System monitor
    pkgs.baobab                 # Disk usage analyzer
    pkgs.pavucontrol            # PulseAudio volume control
    pkgs.pamixer                # PulseAudio mixer
    pkgs.networkmanagerapplet   # Network manager GUI
    pkgs.blueman                # Bluetooth manager
    pkgs.power-profiles-daemon  # Power profile management
    
    # Additional utilities for quickshell
    pkgs.coreutils              # Basic system utilities (date, etc.)
    pkgs.procps                 # Process utilities (ps, top, etc.)
    pkgs.util-linux             # System utilities
    
    # System tray applications (optional, commonly used)
    # These provide system tray functionality that users might want
    # pkgs.pasystray            # PulseAudio system tray (uncomment if needed)
    # pkgs.nm-tray              # NetworkManager system tray (uncomment if needed)
    # pkgs.blueman              # Bluetooth manager with tray support (already included above)
  ];

  # Create quickshell configuration directory
  xdg.configFile = {
    # Main shell configuration
    "quickshell/shell.qml".text = ''
      import Quickshell
      import Quickshell.Io
      import QtQuick
      import "./components" as Components

      Scope {
        id: root
        
        // Global properties for shared state
        property string currentTime: ""
        property string batteryInfo: ""
        
        // Create panels for all screens
        Variants {
          model: Quickshell.screens
          
          delegate: Component {
            PanelWindow {
              required property var modelData
              screen: modelData
              
              anchors {
                top: true
                left: true
                right: true
              }
              
              height: 32
              margins {
                top: 6
                left: 10
                right: 10
              }
              
              color: "#1e1e2e"
              
              // Main panel layout
              Row {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 8
                
                // Left section - Workspaces (placeholder for now)
                Rectangle {
                  width: 200
                  height: parent.height
                  color: "#313244"
                  radius: 10
                  
                  Text {
                    anchors.centerIn: parent
                    text: "Niri Workspaces"
                    color: "#cdd6f4"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                  }
                }
                
                // Spacer to push center content to center
                Item {
                  width: parent.width - leftSection.width - centerSection.width - rightSection.width - (parent.spacing * 3)
                  height: parent.height
                }
                
                // Center section - Clock
                Rectangle {
                  id: centerSection
                  width: 200
                  height: parent.height
                  color: "#a6e3a1"
                  radius: 10
                  
                  Text {
                    anchors.centerIn: parent
                    text: root.currentTime
                    color: "#1e1e2e"
                    font.family: "JetBrainsMono Nerd Font"
                    font.bold: true
                    font.pixelSize: 12
                  }
                }
                
                // Right section - System info and controls
                Row {
                  id: rightSection
                  spacing: 4
                  
                  // System monitoring
                  Components.SystemMonitor {
                    id: systemMonitor
                  }
                  
                  // Network info
                  Components.NetworkInfo {
                    id: networkInfo
                  }
                  
                  // Audio control
                  Components.AudioControl {
                    id: audioControl
                  }
                  
                  // Power profile management
                  Components.PowerProfile {
                    id: powerProfile
                  }
                  
                  // Battery info
                  Rectangle {
                    width: 100
                    height: parent.height
                    color: "#313244"
                    radius: 8
                    
                    Text {
                      anchors.centerIn: parent
                      text: root.batteryInfo
                      color: "#f9e2af"
                      font.family: "JetBrainsMono Nerd Font"
                      font.pixelSize: 12
                    }
                  }
                  
                  // System tray
                  Components.SystemTray {
                    id: systemTray
                  }
                }
              }
            }
          }
        }
        
        // Global system information processes
        
        // Clock updater
        Process {
          id: dateProcess
          command: ["date", "+%a %b %d  %H:%M"]
          running: true
          
          stdout: StdioCollector {
            onStreamFinished: root.currentTime = text.trim()
          }
        }
        
        Timer {
          interval: 1000
          running: true
          repeat: true
          onTriggered: dateProcess.running = true
        }
        
        // Battery info
        Process {
          id: batteryProcess
          command: ["sh", "-c", "if [ -d /sys/class/power_supply/BAT* ]; then cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; else echo 'AC'; fi"]
          running: true
          
          stdout: StdioCollector {
            onStreamFinished: {
              let capacity = text.trim()
              if (capacity === "AC") {
                root.batteryInfo = "AC "
              } else {
                let level = parseInt(capacity)
                let icon = ""
                if (level > 90) icon = ""
                else if (level > 75) icon = ""
                else if (level > 50) icon = ""
                else if (level > 25) icon = ""
                else icon = ""
                
                root.batteryInfo = capacity + "% " + icon
              }
            }
          }
        }
        
        Timer {
          interval: 30000
          running: true
          repeat: true
          onTriggered: batteryProcess.running = true
        }
      }
    '';
    
    # LSP configuration for development
    "quickshell/.qmlls.ini".text = "";
    
    # Component files
    "quickshell/components/SystemMonitor.qml".source = ./quickshell/components/SystemMonitor.qml;
    "quickshell/components/AudioControl.qml".source = ./quickshell/components/AudioControl.qml;
    "quickshell/components/NetworkInfo.qml".source = ./quickshell/components/NetworkInfo.qml;
    "quickshell/components/PowerProfile.qml".source = ./quickshell/components/PowerProfile.qml;
    "quickshell/components/SystemTray.qml".source = ./quickshell/components/SystemTray.qml;
  };

  # Enable quickshell service (will be managed by the window manager)
  # Note: Quickshell is typically started by the window manager's exec-once
  # rather than as a systemd service, but we can provide the option
  
  # Optional: Create a systemd user service for quickshell
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell - QML-based shell";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };
    
    Service = {
      Type = "simple";
      ExecStart = "${quickshell}/bin/quickshell";
      Restart = "on-failure";
      RestartSec = 3;
    };
    
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
