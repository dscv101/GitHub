{
  lib,
  config,
  ...
}: {
  imports = [
    ./backup.nix
  ] ++
  # Conditional import for development services
  (lib.optional config.modules.development.enable ./development.nix);
}
