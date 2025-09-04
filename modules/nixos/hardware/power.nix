_: {
  # Power management (desktop)
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;

  # zram swap
  zramSwap.enable = true;
  boot.kernel.sysctl."vm.swappiness" = 10;
}
