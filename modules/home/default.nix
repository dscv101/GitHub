{
  lib,
  config,
  ...
}: {
  imports = [
    ./shell
    ./theming
  ] ++
  # Conditional imports for better performance
  (lib.optional config.modules.desktop.enable ./desktop) ++
  (lib.optional config.modules.development.enable ./development);
}
