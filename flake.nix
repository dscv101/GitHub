{
  description = "Updated, formatted flake with safe formatter and eval-safe NixOS config";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = inputs @ { self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./parts/fmt.nix
      ];

      perSystem = { pkgs, ... }: {
        devShells.default = pkgs.mkShell { packages = [ pkgs.alejandra pkgs.shellcheck ]; };
      };

      flake = {
        nixosConfigurations.blazar = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./nixos/hosts/blazar.nix ];
        };
      };
    };
}
