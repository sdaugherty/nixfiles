{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.myConfig.modules.niri_desktop.enable = lib.mkEnableOption "Niri Window Manager";

  config = lib.mkIf config.myConfig.modules.niri_desktop.enable {
    programs.niri.enable = true;
    programs.dconf.enable = true;

    # Niri recommends a few things for a better experience
    environment.systemPackages = with pkgs; [
      waybar
      swaybg
      swaylock
      swayidle
      foot # Default terminal often used with niri
      mako # Notification daemon
      fuzzel # Application launcher
      xwayland # For X11 apps
    ];

    # XDG Portals for screen sharing and other desktop features
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      config.common.default = [ "gnome" "gtk" ];
    };

    # Enable polkit for authentication
    security.polkit.enable = true;
  };
}
