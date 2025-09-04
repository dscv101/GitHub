{inputs, ...}: {
  flake.lib = {
    # Helper function to create a NixOS system configuration
    mkSystem = {
      system ? "x86_64-linux",
      modules ? [],
      specialArgs ? {},
      ...
    }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules =
          [
            # Core modules
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            inputs.impermanence.nixosModules.impermanence

            # Home Manager integration
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.dscv = import ../../../home/dscv;
              };
            }
          ]
          ++ modules;

        specialArgs =
          {
            inherit inputs;
          }
          // specialArgs;
      };

    # Helper function to get all Nix files in a directory
    getNixFiles = dir: let
      inherit (inputs.nixpkgs.lib) filesystem;
    in
      builtins.filter (path: inputs.nixpkgs.lib.hasSuffix ".nix" (toString path))
      (filesystem.listFilesRecursive dir);
  };
}
