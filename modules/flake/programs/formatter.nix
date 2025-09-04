{ lib, inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, config, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        
        programs = {
          # Nix formatting
          alejandra.enable = true;
          
          # Dead code detection
          deadnix.enable = true;
          
          # Static analysis
          statix.enable = true;
          
          # Shell script tools
          shellcheck.enable = true;
          shfmt = {
            enable = true;
            indent_size = 2;
          };
          
          # Documentation and config
          markdownlint.enable = true;
          yamllint.enable = true;
          
          # TOML formatting
          taplo.enable = true;
          
          # Lua formatting (if you have .lua files)
          stylua.enable = true;
          
          # GitHub Actions
          actionlint.enable = true;
          
          # Keep imports sorted
          keep-sorted.enable = true;
        };
        
        settings = {
          global.excludes = [
            ".git-crypt/*"
            "secrets/*"
            "flake.lock"
          ];
          
          formatter = {
            keep-sorted = {
              includes = [ "*.nix" ];
            };
          };
        };
      };
      
      # Set treefmt as the default formatter
      formatter = config.treefmt.build.wrapper;
    };
}
