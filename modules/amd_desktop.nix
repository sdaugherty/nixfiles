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
        libva-vdpau-driver
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    environment.systemPackages = with pkgs; [
      libva-utils
    ];
  };
}
