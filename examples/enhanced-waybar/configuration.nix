# Example configuration for the enhanced Waybar setup
# This shows how to use the modern, feature-rich Waybar configuration

{ pkgs, ... }:

{
  # Import the desktop modules (includes enhanced Waybar)
  imports = [
    ../../modules/home/desktop
  ];

  # The enhanced Waybar configuration is automatically applied
  # when you import the desktop modules
  
  # Optional: Enable additional system services for full functionality
  services = {
    # Enable NetworkManager for network module
    networkmanager.enable = true;
    
    # Enable Bluetooth for bluetooth module
    blueman.enable = true;
    
    # Enable power management for power-profiles-daemon
    power-profiles-daemon.enable = true;
  };

  # Optional: Hardware configuration for temperature monitoring
  hardware = {
    # Enable Bluetooth hardware
    bluetooth.enable = true;
    
    # Enable sensors for temperature monitoring
    # Note: You may need to adjust thermal zones in waybar.nix
    # based on your specific hardware
  };

  # Optional: Additional packages that work well with the enhanced Waybar
  home.packages = with pkgs; [
    # System monitoring tools (already included in desktop module)
    # btop                 # System monitor
    # baobab               # Disk usage analyzer
    
    # Additional utilities that complement the Waybar setup
    lm_sensors             # Hardware sensors (for temperature)
    acpi                   # Battery information
    brightnessctl          # Screen brightness control
    playerctl              # Media player control
    
    # Optional: Additional GUI applications
    gnome.gnome-system-monitor  # Alternative system monitor
    gnome.gnome-disk-utility    # Disk management
  ];

  # Optional: Configure additional services
  programs = {
    # Enable fish shell with Starship prompt (complements the modern theme)
    fish.enable = true;
    starship.enable = true;
    
    # Enable direnv for project-specific environments
    direnv.enable = true;
  };

  # Optional: Custom Waybar overrides
  # You can override specific Waybar settings if needed
  xdg.configFile."waybar/custom-overrides.css".text = ''
    /* Custom CSS overrides for your specific preferences */
    
    /* Example: Change the main bar height */
    /* window#waybar { height: 36px; } */
    
    /* Example: Customize workspace colors */
    /* #workspaces button.active { background: #your-color; } */
    
    /* Example: Hide specific modules on smaller screens */
    /* @media (max-width: 1366px) {
      #temperature,
      #idle_inhibitor {
        display: none;
      }
    } */
  '';
}
