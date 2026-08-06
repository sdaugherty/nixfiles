{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  options.myConfig.modules.gaming_desktop = {
    enable = lib.mkEnableOption "Gaming tools";
    hytale.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include the Hytale launcher";
    };
  };

  config = lib.mkIf config.myConfig.modules.gaming_desktop.enable {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib  # libstdc++.so.6 for LWJGL native libs
        openal
      ];
    };

    environment.systemPackages = with pkgs;
      [
        heroic
        lutris
        protonup-qt
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
      ]
      ++ lib.optional config.myConfig.modules.gaming_desktop.hytale.enable
        inputs.hytale-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
