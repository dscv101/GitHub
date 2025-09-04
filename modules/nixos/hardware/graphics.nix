{config, ...}: {
  # Graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = false;
  };

  # NVIDIA configuration (when applicable)
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = false;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
