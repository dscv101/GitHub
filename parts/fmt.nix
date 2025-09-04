{ lib, pkgs, ... }:
{
  perSystem = { pkgs, ... }: {
    formatter = pkgs.alejandra;
  };
}
