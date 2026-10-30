{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.myConfig.modules.amd_desktop.enable = lib.mkEnableOption "AMD graphics drivers and configuration";

  config = lib.mkIf config.myConfig.modules.amd_desktop.enable {
    boot.initrd.kernelModules = [ "amdgpu" ];
    services.xserver.videoDrivers = [ "amdgpu" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva
        vulkan-loader
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        vulkan-loader
      ];
    };

    environment.systemPackages = with pkgs; [
      libva-utils
      vulkan-tools
    ];
  };
}
