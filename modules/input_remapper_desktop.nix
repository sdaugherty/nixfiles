{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.myConfig.modules.input_remapper_desktop.enable = lib.mkEnableOption "input-remapper service and GUI";

  config = lib.mkIf config.myConfig.modules.input_remapper_desktop.enable {
    services.input-remapper.enable = true;
    environment.systemPackages = with pkgs; [
      input-remapper
    ];
  };
}
