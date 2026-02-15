{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.xserver.enable = false;
  # services.desktopManager.plasma6.enable = true;
  # services.displayManager.sddm.enable = false;

  users.users.gyk = {
    isNormalUser = true;
    description = "kristóf";
    extraGroups = [ "networkmanager" "wheel" ];
    initialPassword = "password";
    packages = with pkgs; [
      godot
      blender
      kdePackages.kdenlive
      krita

      # media
      zathura
      mpv
      vimiv-qt
      libreoffice-fresh
      mpc ncmpcpp rmpc # mpd stuff (new to it)

      # cool cli shit (ordered by usefulness)
      libqalculate
      ani-cli yt-dlp # entertainment
      microfetch
      eza
      cowsay
      cava

      # # games
      prismlauncher
      luanti # (formerly minetest)
      # factorio-demo
      # veloren mindustry supertuxkart supertux (from git) the-powder-toy (little 2d sandbox)
      # ? 0ad, hedgewars, warzone-2100, freeciv
    ];
  };

  programs.hyprland.enable = true;

  programs.firefox.enable = true;

  # == NeoVim ==
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = true;
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [ thunar-archive-plugin ];
  };

  programs.steam.enable = true;

  programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # hypr
    foot
    waybar
    wofi
    grim slurp
    hyprpicker
    hyprpaper
    networkmanagerapplet
    adwaita-icon-theme
    brightnessctl
    matugen

    # nvim
    wl-clipboard
    basedpyright
    clang-tools # clangd
    lua-language-server
    rust-analyzer-unwrapped
    stylua
    shfmt

    # other
    htop btop
    vim
    git
    wget
    gcc
    zip unzip
    fzf
    ripgrep

    hyprsunset # gammastep
    tmux
    swayimg
    imagemagick
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-mono
  ];

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = ''
        ${pkgs.tuigreet}/bin/tuigreet \
          --remember --time --asterisks \
          --greeting "Szia Lajos!" \
          --cmd Hyprland
      '';
    };
  };

  # ---------- low editing frequency ----------

  services.gvfs.enable = true;

  # X11 and console keymap
  services.xserver.xkb.layout = "hu";
  console.keyMap = "hu";

  security.polkit.enable = true;
  systemd.user.services.hyprpolkitagent = {
    description = "hyprpolkitagent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  networking = {
    # Enable networking
    networkmanager.enable = true;
    hostName = "gyik-hp";
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # firewall.enable = false;
  };

  # Set your time zone.
  time.timeZone = "Europe/Budapest";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "hu_HU.UTF-8";
    LC_IDENTIFICATION = "hu_HU.UTF-8";
    LC_MEASUREMENT = "hu_HU.UTF-8";
    LC_MONETARY = "hu_HU.UTF-8";
    LC_NAME = "hu_HU.UTF-8";
    LC_PAPER = "hu_HU.UTF-8";
    LC_TELEPHONE = "hu_HU.UTF-8";
    LC_TIME = "hu_HU.UTF-8";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # # conflicts with ssh agent
    # enableSSHSupport = true;
  };

  programs.ssh.startAgent = true;

  # List services that you want to enable:

  services.openssh.enable = true;
  services.printing = {
    enable = true; # CUPS
    drivers = with pkgs; [
      # cnijfilter # Canon PIXMA MG2400 series
      gutenprint # fallback
    ];
  };
  hardware.bluetooth.enable = true;

  # nvidia stuff
  hardware.graphics.enable = true;
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # package = config.boot.kernelPackages.nvidiaPackages.beta;
    powerManagement.enable = false;
    nvidiaSettings = true;

    # >= Turing
    open = false;
    powerManagement.finegrained = false;
  };

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # 6.12: SLTS (2035)
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
