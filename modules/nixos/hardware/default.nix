_: {
  imports = [
    ./graphics.nix
    ./audio.nix
    ./power.nix
  ];

  # Enable hardware support
  security.rtkit.enable = true;
}
