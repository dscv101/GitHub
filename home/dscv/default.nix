{ config, pkgs, lib, ... }:
let
  catppuccin = pkgs.catppuccin-gtk;
in
{
  home.username = "dscv";
  home.homeDirectory = "/home/dscv";
  programs.home-manager.enable = true;

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = '' bindkey -v '';
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

  programs.atuin = { enable = true; enableZshIntegration = true; settings.auto_sync = false; };

  programs.direnv = { enable = true; nix-direnv.enable = true; };
  programs.fzf.enable = true;

  programs.git = {
    enable = true;
    userName = "dscv101";
    userEmail = "derek.vitrano@gmail.com";
    signing = { signByDefault = false; key = ""; };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = { name = "dscv101"; email = "derek.vitrano@gmail.com"; };
      ui.default-command = "status";
      git.auto-local-bookmark = true;
      git.push-bookmark-prefix = "trunk";
      aliases = {
        st = "status -s";
        ls = ''log -r ::@ --limit 20 --template "commit_id.short() ++ \"  \" ++ description.first_line()"'';
        d  = "diff -r @-";
        amend = "amend -i";
        new = "new -m \"\"";
        mvup = "rebase -r @ -d @-";
        sync = "!jj git fetch && jj rebase -r @ -d trunk()";
        land = "!jj git push && gh pr create --fill --draft --web";
      };
      git = { auto = true; push-branches = true; };
    };
  };

  # VS Code (official) + settings
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = false;
    userSettings = {
      "window.titleBarStyle" = "custom";
      "window.autoDetectColorScheme" = true;
      "editor.formatOnSave" = true;
      "editor.codeActionsOnSave" = { "source.fixAll" = true; "source.organizeImports" = true; };
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "workbench.colorTheme" = "Catppuccin Mocha";
      "security.workspace.trust.untrustedFiles" = "open";
      "telemetry.telemetryLevel" = "off";
      "claudeCode.defaultModel" = "sonnet";
      "claudeCode.inlineCompletions.enabled" = true;
      "claudeCode.telemetryEnabled" = false;
    };
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-toolsai.jupyter
      charliermarsh.ruff
      ms-vscode.cpptools
      rust-lang.rust-analyzer
      ziglang.vscode-zig
      github.vscode-pull-request-github
    ];
  };

  home.packages = with pkgs; [
    ghostty
    waybar swaylock-effects swww swappy grim slurp wl-clipboard cliphist fuzzel
    uv ruff mypy ipython jupyterlab
    duckdb sqlite postgresql pgcli
  ];

  xdg.configFile."waybar/config.jsonc".text = ''
  {
    "position": "top",
    "height": 28,
    "modules-left": ["niri/workspaces", "niri/mode", "window"],
    "modules-center": ["clock"],
    "modules-right": ["cpu", "memory", "disk", "network", "pulseaudio", "power-profiles-daemon", "tray"],
    "clock": { "format": "{:%a %b %d  %H:%M}" },
    "window": { "max-length": 60 },
    "cpu": { "interval": 3 },
    "memory": { "interval": 5 },
    "disk": { "interval": 30, "path": "/" },
    "network": {
      "format-wired": "{ifname}  {ipaddr}",
      "format-disconnected": "disconnected",
      "family": "ipv4"
    },
    "pulseaudio": {
      "scroll-step": 2,
      "format": "{volume}% {icon}",
      "format-muted": "muted "
    },
    "power-profiles-daemon": { "profiles": ["power-saver","balanced","performance"] },
    "tray": { "spacing": 6 }
  }
  '';

  xdg.configFile."waybar/style.css".text = ''
  * { font-family: "JetBrainsMono Nerd Font", Inter, sans-serif; font-size: 12px; }
  window#waybar { background: rgba(30,30,46,0.9); color: #c6d0f5; }
  #workspaces button.focused { background: #89b4fa; color: #1e1e2e; }
  #clock, #cpu, #memory, #disk, #network, #pulseaudio, #tray { padding: 0 8px; }
  '';

  xdg.configFile."niri/config.kdl".text = ''
    layout { gaps 8; border 2 }
    input { focus-follows-mouse false }
    monitor "DP-1" { scale 1.0; mode 1920x1080@60.00Hz; transform normal; vrr off; primary true }
    spawn "ghostty"
    spawn "code"
    binds {
      "SUPER+ENTER" => spawn "ghostty"
      "SUPER+Space" => spawn "fuzzel"
      "SUPER+E"     => spawn "code"
      "SUPER+H" => focus left; "SUPER+J" => focus down; "SUPER+K" => focus up; "SUPER+L" => focus right
      "SUPER+TAB" => focus next; "SUPER+SHIFT+TAB" => focus previous
      "SUPER+SHIFT+H" => move left; "SUPER+SHIFT+J" => move down; "SUPER+SHIFT+K" => move up; "SUPER+SHIFT+L" => move right
      "SUPER+CTRL+H" => resize decrease-width; "SUPER+CTRL+L" => resize increase-width
      "SUPER+CTRL+J" => resize increase-height; "SUPER+CTRL+K" => resize decrease-height
      "SUPER+F" => fullscreen; "SUPER+SHIFT+Space" => toggle-floating; "SUPER+Q" => close-window
      "SUPER+1" => switch-workspace 1; "SUPER+2" => switch-workspace 2; "SUPER+3" => switch-workspace 3
      "SUPER+4" => switch-workspace 4; "SUPER+5" => switch-workspace 5; "SUPER+6" => switch-workspace 6
      "SUPER+7" => switch-workspace 7; "SUPER+8" => switch-workspace 8; "SUPER+9" => switch-workspace 9
      "SUPER+SHIFT+1" => move-to-workspace 1; "SUPER+SHIFT+2" => move-to-workspace 2; "SUPER+SHIFT+3" => move-to-workspace 3
      "SUPER+SHIFT+4" => move-to-workspace 4; "SUPER+SHIFT+5" => move-to-workspace 5; "SUPER+SHIFT+6" => move-to-workspace 6
      "SUPER+SHIFT+7" => move-to-workspace 7; "SUPER+SHIFT+8" => move-to-workspace 8; "SUPER+SHIFT+9" => move-to-workspace 9
      "PRINT" => spawn "grimshot save active ~/Pictures/Screenshots"
      "SHIFT+PRINT" => spawn "grimshot save area ~/Pictures/Screenshots"
      "CTRL+PRINT" => spawn "grimshot copy area"
    }
  '';

  xdg.configFile."mako/config".text = "default-timeout=5000\n";
  programs.swaylock.enable = true;
  services.swayidle = {
    enable = true;
    events = [{ event = "before-sleep"; command = "${pkgs.swaylock-effects}/bin/swaylock -f --effect-blur 7x5"; }];
    timeouts = [
      { timeout = 600; command = "${pkgs.swaylock-effects}/bin/swaylock -f --effect-blur 7x5"; }
      { timeout = 900; command = "${pkgs.coreutils}/bin/true"; }
    ];
  };

  gtk = {
    enable = true;
    theme = { name = "Catppuccin-Mocha-Standard-Blue-Dark"; package = catppuccin; };
    iconTheme = { name = "Papirus-Dark"; package = pkgs.papirus-icon-theme; };
    font = { name = "Inter"; size = 11; };
  };

  xdg.configFile."ghostty/config".text = ''
    font = JetBrainsMono Nerd Font
    font-size = 11
    theme = Catppuccin-Mocha
  '';

  home.stateVersion = "24.11";
}
