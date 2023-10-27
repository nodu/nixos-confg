{ pkgs, lib, ... }:
{
  # Start with sway at command line
  # # https://github.com/ziap/dotfiles

  # Override the pulled in sway config
  xdg.configFile."sway/config".source = lib.mkForce ./sway.config;

  xdg.configFile."sway/screenshot.sh".source = ./sway-screenshot.sh;
  xdg.configFile."sway/wallpaper.jpg".source = ./sway-wallpaper.jpg;
  xdg.configFile."waybar/config".source = ./waybar-config.json;

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      #Can't use config bc mkForce config
      #As it pulls in the default config
      #
      # terminal = "alacritty";
      # output = {
      #   "Virtual-1" = {
      #     scale = "1.5";
      #   };
      # };
      # modifier = "Mod4";
    };
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = 1;
    WLR_NO_HARDWARE_CURSORS = 1;
  };
  #Packages
  home.packages = with pkgs; [
    wl-clipboard
    xorg.xeyes #use to check if running wayland on app
    wlr-randr
    grim
    waybar
  ];

  programs.waybar = {
    enable = true;
    style = builtins.readFile ./waybar-style.css;
    # TODO fix JSON import...
    # settings = builtins.toJSON (builtins.readFile ./waybar-config.json);
    # settings = builtins.toJSON (lib.importJSON ./waybar-config.json);
  };
}



