{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.myConfig.modules.kde_desktop.enable = lib.mkEnableOption "KDE Desktop Environment";

  config = lib.mkIf config.myConfig.modules.kde_desktop.enable {
    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    services.xserver.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
