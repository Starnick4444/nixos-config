# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example
    # outputs.homeManagerModules.git
    # outputs.homeManagerModules.sh
    # outputs.homeManagerModules.cli-collection
    # outputs.homeManagerModules.virtualization
    # outputs.homeManagerModules.firefox

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ../modules/home-manager/default.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      # outputs.overlays.additions
      # outputs.overlays.modifications
      # outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "starnick";
    homeDirectory = "/home/starnick";

    packages = with pkgs; [
      # Core
      zsh
      kitty
      firefox # consider librewolf
      git

      # Office
      libreoffice-fresh

      wine

      # social
      discord

      ags

      spotify
      vlc
      obs-studio
      ffmpeg
      mediainfo
      libmediainfo
    ];
  };

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    music = "/home/starnick/Media/Music";
    videos = "/home/starnick/Media/Videos";
    pictures = "/home/starnick/Media/Pictures";
    download = "/home/starnick/Download";
    documents = "/home/starnick/Documents";
    desktop = null;
    publicShare = null;
    extraConfig = {
      XDG_DOTFILES_DIR = "/home/starnick/.dotfiles";
      XDG_ARCHIVE_DIR = "/home/starnick/Archive";
      XDG_VM_DIR = "/home/starnick/Machines";
      XDG_GAME_DIR = "/home/starnick/Media/Games";
      XDG_GAME_SAVE_DIR = "/home/starnick/Media/Game Saves";
    };
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
