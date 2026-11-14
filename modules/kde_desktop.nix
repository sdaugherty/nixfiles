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

    # common.nix also installs xdg-desktop-portal-gtk by default, and plasma6
    # adds xdg-desktop-portal-kde — both at mkDefault priority, so both end up
    # installed with no tiebreaker. Without this, portal calls like OpenURI
    # (used by sandboxed/Wayland Electron apps such as Discord to "open link
    # in browser") can resolve to the GTK backend instead of KDE's, which
    # ignores the KDE-configured default browser.
    xdg.portal.config.common.default = lib.mkDefault [ "kde" ];
  };
}
