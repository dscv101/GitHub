{pkgs, ...}: {
  languages.python = {
    enable = true;
    package = pkgs.python313;
    venv.enable = true;
    uv.enable = true;
  };
  packages = with pkgs; [duckdb];
  pre-commit.hooks = {
    ruff.enable = true;
    mypy.enable = true;
    pytest.enable = true;
  };
}
