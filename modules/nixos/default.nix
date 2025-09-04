{
  _class = "nixos";

  imports = [
    # keep-sorted start
    ../base
    ./desktop
    ./hardware
    ./networking
    ./security
    ./services
    ./virtualization
    # keep-sorted end
  ];
}
