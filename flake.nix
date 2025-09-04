{
  description = "nix-blazar (fixed): NixOS flake for blazar with Niri, HM, NVIDIA Wayland, sops-nix, disko, impermanence";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, home-manager, sops-nix, disko, impermanence, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      flake = {
        nixosConfigurations.blazar = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            impermanence.nixosModules.impermanence

            ./hosts/blazar
            ./profiles/common
            ./profiles/desktop-niri
            ./profiles/devtoolchain
            ./profiles/nvidia
            ./secrets/sops

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.dscv = import ./home/dscv;
            }
          ];
        };
      };

      perSystem = { pkgs, ... }: {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ git jujutsu direnv devenv alejandra statix deadnix ];
          shellHook = "echo Dev shell: nix fmt / statix check / deadnix / nix flake check";
        };
        formatter = pkgs.alejandra;
      };
    };
}
