_: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh.enable = false;
    initContent = ''
      bindkey -v  # vi-mode
    '';
    shellAliases = {
      ll = "eza -l --git";
      la = "eza -la --git";
      gs = "jj st";
      gl = "jj ls";
      gd = "jj d";
      gco = "jj new -m";
      py = "python";
      ipy = "ipython";
    };
  };
}
