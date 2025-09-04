{ config, pkgs, lib, ... }:
{
  system.stateVersion = "24.11";

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  networking.hostName = "blazar";
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  console.useXkbConfig = true;
  services.xserver = {
    enable = false;
    xkb.layout = "us";
    xkb.variant = "";
  };

  users.users.dscv = {
    isNormalUser = true;
    description = "Derek Vitrano";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    shell = pkgs.zsh;
  };

  # Boot & kernel
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.luks.devices.cryptroot.device = "/dev/disk/by-partlabel/luks";
    kernelParams = [
      "nvidia_drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "amd_iommu=on" "iommu=pt"
    ];
    plymouth = {
      enable = true;
      theme = "bgrt"; # theme tweaked later by HM/wayland look
    };
    # zram (no swapfile)
    kernel.sysctl."vm.swappiness" = 10;
  };

  zramSwap.enable = true;

  # Power management (desktop)
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;

  # Audio: PipeWire
  sound.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = false;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Networking
  networking.networkmanager.enable = true;
  services.avahi.enable = false; # no mDNS
  networking.firewall.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    openFirewall = true;
  };

  # Tailscale (+ SSH)
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [ "--ssh" "--accept-routes" "--advertise-tags=tag:nix-dev" ];
  };

  # NVIDIA (Wayland/GBM)
  hardware.opengl = {
    enable = true;
    driSupport32Bit = false;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = false;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Wayland session vars
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";  # Electron/Chromium on Wayland
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.gh.enable = true;
  programs.fzf = { enable = true; };

  # Virtualization / containers
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    containers.enable = true;
  };
  environment.systemPackages = with pkgs; [
    # CLI utils
    ripgrep fd eza bat jq sd bottom tree wget curl
    nvtop
    # file/archive tools
    p7zip unzip unrar
    # dev helpers
    jujutsu git gh direnv devenv
  ];

  # Greetd + Tuigreet → Niri session
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --theme 'catppuccin' --cmd ${pkgs.niri}/bin/niri-session";
        user = "greeter";
      };
    };
  };

  # XDG portals for Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Impermanence: persist selected paths via /persist subvolume
  fileSystems."/persist" = {
    device = "/dev/disk/by-label/cryptroot"; # mounted via btrfs subvol in disko
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=@persist" "compress=zstd:3" "noatime" "ssd" "discard=async" ];
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/systemd/coredump"
      "/var/lib/nixos"
      "/var/lib/tailscale"
      { directory = "/home/dscv/.config/ghostty"; user = "dscv"; group = "users"; mode = "0700"; }
      { directory = "/home/dscv/.config/Code"; user = "dscv"; group = "users"; mode = "0700"; }
      { directory = "/home/dscv/dev"; user = "dscv"; group = "users"; mode = "0755"; }
      # Extra dev persistence
      { directory = "/home/dscv/.ssh"; user = "dscv"; group = "users"; mode = "0700"; }
      { directory = "/home/dscv/.gitconfig"; user = "dscv"; group = "users"; }
      { directory = "/home/dscv/.config/jj"; user = "dscv"; group = "users"; }
      { directory = "/home/dscv/.jj"; user = "dscv"; group = "users"; }
      { directory = "/home/dscv/.config/gh"; user = "dscv"; group = "users"; }
      { directory = "/home/dscv/.config/direnv"; user = "dscv"; group = "users"; }
      { directory = "/home/dscv/.local/share/direnv"; user = "dscv"; group = "users"; }
      { directory = "/home/dscv/.config/devenv"; user = "dscv"; group = "users"; }
      { directory = "/home/dscv/.config/uv"; user = "dscv"; group = "users"; }
      { directory = "/home/dscv/.gnupg"; user = "dscv"; group = "users"; mode = "0700"; }
    ];
  };

  # Backups: restic + rclone (unit + timer)
  # Env/secrets supplied by sops-nix at runtime
  systemd.services."restic-backup" = {
    description = "Restic backup to B2 via rclone";
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = "/run/secrets/restic_env"; # provided by sops (B2 creds + RESTIC_PASSWORD + RCLONE_CONFIG path)
      ExecStart = "${pkgs.restic}/bin/restic backup --repo rclone:b2-blazar:nixos/blazar \
        --exclude-file=/etc/restic/excludes.txt \
        /home/dscv/dev /home/dscv/.config/Code /home/dscv/.config/ghostty /home/dscv/.ssh";
      ExecStartPost = "${pkgs.restic}/bin/restic forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --repo rclone:b2-blazar:nixos/blazar";
    };
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
  systemd.timers."restic-backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "daily 03:30";
    unitConfig.Description = "Daily Restic backup";
  };

  environment.etc."restic/excludes.txt".text = ''
    /home/dscv/.cache
  '';

  # Housekeeping
  system.autoUpgrade.enable = false; # per user preference
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Firewall ports (none open by default)
  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [];
}
