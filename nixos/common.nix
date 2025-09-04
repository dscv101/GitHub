{ config, pkgs, lib, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "blazar";
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  console = { keyMap = "us"; };

  # Boot & kernel
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    plymouth.enable = true;
    kernelParams = [ "nvidia_drm.modeset=1" ];
    initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  };

  # Filesystems + impermanence baseline (persist at /persist)
  environment.persistence."/persist" = {
    enable = true;
    directories = [
      "/var/lib/systemd/coredump"
      "/var/lib/nixos"
      "/var/lib/tailscale"
      { directory = "/home/dscv/.config/ghostty"; user = "dscv"; group = "users"; mode = "0700"; }
      { directory = "/home/dscv/.config/Code"; user = "dscv"; group = "users"; mode = "0700"; }
      { directory = "/home/dscv/dev"; user = "dscv"; group = "users"; mode = "0755"; }
    ];
  };

  # Snapper for @home
  services.snapper = {
    configs.home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ "dscv" ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_DAILY = 7;
    };
  };

  # Users
  users.users.dscv = {
    isNormalUser = true;
    description = "Derek Vitrano";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    shell = pkgs.zsh;
  };

  # Wayland + Niri
  programs.niri.enable = true;
  services.xserver.enable = false;

  # NVIDIA GBM stack
  hardware.graphics = {
    enable = true;
    # VAAPI / NVENC helper
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    # Let nixpkgs choose a good default
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Power management
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;

  # Networking
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };
  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.avahi.enable = false;

  # Virtualization
  virtualisation = {
    libvirtd.enable = true;
    podman.enable = true;
  };

  # xdg portals for screen-share
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  # Login manager (greetd + tuigreet) launching Niri
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.niri}/bin/niri";
        user = "dscv";
      };
    };
    greeter = {
      package = pkgs.tuigreet;
      command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --cmd ${pkgs.niri}/bin/niri";
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    git gh
    curl wget jq yq gnupg
    direnv nix-direnv cachix devenv
    jujutsu
    duckdb sqlite postgresql
    # dev toolchain
    python313 uv
    rustc cargo rust-analyzer
    zig
    vscode
    ghostty
    fuzzel
    # containers
    podman-compose
    # misc
    starship
  ];

  # Direnv (system-wide hook)
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Auto-upgrade disabled as requested
  system.autoUpgrade.enable = false;

  # SOPS-Nix baseline (secrets file is a placeholder; you will replace/ encrypt)
  sops = {
    defaultSopsFile = ./../secrets/secrets.yaml;
    age = {
      keyFile = "/var/lib/sops-nix/key.txt"; # create on the machine or import
      # sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; # alternative
    };
    secrets = {
      restic_password = { };
      motherduck_token = { };
    };
  };

  # Restic + rclone skeleton (won't run until you set repository & rclone config)
  programs.rclone.enable = true;
  services.restic.backups.home = {
    user = "root";
    paths = [ "/home/dscv" ];
    # Example repository string via rclone remote "md:"; adjust after configuring rclone.
    repository = "rclone:md:blazar/home";
    passwordFile = config.sops.secrets.restic_password.path;
    initialize = false;
    timerConfig = { OnCalendar = "weekly"; RandomizedDelaySec = "1h"; };
  };

  # Export MotherDuck token to user sessions (read from sops at activation)
  systemd.user.services."export-motherduck-token" = {
    Unit.Description = "Export MotherDuck token into user env file";
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/sh -c 'install -d -m700 ${config.users.users.dscv.home}/.config && echo MOTHERDUCK_TOKEN=$(cat ${config.sops.secrets.motherduck_token.path}) > ${config.users.users.dscv.home}/.config/motherduck.env'";
    };
  };

  # Make sure WAYLAND apps prefer Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
  };

  # State version (pin when you first deploy; adjust if needed)
  system.stateVersion = "24.05";
}
