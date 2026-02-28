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
    kde.enable = true;
    nvidia.enable = true;
    amd.enable = false;
  };
}
