{
  description = "nyx-updated repo with working nix fmt wrapper (alejandra over repo by default)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem = { pkgs, system, ... }: {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.alejandra pkgs.nixfmt-rfc-style ];
        };

        # Wrapper so `nix fmt -- --check` works (no files provided -> format/check ".")
        formatter = pkgs.writeShellApplication {
          name = "fmt";
          runtimeInputs = [ pkgs.alejandra ];
          text = ''
            set -euo pipefail

            # Drop a literal "--" if it shows up (nix can pass it before forwarding args)
            if [ "${1-}" = "--" ]; then
              shift
            fi

            # If only flags are provided (e.g., --check), append the repository root "."
            has_path=false
            for a in "$@"; do
              case "$a" in
                -*) ;;
                *) has_path=true ;;
              esac
            done
            if [ "$has_path" = false ]; then
              set -- "$@" "."
            fi

            exec alejandra "$@"
          '';
        };
      };

      flake = {
        nixosConfigurations.blazar = let
          system = "x86_64-linux";
          pkgs = import nixpkgs { inherit system; };
          lib = pkgs.lib;
        in
          lib.nixosSystem {
            inherit system;
            modules = [
              ({ config, pkgs, lib, ... }: {
                system.stateVersion = "24.05";

                # Provide a trivial root FS so evaluation doesn't assert during checks.
                fileSystems."/" = {
                  device = "tmpfs";
                  fsType = "tmpfs";
                  options = [ "mode=0755" "size=512M" ];
                };

                # Avoid bootloader assertions in generic CI environments
                boot.loader.grub.enable = false;
                boot.loader.systemd-boot.enable = lib.mkForce false;
                boot.loader.generic-extlinux-compatible.enable = lib.mkForce false;

                environment.systemPackages = with pkgs; [ vimMinimal ];
              })
            ];
          };
      };
    };
}