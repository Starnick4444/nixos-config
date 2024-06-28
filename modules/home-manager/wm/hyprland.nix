{
  inputs,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    # systemd.enable = true;
    # xwayland.enable = true;

    settings = {};
    extraConfig = (builtins.readFile ./hyprland.conf) + (builtins.readFile ./keybindings.conf) + (builtins.readFile ./windowrules.conf) + (builtins.readFile ./animations.conf);
  };

  home.packages = with pkgs; [
    kitty
    hyprpaper
    thunar # file explorer
    pavucontrol # sound control
    waybar # status bar
    # TODO screenshot tool
    # TODO clipboard manager
  ];
}
