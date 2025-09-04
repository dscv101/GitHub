{ pkgs, ... }: {
  perSystem.formatter = pkgs.writeShellApplication {
    name = "fmt";
    text = ''
      set -eu
      # Drop a literal "--" if it shows up
      if [ "''${1-}" = "--" ]; then
        shift
      fi
      exec ${pkgs.alejandra}/bin/alejandra "$@" .
    '';
  };
}
