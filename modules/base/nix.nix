_: {
  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;

    # Automatic cleanup thresholds
    min-free = 1073741824; # 1GB - trigger cleanup when free space drops below this
    max-free = 3221225472; # 3GB - stop cleanup when free space reaches this

    # Build optimization
    cores = 0; # Use all available cores for parallel builds
    max-jobs = "auto"; # Automatically determine optimal number of parallel jobs

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
      "https://nix-blazar.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-blazar.cachix.org-1:YOUR_CACHE_PUBLIC_KEY_HERE"
    ];
  };

  # Reduce system impact by running nix daemon at idle priority
  nix.daemonCPUSchedPolicy = "idle";

  # Automatic store optimization
  nix.optimise = {
    automatic = true;
    dates = "daily"; # Run daily optimization for deduplication
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
