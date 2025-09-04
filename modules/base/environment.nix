{pkgs, ...}: {
  environment = {
    systemPackages = [
      # CLI utilities
      pkgs.ripgrep
      pkgs.fd
      pkgs.eza
      pkgs.bat
      pkgs.jq
      pkgs.sd
      pkgs.bottom
      pkgs.tree
      pkgs.wget
      pkgs.curl
      pkgs.fzf

      # File/archive tools
      pkgs.p7zip
      pkgs.unzip
      pkgs.unrar

      # Development helpers
      pkgs.jujutsu
      pkgs.git
      pkgs.gh
      pkgs.direnv
      pkgs.devenv
    ];
  };
}
