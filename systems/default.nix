{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations = {
    blazar = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Core modules
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        inputs.impermanence.nixosModules.impermanence

        # System class module
        "${self}/modules/nixos"

        # Host-specific configuration
        ./blazar

        # Home Manager integration
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.dscv = import ../home/dscv;
          };
        }
      ];

      specialArgs = {
        inherit inputs;
      };
    };
  };
}
