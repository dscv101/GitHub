{pkgs, ...}: {
  xdg.configFile = {
    "waybar/config.jsonc".text = ''
      {
        "layer": "top",
        "position": "top",
        "height": 32,
        "spacing": 4,
        "margin-top": 6,
        "margin-left": 10,
        "margin-right": 10,
        "reload_style_on_change": true,

        "modules-left": [
          "niri/workspaces",
          "niri/mode",
          "niri/window"
        ],

        "modules-center": [
          "clock"
        ],

        "modules-right": [
          "idle_inhibitor",
          "temperature",
          "cpu",
          "memory",
          "disk",
          "network",
          "bluetooth",
          "pulseaudio",
          "battery",
          "power-profiles-daemon",
          "tray"
        ],

        // Left modules
        "niri/workspaces": {
          "disable-scroll": true,
          "all-outputs": true,
          "format": "{icon}",
          "format-icons": {
            "1": "󰲠",
            "2": "󰲢",
            "3": "󰲤",
            "4": "󰲦",
            "5": "󰲨",
            "6": "󰲪",
            "7": "󰲬",
            "8": "󰲮",
            "9": "󰲰",
            "10": "󰿬"
          }
        },

        "niri/mode": {
          "format": "<span style=\"italic\">{}</span>"
        },

        "niri/window": {
          "format": "{}",
          "max-length": 50,
          "separate-outputs": true
        },

        // Center modules
        "clock": {
          "timezone": "America/New_York",
          "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
          "format": "{:%a %b %d  %H:%M}",
          "format-alt": "{:%Y-%m-%d %H:%M:%S}",
          "actions": {
            "on-click-right": "mode",
            "on-scroll-up": "shift_up",
            "on-scroll-down": "shift_down"
          }
        },

        // Right modules
        "idle_inhibitor": {
          "format": "{icon}",
          "format-icons": {
            "activated": "󰒳",
            "deactivated": "󰒲"
          }
        },

        "temperature": {
          "thermal-zone": 2,
          "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
          "critical-threshold": 80,
          "format-critical": "{temperatureC}°C {icon}",
          "format": "{temperatureC}°C {icon}",
          "format-icons": ["", "", "", "", ""],
          "interval": 5
        },

        "cpu": {
          "format": "{usage}% ",
          "tooltip": false,
          "interval": 3,
          "on-click": "${pkgs.btop}/bin/btop"
        },

        "memory": {
          "format": "{}% ",
          "tooltip-format": "Memory: {used:0.1f}G/{total:0.1f}G\nSwap: {swapUsed:0.1f}G/{swapTotal:0.1f}G",
          "interval": 5,
          "on-click": "${pkgs.btop}/bin/btop"
        },

        "disk": {
          "interval": 30,
          "format": "{percentage_used}% ",
          "path": "/",
          "tooltip-format": "Used: {used} / {total} ({percentage_used}%)\nFree: {free}",
          "on-click": "${pkgs.baobab}/bin/baobab"
        },

        "network": {
          "format-wifi": "{essid} ({signalStrength}%) ",
          "format-ethernet": "{ipaddr}/{cidr} 󰊗",
          "tooltip-format": "{ifname} via {gwaddr} 󰊗",
          "format-linked": "{ifname} (No IP) 󰊗",
          "format-disconnected": "Disconnected ⚠",
          "format-alt": "{ifname}: {ipaddr}/{cidr}",
          "interval": 5,
          "on-click": "${pkgs.networkmanagerapplet}/bin/nm-connection-editor"
        },

        "bluetooth": {
          "format": " {status}",
          "format-disabled": "",
          "format-off": "",
          "interval": 30,
          "on-click": "${pkgs.blueman}/bin/blueman-manager",
          "format-no-controller": ""
        },

        "pulseaudio": {
          "scroll-step": 5,
          "format": "{volume}% {icon} {format_source}",
          "format-bluetooth": "{volume}% {icon} {format_source}",
          "format-bluetooth-muted": " {icon} {format_source}",
          "format-muted": " {format_source}",
          "format-source": "{volume}% ",
          "format-source-muted": "",
          "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
          },
          "on-click": "${pkgs.pavucontrol}/bin/pavucontrol",
          "on-scroll-up": "${pkgs.pamixer}/bin/pamixer -i 5",
          "on-scroll-down": "${pkgs.pamixer}/bin/pamixer -d 5"
        },

        "battery": {
          "states": {
            "good": 95,
            "warning": 30,
            "critical": 15
          },
          "format": "{capacity}% {icon}",
          "format-charging": "{capacity}% ",
          "format-plugged": "{capacity}% ",
          "format-alt": "{time} {icon}",
          "format-icons": ["", "", "", "", ""],
          "tooltip-format": "{timeTo}, {capacity}% - {power}W"
        },

        "power-profiles-daemon": {
          "format": "{icon}",
          "tooltip-format": "Power profile: {profile}\nDriver: {driver}",
          "tooltip": true,
          "format-icons": {
            "default": "",
            "performance": "",
            "balanced": "",
            "power-saver": ""
          }
        },

        "tray": {
          "icon-size": 16,
          "spacing": 8,
          "show-passive-items": true
        }
      }
    '';

    "waybar/style.css".text = ''
      /* Enhanced Waybar styling with modern design */
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", "Fira Code Nerd Font", "Iosevka Nerd Font", monospace;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.95);
        color: #cdd6f4;
        border-radius: 12px;
        border: 2px solid rgba(137, 180, 250, 0.3);
        transition: all 0.3s ease;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      /* Workspaces */
      #workspaces {
        background: rgba(49, 50, 68, 0.8);
        border-radius: 10px;
        margin: 4px 0px 4px 8px;
        padding: 0px 8px;
      }

      #workspaces button {
        padding: 4px 8px;
        color: #6c7086;
        background: transparent;
        border-radius: 8px;
        transition: all 0.3s ease;
        margin: 2px;
      }

      #workspaces button:hover {
        background: rgba(137, 180, 250, 0.2);
        color: #89b4fa;
        transform: scale(1.05);
      }

      #workspaces button.active {
        background: linear-gradient(45deg, #89b4fa, #74c7ec);
        color: #1e1e2e;
        font-weight: bold;
        box-shadow: 0 2px 8px rgba(137, 180, 250, 0.4);
      }

      #workspaces button.urgent {
        background: #f38ba8;
        color: #1e1e2e;
        animation: blink 1s linear infinite alternate;
      }

      @keyframes blink {
        to {
          background: #f9e2af;
        }
      }

      /* Mode and Window */
      #mode, #window {
        background: rgba(49, 50, 68, 0.8);
        border-radius: 10px;
        padding: 4px 12px;
        margin: 4px;
        color: #f9e2af;
      }

      #mode {
        background: rgba(243, 139, 168, 0.8);
        color: #1e1e2e;
        font-weight: bold;
      }

      /* Clock */
      #clock {
        background: linear-gradient(45deg, #a6e3a1, #94e2d5);
        color: #1e1e2e;
        border-radius: 10px;
        padding: 4px 16px;
        margin: 4px;
        font-weight: bold;
        box-shadow: 0 2px 8px rgba(166, 227, 161, 0.3);
      }

      /* Right modules container */
      #idle_inhibitor,
      #temperature,
      #cpu,
      #memory,
      #disk,
      #network,
      #bluetooth,
      #pulseaudio,
      #battery,
      #power-profiles-daemon,
      #tray {
        background: rgba(49, 50, 68, 0.8);
        border-radius: 8px;
        padding: 4px 10px;
        margin: 4px 2px;
        transition: all 0.3s ease;
      }

      /* Individual module styling */
      #idle_inhibitor {
        color: #f9e2af;
      }

      #idle_inhibitor.activated {
        background: rgba(249, 226, 175, 0.2);
        color: #f9e2af;
      }

      #temperature {
        color: #fab387;
      }

      #temperature.critical {
        background: rgba(243, 139, 168, 0.8);
        color: #1e1e2e;
        animation: pulse 2s ease-in-out infinite alternate;
      }

      @keyframes pulse {
        to {
          background: rgba(243, 139, 168, 1);
        }
      }

      #cpu {
        color: #89b4fa;
      }

      #cpu:hover {
        background: rgba(137, 180, 250, 0.2);
      }

      #memory {
        color: #a6e3a1;
      }

      #memory:hover {
        background: rgba(166, 227, 161, 0.2);
      }

      #disk {
        color: #f5c2e7;
      }

      #disk:hover {
        background: rgba(245, 194, 231, 0.2);
      }

      #network {
        color: #94e2d5;
      }

      #network.disconnected {
        background: rgba(243, 139, 168, 0.8);
        color: #1e1e2e;
      }

      #bluetooth {
        color: #89b4fa;
      }

      #bluetooth.disabled,
      #bluetooth.off {
        color: #6c7086;
      }

      #pulseaudio {
        color: #cba6f7;
      }

      #pulseaudio.muted {
        color: #6c7086;
        background: rgba(108, 112, 134, 0.2);
      }

      #battery {
        color: #a6e3a1;
      }

      #battery.charging {
        color: #f9e2af;
        background: rgba(249, 226, 175, 0.2);
      }

      #battery.warning:not(.charging) {
        background: rgba(249, 226, 175, 0.8);
        color: #1e1e2e;
      }

      #battery.critical:not(.charging) {
        background: rgba(243, 139, 168, 0.8);
        color: #1e1e2e;
        animation: blink 0.5s linear infinite alternate;
      }

      #power-profiles-daemon {
        color: #f38ba8;
      }

      #power-profiles-daemon.performance {
        background: rgba(243, 139, 168, 0.2);
        color: #f38ba8;
      }

      #power-profiles-daemon.balanced {
        background: rgba(137, 180, 250, 0.2);
        color: #89b4fa;
      }

      #power-profiles-daemon.power-saver {
        background: rgba(166, 227, 161, 0.2);
        color: #a6e3a1;
      }

      #tray {
        background: rgba(49, 50, 68, 0.8);
        border-radius: 10px;
        margin-right: 8px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background: rgba(243, 139, 168, 0.8);
        border-radius: 8px;
      }

      /* Hover effects for all modules */
      #idle_inhibitor:hover,
      #temperature:hover,
      #cpu:hover,
      #memory:hover,
      #disk:hover,
      #network:hover,
      #bluetooth:hover,
      #pulseaudio:hover,
      #battery:hover,
      #power-profiles-daemon:hover,
      #tray:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
      }

      /* Tooltip styling */
      tooltip {
        background: rgba(30, 30, 46, 0.95);
        border: 2px solid rgba(137, 180, 250, 0.3);
        border-radius: 8px;
        color: #cdd6f4;
      }

      tooltip label {
        color: #cdd6f4;
        padding: 4px;
      }
    '';
  };
}
