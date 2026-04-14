{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  options.myConfig.modules.apps_desktop.enable = lib.mkEnableOption "Desktop applications";

  config = lib.mkIf config.myConfig.modules.apps_desktop.enable {
    programs.firefox.enable = true;
    programs.steam = {
      enable = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      extraPackages = with pkgs; [
        qogir-icon-theme
        steamtinkerlaunch
        corefonts
        winetricks
      ];
      extraCompatPackages = with pkgs; [
        steamtinkerlaunch
      ];
      fontPackages = with pkgs; [
        corefonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        liberation_ttf
        fira-code
        fira-code-symbols
        mplus-outline-fonts.githubRelease
        dina-font
        proggyfonts
      ];
    };

    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "stephanie" ];
    };


    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      corefonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
    ];

    fonts.enableDefaultPackages = true;

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
      kdePackages.kio
      kdePackages.kio-fuse
      kdePackages.kio-gdrive
      kdePackages.kio-extras
      kdePackages.kdesdk-kio
      kdePackages.kio-zeroconf
      kdePackages.dolphin-plugins
      kdePackages.filelight
      kdePackages.kaccounts-providers
      kdePackages.kaccounts-integration
      kaidan
      gramps
      pan
      lyx
      yad
      corefonts
      xwininfo
      xdotool
      kdotool
      yubioath-flutter
      alpaca
      kdePackages.alpaka
      thunderbird
      wineWowPackages.stable
      winetricks
      q4wine
      #protontricks
      protonup-ng
      protonplus
      super-productivity
      adoptopenjdk-icedtea-web
      bubblewrap
      inputs.nixpkgs-master.legacyPackages.${pkgs.system}.calibre
      inputs.affinity-nix.packages.${pkgs.system}.v3
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
         obs-pipewire-audio-capture
        ];
      })


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
