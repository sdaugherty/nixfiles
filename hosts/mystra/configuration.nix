{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "mystra";

  environment.systemPackages = [
    (pkgs.callPackage ../../pkgs/serenade-converter.nix { })
  ];

  # Enabled via the dedicated module (rather than just environment.systemPackages)
  # so services.udev.packages picks up the Stream Deck udev rules it ships.
  programs.streamcontroller.enable = true;

  myConfig.modules = {
    common_cli.enable = true;
    common_desktop.enable = true;
    apps_cli.enable = true;
    apps_desktop.enable = true;
    dev_cli.enable = true;
    dev_desktop.enable = true;
    gaming_desktop.enable = true;
    emulators_desktop.enable = true;
    kde_desktop.enable = true;
    cinnamon_desktop.enable = false;
    niri_desktop.enable = false;
    nvidia_desktop.enable = false;
    amd_desktop.enable = true;
    watercooling_desktop.enable = true;
    input_remapper_desktop.enable = true;
    # opendeck_desktop.enable = true;
  };
}
