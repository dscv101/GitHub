{
  imports = [
    ../../modules/home
  ];

  home = {
    username = "dscv";
    homeDirectory = "/home/dscv";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
