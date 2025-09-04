{ ... }:
{
  xdg.configFile = {
    "waybar/config.jsonc".text = ''
      {
        "position": "top",
        "height": 28,
        "modules-left": ["niri/workspaces", "niri/mode", "window"],
        "modules-center": ["clock"],
        "modules-right": ["cpu", "memory", "disk", "network", "pulseaudio", "power-profiles-daemon", "tray"],
        "clock": { "format": "{:%a %b %d  %H:%M}" },
        "window": { "max-length": 60 },
        "cpu": { "interval": 3 },
        "memory": { "interval": 5 },
        "disk": { "interval": 30, "path": "/" },
        "network": {
          "format-wired": "{ifname}  {ipaddr}",
          "format-disconnected": "disconnected",
          "family": "ipv4"
        },
        "pulseaudio": {
          "scroll-step": 2,
          "format": "{volume}% {icon}",
          "format-muted": "muted "
        },
        "power-profiles-daemon": { "profiles": ["power-saver","balanced","performance"] },
        "tray": { "spacing": 6 }
      }
    '';

    "waybar/style.css".text = ''
      /* Minimal Catppuccin-ish styling */
      * { font-family: "JetBrainsMono Nerd Font", Inter, sans-serif; font-size: 12px; }
      window#waybar { background: rgba(30,30,46,0.9); color: #c6d0f5; }
      #workspaces button.focused { background: #89b4fa; color: #1e1e2e; }
      #clock, #cpu, #memory, #disk, #network, #pulseaudio, #tray { padding: 0 8px; }
    '';
  };
}
