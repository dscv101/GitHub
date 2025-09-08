_: {
  perSystem = {pkgs, ...}: {
    packages = {
      # Custom packages can be defined here
      # SDDM Themes
      sddm-astronaut-theme = pkgs.callPackage ../../../pkgs/sddm-themes/astronaut.nix { };
    };
  };
}
