_: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      cmd_duration.disabled = false;
      time.disabled = false;
      nix_shell.disabled = false;
      git_branch.disabled = false;
      git_status.disabled = false;
      python.disabled = false;
    };
  };
}
