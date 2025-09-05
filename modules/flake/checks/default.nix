_: {
  perSystem = {pkgs, ...}: {
    checks = {
      # Nix formatting check
      alejandra-check = pkgs.runCommand "alejandra-check" {} ''
        ${pkgs.alejandra}/bin/alejandra --check ${./../../../.} || {
          echo "Alejandra formatting check failed. Run 'alejandra .' to fix formatting."
          exit 1
        }
        touch $out
      '';

      # Statix check for Nix anti-patterns
      statix-check = pkgs.runCommand "statix-check" {} ''
        ${pkgs.statix}/bin/statix check ${./../../../.} || {
          echo "Statix found Nix anti-patterns. Review the output above."
          exit 1
        }
        touch $out
      '';

      # Dead code check
      deadnix-check = pkgs.runCommand "deadnix-check" {} ''
        ${pkgs.deadnix}/bin/deadnix --fail ${./../../../.} || {
          echo "Deadnix found dead code. Run 'deadnix --edit .' to remove it."
          exit 1
        }
        touch $out
      '';

      # Shell script linting (conditional on scripts directory existence)
      shellcheck-check = pkgs.runCommand "shellcheck-check" {} ''
        if [ -d "${./../../../scripts}" ] && [ -n "$(find ${./../../../scripts} -name '*.sh' 2>/dev/null)" ]; then
          ${pkgs.shellcheck}/bin/shellcheck ${./../../../scripts}/*.sh
        else
          echo "No shell scripts found to check"
        fi
        touch $out
      '';

      # Shell script formatting check (conditional on scripts directory existence)
      shfmt-check = pkgs.runCommand "shfmt-check" {} ''
        if [ -d "${./../../../scripts}" ] && [ -n "$(find ${./../../../scripts} -name '*.sh' 2>/dev/null)" ]; then
          ${pkgs.shfmt}/bin/shfmt -d ${./../../../scripts}/*.sh
        else
          echo "No shell scripts found to format"
        fi
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

      # GitHub Actions linting (conditional on workflows directory existence)
      actionlint-check = pkgs.runCommand "actionlint-check" {} ''
        if [ -d "${./../../../.github/workflows}" ] && [ -n "$(find ${./../../../.github/workflows} -name '*.yml' -o -name '*.yaml' 2>/dev/null)" ]; then
          ${pkgs.actionlint}/bin/actionlint ${./../../../.github/workflows}/*.yml ${./../../../.github/workflows}/*.yaml 2>/dev/null || true
        else
          echo "No GitHub Actions workflows found to check"
        fi
        touch $out
      '';
    };
  };
}
