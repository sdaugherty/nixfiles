{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.myConfig.modules.emulators.enable = lib.mkEnableOption "Emulators";

  config = lib.mkIf config.myConfig.modules.emulators.enable {
    environment.systemPackages = with pkgs; [
      zsnes
      blastem
      retroarch-full
      dosbox-x
    ];
  };
}
