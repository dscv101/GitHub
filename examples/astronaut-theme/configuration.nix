# Example configuration for using the Astronaut SDDM theme
# This shows how to enable SDDM with the beautiful space-themed login screen

{ config, pkgs, ... }:

{
  # Import the desktop modules (includes SDDM support)
  imports = [
    ../../modules/nixos/desktop
  ];

  # Enable SDDM display manager with Astronaut theme
  desktop.sddm = {
    enable = true;
    enableAstronautTheme = true;
  };

  # Optional: Additional desktop environment
  # services.xserver.desktopManager.plasma5.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # The astronaut theme works great with Wayland compositors
  # programs.niri.enable = true;  # Already enabled in desktop module
  
  # Optional: Customize SDDM further
  # services.displayManager.sddm.settings = {
  #   Theme = {
  #     Current = "astronaut";
  #     CursorTheme = "Adwaita";
  #   };
  # };
}
