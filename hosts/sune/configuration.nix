{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "sune";

  myConfig.modules = {
    apps.enable = true;
    dev.enable = true;
    gaming.enable = true;
    emulators.enable = false;
    kde.enable = true;
    nvidia.enable = false;
    amd.enable = true;
  };
}
