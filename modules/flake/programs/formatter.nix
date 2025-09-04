{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = {config, ...}: {
    treefmt = {
      projectRootFile = "flake.nix";

      programs = {
        # Nix formatting
        alejandra.enable = true;

        # Dead code detection
        deadnix.enable = true;

        # Static analysis
        statix.enable = true;

        # Shell script tools (disabled due to conflicts)
        # shellcheck.enable = true;
        # shfmt = {
        #   enable = true;
        #   indent_size = 2;
        # };

        # TOML formatting
        taplo.enable = true;
      };

      settings = {
        global.excludes = [
          ".git-crypt/*"
          "secrets/*"
          "flake.lock"
          ".github/workflows/*"
          "*.yaml"
          "*.yml"
        ];
      };
    };

    # Set treefmt as the default formatter
    formatter = config.treefmt.build.wrapper;
  };
}
