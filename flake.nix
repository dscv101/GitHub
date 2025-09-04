{
  description = "Updated repo: fixed formatter quoting, eval-safe NixOS config, minimal HM setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, home-manager, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { pkgs, system, ... }: {
        # nix fmt
        formatter = pkgs.writeShellApplication {
          name = "fmt";
          runtimeInputs = [ pkgs.alejandra ];
          text = ''
            set -euo pipefail

            # Drop a literal "--" if it shows up (nix can pass it before forwarding args)
            if [ "''${1-}" = "--" ]; then
              shift
            fi

            # If no paths were passed, format repo root; otherwise forward
            has_path=false
            for a in "$@"; do
              case "$a" in
                -*) ;;
                *) has_path=true ;;
              esac
            done

            if [ "$has_path" = false ]; then
              exec alejandra "$@" .
            else
              exec alejandra "$@"
            fi
          '';
        };

        # simple dev shell
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.git pkgs.alejandra ];
        };

        # placeholder package to make `nix build` work
        packages.default = pkgs.hello;
      };

      # An eval-safe NixOS config for CI. Uses tmpfs root to satisfy the assertion.
      flake.nixosConfigurations = {
        blazar = let
          system = "x86_64-linux";
          pkgs = import nixpkgs { inherit system; };
        in nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ lib, ... }: {
              nixpkgs.hostPlatform = system;
              system.stateVersion = "24.05";

              # Eval-only root fs for CI checks; adjust to your real disks for deployment.
              fileSystems."/" = {
                device = "nodev";
                fsType = "tmpfs";
                options = [ "mode=0755" ];
              };

              # Home Manager
              imports = [ home-manager.nixosModules.home-manager ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.dscv = import ./home/dscv/default.nix;

              # Removed deprecated sound.enable. If you need ALSA, use hardware.alsa.* options.
            })
          ];
        };
      };
    };
}
