{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "akadi";

  myConfig.modules = {
    apps.enable = true;
    dev.enable = false;
    gaming.enable = true;
    emulators.enable = true;
    kde.enable = true;
    nvidia.enable = false;
    amd.enable = true;
  };
}
