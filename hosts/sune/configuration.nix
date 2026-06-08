{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "sune";

  myConfig.modules = {
    common_cli.enable = true;
    common_desktop.enable = true;
    apps_cli.enable = true;
    apps_desktop.enable = true;
    dev_cli.enable = true;
    dev_desktop.enable = true;
    gaming_desktop = {
      enable = true;
      hytale.enable = false;
    };
    emulators_desktop.enable = false;
    kde_desktop.enable = true;
    nvidia_desktop.enable = false;
    amd_desktop.enable = true;
    input_remapper_desktop.enable = true;
  };
}
