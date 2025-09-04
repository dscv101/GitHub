{
  description = "Example NixOS + Home Manager flake (fixed skeleton)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Optional extras you mentioned
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs { inherit system; };
  in
  {
    # simple dev shell so `flake check` has something to evaluate
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [ nixpkgs-fmt git ];
    };

    nixosConfigurations.blazar = lib.nixosSystem {
      inherit system;
      modules = [
        ./nixos/common.nix
        ./hosts/blazar/default.nix

        # Home Manager as a NixOS module
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.dscv = import ./home/dscv/default.nix;
        }
      ];
    };
  };
}