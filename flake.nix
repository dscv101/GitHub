{
  description = "Minimal, CI-friendly Nix flake with HM and a dummy NixOS host";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, flake-parts, home-manager, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./parts/fmt.nix
      ];

      perSystem = { system, pkgs, lib, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
          };
        in {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [ git alejandra nil rust-analyzer ];
          };

          packages.default = pkgs.hello;
        };

      flake = {
        nixosConfigurations = {
          blazar = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./nixos/hosts/blazar.nix

              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.dscv = import ./home/dscv/home.nix;
              }
            ];
          };
        };
      };
    };
}
