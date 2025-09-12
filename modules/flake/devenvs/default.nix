{inputs, ...}: {
  imports = [
    inputs.devenv.flakeModule
    ./python.nix
    ./rust.nix
    ./zig.nix
    ./julia.nix
  ];

  perSystem = {pkgs, sharedPackages, ...}: {
    # Simple base development shell
    devenv.shells.default = {
      name = "nix-blazar-dev";
      packages = sharedPackages.base;
      enterShell = ''
        echo "🚀 Development shell ready!"
        echo "Available shells: python, rust, zig, julia"
      '';
    };

    # Git hooks for code quality (can be enabled per profile)
    # git-hooks.hooks = {
    #   # Nix
    #   alejandra.enable = true;
    #   statix.enable = true;
    #   deadnix.enable = true;
    #
    #   # Shell scripts
    #   shellcheck.enable = true;
    #   shfmt.enable = true;
    #
    #   # Documentation
    #   markdownlint.enable = true;
    #
    #   # General
    #   check-yaml.enable = true;
    #   check-toml.enable = true;
    #   end-of-file-fixer.enable = true;
    #   trailing-whitespace.enable = true;
    # };
  };
}
