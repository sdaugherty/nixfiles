{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.myConfig.modules.emulators_desktop.enable = lib.mkEnableOption "Emulators";

  config = lib.mkIf config.myConfig.modules.emulators_desktop.enable {
    environment.systemPackages = with pkgs; [
      zsnes
      blastem
      retroarch-full
      dosbox-x
    ];
  };
}
