_: {
  perSystem = {pkgs, ...}: {
    checks = {
      # Nix formatting check
      alejandra-check = pkgs.runCommand "alejandra-check" {} ''
        ${pkgs.alejandra}/bin/alejandra --check ${./../../../.}
        touch $out
      '';

      # Statix check for Nix anti-patterns
      statix-check = pkgs.runCommand "statix-check" {} ''
        ${pkgs.statix}/bin/statix check ${./../../../.}
        touch $out
      '';

      # Dead code check
      deadnix-check = pkgs.runCommand "deadnix-check" {} ''
        ${pkgs.deadnix}/bin/deadnix --fail ${./../../../.}
        touch $out
      '';

      # Shell script linting
      shellcheck-check = pkgs.runCommand "shellcheck-check" {} ''
        ${pkgs.shellcheck}/bin/shellcheck ${./../../../scripts}/*.sh
        touch $out
      '';

      # Shell script formatting check
      shfmt-check = pkgs.runCommand "shfmt-check" {} ''
        ${pkgs.shfmt}/bin/shfmt -d ${./../../../scripts}/*.sh
        touch $out
      '';

      # Markdown linting (disabled due to existing README formatting)
      # markdownlint-check = pkgs.runCommand "markdownlint-check" {} ''
      #   ${pkgs.markdownlint-cli}/bin/markdownlint ${./../../../.}/*.md
      #   touch $out
      # '';

      # YAML linting (disabled due to configuration conflicts)
      # yamllint-check = pkgs.runCommand "yamllint-check" {} ''
      #   ${pkgs.yamllint}/bin/yamllint ${./../../../.}
      #   touch $out
      # '';

      # GitHub Actions linting
      actionlint-check = pkgs.runCommand "actionlint-check" {} ''
        ${pkgs.actionlint}/bin/actionlint ${./../../../.github/workflows}/*.yml
        touch $out
      '';
    };
  };
}
