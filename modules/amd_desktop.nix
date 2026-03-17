{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.myConfig.modules.amd_desktop.enable = lib.mkEnableOption "AMD graphics drivers and configuration";

  config = lib.mkIf config.myConfig.modules.amd_desktop.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
