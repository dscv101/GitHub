{ config, pkgs, lib, inputs, ... }:
let
  inherit (pkgs) stdenv;
in
{
  home.username = "dscv";
  home.homeDirectory = "/home/dscv";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = false; # use plugin below if desired
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "sudo" "direnv" ];
    };
    # Alternative autosuggestions via plugin package:
    plugins = [
      { name = "zsh-autosuggestions"; src = pkgs.zsh-autosuggestions; }
      { name = "zsh-syntax-highlighting"; src = pkgs.zsh-syntax-highlighting; }
    ];
    initExtra = ''
      eval "$(starship init zsh)"
    '';
  };

  programs.starship.enable = true;

  # Terminal (Ghostty)
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;
      theme = "Catppuccin-Mocha";
    };
  };

  # App launcher (Fuzzel) bound via Niri to SUPER+Space
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
      };
    };
  };

  # VS Code (official "code" build; Wayland enabled)
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    mutableExtensionsDir = true; # allow installing marketplace extensions at runtime
    userSettings = {
      "window.titleBarStyle" = "custom";
      "window.experimental.useSandbox" = false;
      "editor.formatOnSave" = true;
      "files.autoSave" = "off";
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "workbench.colorTheme" = "Catppuccin Mocha";
      "window.title" = "${config.home.username} — ${config.home.homeDirectory} — ${config.home.stateVersion}";
      "window.enableExperimentalBidi" = false;
      "telemetry.telemetryLevel" = "off";
      "window.autoDetectColorScheme" = true;
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "security.workspace.trust.enabled" = true;
      "terminal.integrated.enablePersistentSessions" = true;
      "terminal.integrated.defaultProfile.windows" = "zsh";
      "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
      "window.titleBarStyle" = "custom";
      "window.commandCenter" = false;
      # Wayland
      "ozone.platform" = "wayland";
      "window.titleBarStyle" = "custom";
    };
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-toolsai.jupyter
      ms-vscode.cpptools
      rust-lang.rust-analyzer
      ziglang.vscode-zig
      github.vscode-pull-request-github
    ];
  };

  # Git
  programs.git = {
    enable = true;
    userName = "dscv101";
    userEmail = "derek.vitrano@gmail.com";
    signing = {
      signByDefault = false;
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  # Direnv for per-project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Packages installed for the user
  home.packages = with pkgs; [
    # languages/tools
    python313 uv
    rustc cargo rust-analyzer
    zig
    nodejs
    # db tools
    duckdb sqlite postgresql
    # scm
    jujutsu
    # shells/cli
    fzf fd ripgrep eza bat
  ];

  # Basic Niri config (bind SUPER+Space to fuzzel)
  xdg.configFile."niri/config.kdl".text = ''
    binds {
      "Super+Space" = "exec fuzzel"
      "Super+Enter" = "exec ghostty"
      "Super+Q" = "close-window"
    }
  '';
}
