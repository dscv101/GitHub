{
  lib,
  config,
  ...
}: {
  _class = "nixos";

  imports = [
    # keep-sorted start
    ../base
    ../common.nix
    # keep-sorted end
  ] ++
  # Conditional imports for better performance
  (lib.optional config.modules.desktop.enable ./desktop) ++
  (lib.optional config.modules.networking.enable ./networking) ++
  (lib.optional config.modules.security.enable ./security) ++
  (lib.optional config.modules.virtualization.enable ./virtualization) ++
  # Always import hardware and services (core functionality)
  [
    ./hardware
    ./services
  ];
}
