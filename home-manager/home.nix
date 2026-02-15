# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [ ];

  # TODO: Set your username
  home = {
    username = "gyk";
    homeDirectory = "/home/gyk";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [ uv ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    settings = {
      user.name = "Krist0FF-T";
      user.email = "155083075+Krist0FF-T@users.noreply.github.com";
      init.defaultBranch = "main";
    };
    lfs.enable = true;
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/home/gyk/Music/";
    extraConfig = ''
        audio_output {
            type "pipewire"
            name "My PipeWire Output"
        }
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
