{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    # Make shared packages available to the flake
    _module.args.sharedPackages = import ./packages.nix {inherit pkgs;};
  };

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

    # Helper functions for development environments
    devenv = {
      # Combine base packages with language-specific ones
      mkPackages = {
        base ? [],
        language ? [],
        extra ? [],
      }: let
        inherit (inputs.nixpkgs.lib) concatLists;
      in
        concatLists [base language extra];

      # Standard git hooks configuration
      mkGitHooks = {
        # Nix
        alejandra.enable = true;
        statix.enable = true;
        deadnix.enable = true;

        # Shell scripts
        shellcheck.enable = true;
        shfmt.enable = true;

        # Documentation
        markdownlint.enable = true;

        # General
        check-yaml.enable = true;
        check-toml.enable = true;
        end-of-file-fixer.enable = true;
        trailing-whitespace.enable = true;
      };
    };
  };
}
