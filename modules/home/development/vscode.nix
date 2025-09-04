{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default = {
      enableUpdateCheck = false;
      userSettings = {
        "window.titleBarStyle" = "custom";
        "window.autoDetectColorScheme" = true;
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.fixAll" = true;
          "source.organizeImports" = true;
        };
        "terminal.integrated.defaultProfile.linux" = "zsh";
        "workbench.colorTheme" = "Catppuccin Mocha";
        "security.workspace.trust.untrustedFiles" = "open";
        "telemetry.telemetryLevel" = "off";
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
  };
}
