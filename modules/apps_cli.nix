{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.myConfig.modules.apps_cli.enable = lib.mkEnableOption "CLI applications";

  config = lib.mkIf config.myConfig.modules.apps_cli.enable {
    environment.systemPackages = with pkgs; [
      irssi
      ncdu
      ollama
    ];
  };
}
