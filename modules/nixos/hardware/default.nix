_: {
  imports = [
    ./graphics.nix
    ./audio.nix
    ./power.nix
    ./bootloader-cleanup.nix
  ];

  # Enable hardware support
  security.rtkit.enable = true;
}
