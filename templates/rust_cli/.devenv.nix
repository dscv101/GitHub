{pkgs, ...}: {
  languages.rust = {
    enable = true;
    channel = "stable";
  };
  pre-commit.hooks = {
    rustfmt.enable = true;
    clippy.enable = true;
  };
}
