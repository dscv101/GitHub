{ pkgs, ... }:
{
  checks = {
    # Nix formatting check
    alejandra-check = pkgs.runCommand "alejandra-check" { } ''
      ${pkgs.alejandra}/bin/alejandra --check ${./../../../.}
      touch $out
    '';
    
    # Statix check for Nix anti-patterns
    statix-check = pkgs.runCommand "statix-check" { } ''
      ${pkgs.statix}/bin/statix check ${./../../../.}
      touch $out
    '';
    
    # Dead code check
    deadnix-check = pkgs.runCommand "deadnix-check" { } ''
      ${pkgs.deadnix}/bin/deadnix --fail ${./../../../.}
      touch $out
    '';
  };
}
