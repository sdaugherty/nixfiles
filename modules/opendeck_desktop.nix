{
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [ inputs.opendeck-nix.nixosModules.default ];

  options.myConfig.modules.opendeck_desktop.enable = lib.mkEnableOption "OpenDeck (Stream Deck control software)";

  config = lib.mkIf config.myConfig.modules.opendeck_desktop.enable {
    programs.opendeck.enable = true;
  };
}
