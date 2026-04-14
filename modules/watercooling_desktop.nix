{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.myConfig.modules.watercooling_desktop.enable = lib.mkEnableOption "Water cooling control (coolercontrol and liquidctl)";

  config = lib.mkIf config.myConfig.modules.watercooling_desktop.enable {
    environment.systemPackages = with pkgs; [
      coolercontrol.coolercontrol-gui
      coolercontrol.coolercontrold
      liquidctl
    ];

    # Enable i2c for fan and pump control
    hardware.i2c.enable = true;
    boot.kernelModules = [ "i2c-dev" ];

    # liquidctl and coolercontrol need udev rules for non-root access
    services.udev.packages = with pkgs; [
      liquidctl
      coolercontrol.coolercontrold
    ];

    # Enable the coolercontrol daemon service
    systemd.packages = [ pkgs.coolercontrol.coolercontrold ];
    systemd.services.coolercontrold = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
    };
  };
}
