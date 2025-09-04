{
  description = "Blazar NixOS flake (Wayland/Niri, NVIDIA GBM, HM, sops-nix, disko, impermanence)";

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

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, home-manager, sops-nix, impermanence, disko, fenix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { system, pkgs, ... }: {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ git nixfmt-classic just ];
        };
      };

      flake = {
        nixosConfigurations = {
          blazar = let
            system = "x86_64-linux";
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          in nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs; };
            modules = [
              # Base + host modules
              ./nixos/common.nix
              ./hosts/blazar/hardware.nix
              ./hosts/blazar/disko.nix
              ./hosts/blazar/default.nix

              # Third-party modules
              disko.nixosModules.disko
              home-manager.nixosModules.home-manager
              sops-nix.nixosModules.sops
              impermanence.nixosModules.impermanence

              # Workaround override for HM oneshot service restart
              ./nixos/overrides/home-manager-service.nix

              # Home-Manager wiring
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.dscv = import ./home/dscv;
              }
            ];
          };
        };
      };
    };
}
