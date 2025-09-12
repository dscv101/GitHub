# Example configuration for optimizing module imports
# Add this to your system configuration to disable unused features

{
  # Disable desktop environment for server/headless systems
  modules.desktop.enable = false;

  # Disable development tools for production systems
  modules.development.enable = false;

  # Enable virtualization only when needed
  modules.virtualization.enable = true;

  # Keep networking and security enabled (recommended)
  modules.networking.enable = true;
  modules.security.enable = true;
}

