{pkgs, ...}: {
  imports = [
    ./hyprlock
    ./rofi
    ./waybar
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    systemd.enable = true;
    xwayland.enable = true;

    settings = {};
    extraConfig = (builtins.readFile ./hyprland.conf) + (builtins.readFile ./keybindings.conf) + (builtins.readFile ./windowrules.conf) + (builtins.readFile ./animations.conf);
  };

  xdg = {
    enable = true;
    # Portal config
    portal = {
      # enable = true;
      # extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr];
    };

    userDirs = {
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

    # wallpapper
    dataFile."wallpaper.jpeg" = {
      source = ./red-katana.jpeg;
    };
    dataFile."wallpaper_11.jpg" = {
      source = ./wallpaper_11.jpg;
    };
  };

  services = {
    hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };

        listener = [
          {
            timeout = 150; # 2.5min.
            on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
            on-resume = "brightnessctl -r"; # monitor backlight restore.
          }
          {
            timeout = 150; # 2.5min.
            on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0"; # turn off keyboard backlight.
            on-resume = "brightnessctl -rd rgb:kbd_backlight"; # turn on keyboard backlight.
          }
          {
            timeout = 3000; # 5min
            on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
          }
          {
            timeout = 3300; # 5.5min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 1800; # 30min
            on-timeout = "systemctl suspend"; # suspend pc
          }
        ];
      };
    };
    hyprpaper = {
      enable = true;
      settings = {
        preload = ["$XDG_DATA_HOME/wallpaper_11.jpg"];

        wallpaper = [",$XDG_DATA_HOME/wallpaper_11.jpg"];
      };
    };
    dunst = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    kitty
    hyprpaper
    xfce.thunar # file explorer
    pavucontrol # sound control
    pamixer # sound control
    brightnessctl # screen brightness control
    playerctl
    swappy
    hyprshade
    grimblast
    wl-clipboard

    # bluetooth
    bluez-tools
    blueberry

    # Screenshot script
    (pkgs.writeShellScriptBin "screenshot" ''
      # Restores the shader after screenhot has been taken
      restore_shader() {
      	if [ -n "$shader" ]; then
      		hyprshade on "$shader"
      	fi
      }

      # Saves the current shader and turns it off
      save_shader() {
      	shader=$(hyprshade current)
      	hyprshade off
      	trap restore_shader EXIT
      }

      save_shader # Saving the current shader

      if [ -z "$XDG_PICTURES_DIR" ]; then
      	XDG_PICTURES_DIR="$HOME/Pictures"
      fi

      swpy_dir="~/.config/swappy"
      save_dir="$XDG_PICTURES_DIR/screenshots"
      save_file=$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')
      temp_screenshot="/tmp/screenshot.png"

      mkdir -p $save_dir
      mkdir -p $swpy_dir
      echo -e "[Default]\nsave_dir=$save_dir\nsave_filename_format=$save_file" >$swpy_dir/config

      function print_error
      {
      	cat <<"EOF"
          ./screenshot.sh <action>
          ...valid actions are...
              p  : print all screens
              s  : snip current screen
              sf : snip current screen (frozen)
              m  : print focused monitor
      EOF
      }

      case $1 in
      p) # print all outputs
      	grimblast copysave screen $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
      s) # drag to manually snip an area / click on a window to print it
      	grimblast copysave area $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
      sf) # frozen screen, drag to manually snip an area / click on a window to print it
      	grimblast --freeze copysave area $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
      m) # print focused monitor
      	grimblast copysave output $temp_screenshot && restore_shader && swappy -f $temp_screenshot ;;
      *) # invalid option
      	print_error ;;
      esac

      rm "$temp_screenshot"
    '')
    # TODO clipboard manager
  ];
}
