{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  options.myConfig.modules.apps.enable = lib.mkEnableOption "General applications";

  config = lib.mkIf config.myConfig.modules.apps.enable {
    programs.firefox.enable = true;
    programs.steam.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "stephanie" ];
    };

    environment.systemPackages = with pkgs; [
      libreoffice-qt-fresh
      obsidian
      discord
      typora
      captive-browser
      deezer-enhanced
      zoom-us
      kdePackages.isoimagewriter
      kdePackages.kcalc
      kdePackages.kcharselect
      kdePackages.konversation
      kdePackages.neochat
      kaidan
      irssi
      ncdu
      gramps
      pan
      lyx
      yubioath-flutter
      alpaca
      inputs.nixpkgs-master.legacyPackages.${pkgs.system}.calibre
      inputs.affinity-nix.packages.${pkgs.system}.v3
    ];

    xdg.mime.defaultApplications = {
      "text/html" = "org.mozilla.firefox";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
