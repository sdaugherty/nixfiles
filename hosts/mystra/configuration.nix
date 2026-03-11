{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "mystra";

  myConfig.modules = {
    apps.enable = true;
    dev.enable = true;
    gaming.enable = true;
    emulators.enable = true;
    kde.enable = true;
    nvidia.enable = false;
    amd.enable = true;
  };
}
