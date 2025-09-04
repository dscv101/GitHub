{ lib, ... }:
{
  perSystem = { pkgs, ... }: {
    formatter = pkgs.writeShellApplication {
      name = "fmt";
      runtimeInputs = [ pkgs.alejandra pkgs.shellcheck ];
      text = ''
        set -euo pipefail
        # Drop a literal "--" if nix passes it before forwarding args
        if [ "''${1-}" = "--" ]; then
          shift
        fi

        # If no args, format repo; otherwise forward args (e.g. --check)
        if [ $# -eq 0 ]; then
          alejandra .
        else
          alejandra "$@" .
        fi
      '';
    };
  };
}
