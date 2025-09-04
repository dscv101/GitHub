{pkgs, ...}: {
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
      extensions = [
        pkgs.vscode-extensions.ms-python.python
        pkgs.vscode-extensions.ms-toolsai.jupyter
        pkgs.vscode-extensions.charliermarsh.ruff
        pkgs.vscode-extensions.ms-vscode.cpptools
        pkgs.vscode-extensions.rust-lang.rust-analyzer
        pkgs.vscode-extensions.ziglang.vscode-zig
        pkgs.vscode-extensions.github.vscode-pull-request-github
      ];
    };
  };
}
