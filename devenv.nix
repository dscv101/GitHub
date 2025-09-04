{pkgs, ...}: {
  # This file tells devenv where the project root is
  # when using devenv with flakes

  # Basic packages for the development environment
  packages = [pkgs.hello];

  # Set environment variables
  env.DEVENV_ROOT = builtins.toString ./.;

  enterShell = ''
    echo "Welcome to the development environment!"
    echo "Use 'nix develop' or specific devenv shells for language-specific environments."
  '';
}
