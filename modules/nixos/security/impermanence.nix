_: {
  # Impermanence: persist selected paths via /persist subvolume
  # Note: /persist filesystem is defined in disko.nix
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/systemd/coredump"
      "/var/lib/nixos"
      "/var/lib/tailscale"
      {
        directory = "/home/dscv/.config/ghostty";
        user = "dscv";
        group = "users";
        mode = "0700";
      }
      {
        directory = "/home/dscv/.config/Code";
        user = "dscv";
        group = "users";
        mode = "0700";
      }
      {
        directory = "/home/dscv/dev";
        user = "dscv";
        group = "users";
        mode = "0755";
      }
      # Extra dev persistence
      {
        directory = "/home/dscv/.ssh";
        user = "dscv";
        group = "users";
        mode = "0700";
      }
      {
        directory = "/home/dscv/.gitconfig";
        user = "dscv";
        group = "users";
      }
      {
        directory = "/home/dscv/.config/jj";
        user = "dscv";
        group = "users";
      }
      {
        directory = "/home/dscv/.jj";
        user = "dscv";
        group = "users";
      }
      {
        directory = "/home/dscv/.config/gh";
        user = "dscv";
        group = "users";
      }
      {
        directory = "/home/dscv/.config/direnv";
        user = "dscv";
        group = "users";
      }
      {
        directory = "/home/dscv/.local/share/direnv";
        user = "dscv";
        group = "users";
      }
      {
        directory = "/home/dscv/.config/devenv";
        user = "dscv";
        group = "users";
      }
      {
        directory = "/home/dscv/.config/uv";
        user = "dscv";
        group = "users";
      }
      {
        directory = "/home/dscv/.gnupg";
        user = "dscv";
        group = "users";
        mode = "0700";
      }
    ];
  };

  environment.etc."restic/excludes.txt".text = ''
    /home/dscv/.cache
  '';
}
