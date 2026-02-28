{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.myConfig.modules.amd.enable = lib.mkEnableOption "AMD graphics drivers and configuration";

  config = lib.mkIf config.myConfig.modules.amd.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
