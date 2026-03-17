{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "akadi";

  myConfig.modules = {
    common_cli.enable = true;
    common_desktop.enable = true;
    apps_cli.enable = true;
    apps_desktop.enable = true;
    dev_cli.enable = false;
    dev_desktop.enable = false;
    gaming_desktop.enable = true;
    emulators_desktop.enable = true;
    kde_desktop.enable = true;
    nvidia_desktop.enable = false;
    amd_desktop.enable = true;
  };
}
