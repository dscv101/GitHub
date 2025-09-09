{
  pkgs,
  ...
}: {
  # SDDM Themes
  sddm-astronaut-theme = pkgs.callPackage ./sddm-themes/astronaut.nix { };
}
