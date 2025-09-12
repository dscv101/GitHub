{
  description = "nix-blazar: NixOS flake (flake-parts) for host blazar with Niri, Home Manager, NVIDIA (Wayland/GBM), sops-nix, disko, impermanence";

  nixConfig = {
    extra-trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-blazar.cachix.org-1:YOUR_CACHE_PUBLIC_KEY_HERE"
    ];
    extra-substituters = [
      "https://devenv.cachix.org"
      "https://nix-blazar.cachix.org"
    ];
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} {imports = [./modules/flake/default.nix];};

  inputs = {
    # Core system dependencies - pinned for reproducibility
    nixpkgs.url = "github:NixOS/nixpkgs/250b695f41e0";

    # Flake ecosystem
    flake-parts = {
      url = "github:hercules-ci/flake-parts/4524271976b625a4a605beefd893f270620fd751";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # System configuration
    home-manager = {
      url = "github:nix-community/home-manager/6d7c11a0adee0db21e3a8ef90ae07bb89bc20b8f";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix/0bf793823386187dff101ee2a9d4ed26de8bbf8c";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/146f45bee02b8bd88812cfce6ffc0f933788875a";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence/4b3e914cdf97a5b536a889e939fb2fd2b043a170";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development tools
    treefmt-nix = {
      url = "github:numtide/treefmt-nix/1aabc6c05ccbcbf4a635fb7a90400e44282f61c4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv/c57bded76fa6a885ab1dee2c75216cc23d58b311";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
