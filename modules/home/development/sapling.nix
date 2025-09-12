_: {
  programs.sapling = {
    enable = true;
    settings = {
      user = {
        name = "dscv101";
        email = "derek.vitrano@gmail.com";
      };
      ui.default-command = "status";
      git = {
        auto-local-bookmark = true;
        push-bookmark-prefix = "trunk";
        auto = true;
        push-branches = true;
      };
      templates = {};
      aliases = {
        st = "status -s";
        ls = ''log -r ::@ --limit 20 --template "commit_id.short() ++ \"  \" ++ description.first_line()"'';
        d = "diff -r @-";
        amend = "amend -i";
        new = "new -m \"\"";
        mvup = "rebase -r @ -d @-";
        sync = "!sl git fetch && sl rebase -r @ -d trunk()";
        land = "!sl git push && gh pr create --fill --draft --web";
      };
    };
  };
}
