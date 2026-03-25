{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.myConfig.modules.cinnamon_desktop.enable = lib.mkEnableOption "Cinnamon Desktop Environment";

  config = lib.mkIf config.myConfig.modules.cinnamon_desktop.enable {
    services.xserver.enable = true;
    services.xserver.desktopManager.cinnamon.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };
}
