{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      # CLI utilities
      ripgrep
      fd
      eza
      bat
      jq
      sd
      bottom
      tree
      wget
      curl
      fzf
      
      # File/archive tools
      p7zip
      unzip
      unrar
      
      # Development helpers
      jujutsu
      git
      gh
      direnv
      devenv
    ];
  };
}
