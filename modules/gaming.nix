{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  options.myConfig.modules.gaming.enable = lib.mkEnableOption "Gaming tools";

  config = lib.mkIf config.myConfig.modules.gaming.enable {
    environment.systemPackages = with pkgs; [
      heroic
      lutris
      protonup-qt
      inputs.hytale-launcher.packages.${pkgs.system}.default
      (prismlauncher.override {
        # Add binary required by some mod
        additionalPrograms = [ ffmpeg ];

        # Change Java runtimes available to Prism Launcher
        jdks = [
          zulu8
          zulu11
          zulu17
          zulu21
          zulu25
          zulu
        ];
      })
    ];
  };
}
