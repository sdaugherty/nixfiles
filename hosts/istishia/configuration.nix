{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "istishia";

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  myConfig.modules = {
    common_cli.enable = true;
    common_desktop.enable = false;
    apps_cli.enable = true;
    apps_desktop.enable = false;
    dev_cli.enable = true;
    dev_desktop.enable = false;
    grocy_cli.enable = true;
    gaming_desktop.enable = false;
    emulators_desktop.enable = false;
    kde_desktop.enable = false;
    nvidia_desktop.enable = false;
    amd_desktop.enable = false;
  };
}
