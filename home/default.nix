# Resources
# - `man home-configuration.nix`

# TODO:
# - cliphist

{
  config,
  pkgs,
  ...
}: let
  dot_config = "${config.home.homeDirectory}/dots/dot_config/";
  ln_conf = path: config.lib.file.mkOutOfStoreSymlink "${dot_config}/${path}";
in {
  imports = [
    ./games.nix
    ./git.nix
    ./firefox.nix
    ./terminal.nix
    ./theming.nix
  ];

  home.username = "gyk";
  home.homeDirectory = "/home/gyk";

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;
  };

  xdg.configFile = {
    # TODO: for each, `x.source = ln x`
    "nvim".source = ln_conf "lazyvim";
    "quickshell".source = ln_conf "quickshell";
    "hypr".source = ln_conf "hypr";
    "foot".source = ln_conf "foot";
    "waybar".source = ln_conf "waybar";
    "matugen".source = ln_conf "matugen";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    quickshell

    qutebrowser
    # element-desktop # Matrix client (ew, electron based)
    dino # xmpp client (cute logo, native gtk, lightweight)
    newsboat # RSS reader
    kiwix # for offline wikipedia and more
    freetube # yt frontend with local playlists, history, ..
    gnome-pomodoro
    transmission_4-gtk

    # creative
    godot
    blender
    kdePackages.kdenlive
    krita
    audacity
    gimp
    openutau # open singing synth, supports DiffSinger
    inkscape

    # media
    zathura # pdf reader
    vimiv-qt # vim-like image viewer
    libreoffice-stable
    playerctl # required by multimedia key bindings
    mpc
    rmpc

    pavucontrol
    gnome-clocks
    libnotify # for `notify-send` in scripts
    dunst # notification daemon, will replace with quickshell
    wireguard-tools
    # proton-vpn
    keepassxc
  ];

  services.mpd = {
    enable = true;
    musicDirectory = config.xdg.userDirs.music;
    extraConfig = ''
        audio_output {
            type "pipewire"
            name "My PipeWire Output"
        }
    '';
  };

  programs.mpv = {
    enable = true;
    scripts = [ pkgs.mpvScripts.mpris ];
    config = {
      save-position-on-quit = true;
    };
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  services.hypridle.enable = true;

  programs.direnv = {
    enable = true;
    # nix-direnv.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
